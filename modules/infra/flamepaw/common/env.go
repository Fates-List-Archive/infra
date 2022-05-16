package common

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"runtime"

	jsoniter "github.com/json-iterator/go"
	log "github.com/sirupsen/logrus"
	"github.com/valyala/fastjson"
)

// Put all env variables here
const version = "2"

var json = jsoniter.ConfigCompatibleWithStandardLibrary

var (
	secretsJsonFile string
	discordJsonFile string
)

var (
	MainBotToken        string
	ClientSecret        string
	GHWebhookSecret     string
	MainServer          string
	StaffServer         string
	GithubChannel       string
	TestServerStaffRole string
	CliCmd              string
	RootPath            string
	PythonPath          string
	Debug               bool
	RegisterCommands    bool
	IPCOnly             bool
	NotifPubKey         string
	NotifPrivKey        string
)

func init() {
	flag.StringVar(&RootPath, "root", "/home/meow/FatesList", "Fates List source directory")
	flag.StringVar(&CliCmd, "cmd", "", "The command to run:\n\tserver: runs the ipc and ws server\n\ttest: runs the unit test system\n\tsite.XXX: run a site command (run=run site, compilestatic=compile static files).\n\tSet PYLOG_LEVEL to set loguru log level to debug")
	flag.StringVar(&PythonPath, "python-path", "/usr/bin/python", "Path to python interpreter")
	flag.BoolVar(&Debug, "debug", false, "Debug mode")
	flag.BoolVar(&RegisterCommands, "register-only", false, "Only register commands and exit! Overrides --cmd")
	flag.BoolVar(&IPCOnly, "ipc-only", false, "Whether or not this dragon server instance should be a ipc only instance")
	flag.Parse()

	secretsJsonFile = RootPath + "/config/data/secrets.json"
	discordJsonFile = RootPath + "/config/data/discord.json"

	if CliCmd == "" && !RegisterCommands && !IPCOnly {
		fmt.Println("Version:", version, "\nBuilt with:", runtime.Version())
		flag.Usage()
		os.Exit(3)
	} else if RegisterCommands || IPCOnly {
		CliCmd = "server"
	}

	err := os.Chdir(RootPath)

	if err != nil {
		panic(err)
	}

	var secretsJson, ferr = ioutil.ReadFile(secretsJsonFile)
	var discordJson, ferr2 = ioutil.ReadFile(discordJsonFile)
	if ferr != nil {
		panic(ferr.Error())
	} else if ferr2 != nil {
		panic(ferr2.Error())
	}

	MainBotToken = fastjson.GetString(secretsJson, "token_main")
	ClientSecret = fastjson.GetString(secretsJson, "client_secret")
	GHWebhookSecret = fastjson.GetString(secretsJson, "gh_webhook_secret")
	NotifPubKey = fastjson.GetString(secretsJson, "notif_public_key")
	NotifPrivKey = fastjson.GetString(secretsJson, "notif_private_key")

	var p fastjson.Parser

	v, err := p.Parse(string(discordJson))

	if err != nil {
		panic(err)
	}

	var servers = v.GetObject("servers")

	MainServer = string(servers.Get("main").GetStringBytes())
	StaffServer = string(servers.Get("staff").GetStringBytes())

	var channels = v.GetObject("channels")

	GithubChannel = string(channels.Get("github_channel").GetStringBytes())

	log.Info("Environment setup successfully!")
}
