# pylint: disable=E1101
"""_manage comtains functions to manage the site using dragon"""
import asyncio
import datetime
import importlib
import os
import secrets
import shutil
import sys
import time
import uuid
from getpass import getpass
from pathlib import Path
from subprocess import DEVNULL, Popen
import requests

def error(msg: str, code: int = 1):
    print(msg)
    return sys.exit(code)


def confirm(msg, abort: bool = True):
    while True:
        check = input(msg + "(Y/N): ")
        if check.lower() in ("y", "yes"):
            return True
        if check.lower() in ("n", "no"):
            if abort:
                sys.exit(1)
            return False


def site_gensecret():
    """Generates a random secret"""
    print(secrets.token_urlsafe())


def site_compilestatic():
    """Compiles all labelled static files"""
    for src_file in Path("data/static/assets/src").rglob("*.js"):
        out_file = (str(src_file).replace(".js", ".min.js").replace(
            "src/", "prod/").replace("js/", ""))
        print(f"{src_file} -> {out_file}")
        cmd = [
            "google-closure-compiler",
            "--js",
            str(src_file),
            "--js_output_file",
            out_file,
        ]

        with Popen(cmd, env=os.environ) as proc:
            proc.wait()

    for src_file in Path("data/static/assets/src").rglob("*.scss"):
        out_file = (str(src_file).replace(".scss", ".min.css").replace(
            "src/", "prod/").replace("css/", ""))
        print(f"{src_file} -> {out_file}")
        cmd = ["sass", "--style=compressed", str(src_file), out_file]

        with Popen(cmd, env=os.environ) as proc:
            proc.wait()

    for img in Path("data/static/assets/src/img").rglob("*"):
        ext = str(img).split(".")[-1]
        out = str(img).replace("src/img/", "prod/").replace(f".{ext}", ".webp")
        print(f"{img} -> {out}")

        if ext == "webp":
            shutil.copy2(str(img), out)
        else:
            cmd = ["cwebp", "-quiet", "-q", "75", str(img), "-o", out]

            with Popen(cmd, env=os.environ) as proc:
                proc.wait()

def db_backup():
    """Backs up the Fates List database"""
    from loguru import logger

    logger.info("Starting backups")

    bak_id = datetime.datetime.now().strftime("%Y-%m-%d~%H:%M:%S")
    cmd = f"pg_dump -Fc > /backups/full-{bak_id}.bak"

    with Popen(cmd, shell=True, env=os.environ) as proc:
        proc.wait()

    logger.info("Backup of full db done. Backing up only schema...")

    try:
        Path("/backups/latest.bak").unlink()
    except FileNotFoundError:
        pass

    Path("/backups/latest.bak").symlink_to(f"/backups/full-{bak_id}.bak")
    cmd = f"pg_dump -Fc --schema-only --no-owner > /backups/schema-{bak_id}.bak"

    with Popen(cmd, shell=True, env=os.environ) as proc:
        proc.wait()

    logger.info("Schema backup done")

    local_recv = os.environ.get("UPLOAD_DIR") or getpass(prompt="Enter server upload dir (optional)")

    conf_pwd = os.environ.get("RCLONE_PWD") or getpass(prompt="Enter rclone conf password: ")
    for bak_type in ("full", "schema"):
        os.chdir("/tmp")
        cmd = (
            f"rclone copy /backups/{bak_type}-{bak_id}.bak 'Fates List:' "
        )
        cmd += f"--password-command 'printf {conf_pwd}'"

        with Popen(cmd, env=os.environ, shell=True) as proc:
            proc.wait()

        # Copy out of FatesList directory
        for f in Path("FatesList").glob("*.bin"):
            if local_recv:
                print(f, f" is being pushed on to {local_recv}")
                with open(str(f), "rb") as f:
                    files = {"file": ("fb/"+f.name, f, "multipart/form-data")}
                    requests.post(url=f"{local_recv.rstrip('/')}/recv", files=files)

        shutil.rmtree("FatesList")

    logger.success("Backups done!")

def db_apply():
    """Apply Fates List database migration"""
    import uvloop

    from loguru import logger

    uvloop.install()

    import aioredis
    import asyncpg

    module = os.environ.get("MIGRATION")

    if not module:
        raise RuntimeError(
            "No migration found. Set MIGRATION envvar to migration file path")

    try:
        migration = importlib.import_module(module)
        _ = migration.apply  # Check for apply function
    except Exception as exc:
        return error(f"Could not import migration file: {exc}")

    async def _migrator():
        postgres = await asyncpg.create_pool()
        redis = aioredis.from_url("redis://localhost:1001", db=1)
        logger.info("Starting migration")
        ret = await migration.apply(postgres=postgres,
                                    redis=redis,
                                    logger=logger)
        logger.success(f"Migration applied with return code of {ret}")

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.run_until_complete(_migrator())

