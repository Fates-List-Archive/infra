import json

async def apply(postgres, **_):
    bots = await postgres.fetch("SELECT website, discord, github, donate, privacy_policy, bot_id FROM bots")
    for bot in bots:
        hashm = {}
        if bot["website"]:
            hashm["Website"] = bot["website"]
        if bot["discord"]:
            hashm["Support"] = bot["discord"]
        if bot["github"]:
            hashm["Github"] = bot["github"]
        if bot["donate"]:
            hashm["Donate"] = bot["donate"]
        if bot["privacy_policy"]:
            hashm["Privacy"] = bot["privacy_policy"]
        print(hashm)
        await postgres.execute("UPDATE bots SET extra_links = $1 WHERE bot_id = $2", json.dumps(hashm), bot["bot_id"])