def db_setup():
    """Setup Snowfall (the Fates List database system)"""
    from loguru import logger

    home = os.environ.get("HOMEDIR") or Path.home()
    home = Path(str(home))

    backup = os.environ.get("backup", False)
    if backup:
        backup = True

    confirm(
        "Setting up Snowfall databases is a potentially destructive operation. Continue?",
        abort=True,
    )
    logger.info("Preparing to setup snowtuft")

    if not home.exists():
        return error("Invalid user specified for primary_user")

    try:
        with open("/etc/sysctl.conf", "w") as sysctl_file:
            lines = ["fs.file-max=17500", "vm.overcommit_memory = 1"]
            sysctl_file.write("\n".join(lines))
    except:
        pass

    with Popen(["sysctl", "-p"], env=os.environ, stdout=DEVNULL) as proc:
        proc.wait()

    if Path("/snowfall/docker/env_done").exists():
        logger.info("Existing docker setup found. Backing it up...")
        try:
            if backup:
                db_backup()
        except Exception as exc:
            logger.error(f"Backup failed. Error is {exc}")
            confirm("Continue? ", abort=True)

        with Popen(["systemctl", "stop", "snowfall-dbs"],
                   env=os.environ) as proc:
            proc.wait()

    logger.info("Removing/Renaming old files")

    def _rm_force(f_name):
        try:
            Path(f_name).unlink()
        except Exception:
            pass

    _rm_force("/etc/systemd/system/snowfall-dbs.service")

    if Path("/snowfall").exists():
        uid = str(uuid.uuid4())
        logger.info(f"Moving /snowfall to /snowfall.old/{uid}")
        Path("/snowfall.old").mkdir(exist_ok=True)
        Path("/snowfall").rename(f"/snowfall.old/{uid}")

    Path("/snowfall/docker/db/postgres").mkdir(parents=True)
    Path("/snowfall/docker/db/redis").mkdir(parents=True)

    pg_pwd = secrets.token_urlsafe()

    with open("/snowfall/docker/env.pg", "w") as env_pg:
        lines = [
            "POSTGRES_DB=fateslist",
            "POSTGRES_USER=fateslist",
            f"POSTGRES_PASSWORD={pg_pwd}",
        ]
        env_pg.write("\n".join(lines))

    shutil.copytree("data/docker/scripts",
                    "/snowfall/docker/scripts",
                    dirs_exist_ok=True)
    shutil.copy2("data/docker/config/docker-compose.yml",
                 "/snowfall/docker")

    logger.info("Starting up docker compose...")
    cmd = [
        "docker-compose", "-f", "/snowfall/docker/docker-compose.yml", "up",
        "-d"
    ]

    with Popen(cmd, env=os.environ) as proc:
        proc.wait()

    time.sleep(5)

    logger.info("Fixing postgres password. Do not worry if this fails")

    cmd = [
        "docker",
        "exec",
        "snowfall.postgres",
        "psql",
        "-U",
        "fateslist",
        "-d",
        "fateslist",
        "-c",
        f"ALTER USER fateslist WITH PASSWORD '{pg_pwd}'",
    ]

    with Popen(cmd, env=os.environ) as proc:
        proc.wait()

    for op in ("start", "stop"):
        script_path = Path(f"/usr/bin/snowfall-dbs-{op}")
        with script_path.open("w") as action_script:
            lines = [
                "#!/bin/bash",
                f"/usr/bin/docker {op} snowfall.postgres",
                f"/usr/bin/docker {op} snowfall.redis",
            ]
            action_script.write("\n".join(lines))

        script_path.chmod(755)

    with open("/etc/systemd/system/snowfall-dbs.service", "w") as sf_service:
        lines = [
            "[Unit]",
            "Description=Docker Compose Snowfall 2.0",
            "Requires=docker.service",
            "After=docker.service",
            "",
            "[Service]",
            "Type=oneshot",
            "RemainAfterExit=yes",
            "WorkingDirectory=/snowfall/docker",
            "ExecStart=/usr/bin/snowfall-dbs-start",
            "ExecStop=/usr/bin/snowfall-dbs-stop"
            "TimeoutStartSec=0",
            "",
            "[Install]",
            "WantedBy=multi-user.target",
        ]

        sf_service.write("\n".join(lines))

    cmds = (
        ["systemctl", "daemon-reload"],
        ["snowfall-dbs-stop"],
        ["systemctl", "start", "snowfall-dbs"],
        ["systemctl", "restart", "snowfall-dbs"],
    )

    for cmd in cmds:
        with Popen(cmd, env=os.environ) as proc:
            proc.wait()

    time.sleep(2)

    logger.info("Fixing up user env")

    with open("/snowfall/userenv", "w") as sf_userenv:
        lines = [
            "source /etc/profile",
            "export PGUSER=fateslist",
            "export PGHOST=localhost",
            "export PGPORT=1000",
            f"export PGPASSWORD='{pg_pwd}'",
            "export PGDATABASE=fateslist",
        ]

        sf_userenv.write("\n".join(lines))

    lines = [
        "source /snowfall/userenv",
    ]

    with Path(home / ".bashrc").open("a") as bashrc_f:
        bashrc_f.write("\n".join(lines))

    with open("/root/.bashrc", "w") as bashrc_f:
        bashrc_f.write("\n".join(lines))

    if Path("/backups/latest.bak").exists():
        logger.info("Restoring backup...")

        with open("/tmp/s2.bash", "w") as sf_s2_f:
            lines = [
                "source /snowfall/userenv",
                'psql -c "CREATE ROLE meow"',
                'psql -c "CREATE ROLE readaccess"',
                'psql -c "CREATE ROLE postgres"',
                'psql -c "CREATE ROLE root"',
                'psql -c "CREATE SCHEMA IF NOT EXISTS public"',
                "psql -c 'CREATE EXTENSION IF NOT EXISTS " + '"uuid-ossp"' +
                "'",
                "pg_restore -cvd fateslist /backups/latest.bak",
            ]
            sf_s2_f.write("\n".join(lines))

        with Popen(["bash", "/tmp/s2.bash"]) as proc:
            proc.wait()
    else:
        logger.info("No backup found. Creating new database... [UNTESTED!]")
        with open("/tmp/s3.bash", "w") as sf_s3_f:
            lines = [
                "source /snowfall/userenv",
                'psql -f "data/sql/schema.sql"'
            ]
            sf_s3_f.write("\n".join(lines))

        with Popen(["bash", "/tmp/s3.bash"]) as proc:
            proc.wait()

    Path("/snowfall/docker/env_done").touch()
    logger.info(f"Postgres password is {pg_pwd}")
    logger.success("Done setting up databases")
