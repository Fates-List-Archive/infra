package main

import (
	"flamepaw/cli"
	"flamepaw/common"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"

	log "github.com/sirupsen/logrus"
)

func main() {
	lvl, ok := os.LookupEnv("LOG_LEVEL")
	if !ok {
		lvl = "debug"
	}
	ll, err := log.ParseLevel(lvl)
	if err != nil {
		ll = log.DebugLevel
	}
	log.SetLevel(ll)

	if common.CliCmd == "server" {
		cli.Server()
	} else if common.CliCmd == "test" {
		cli.Test()
	} else {
		cmdFunc := strings.Replace(common.CliCmd, ".", "_", -1)
		pyCmd := "from modules.core._manage import " + cmdFunc + "; " + cmdFunc + "()"
		log.Info("Running " + common.PythonPath + " -c '" + pyCmd + "'")
		os.Setenv("MAIN_TOKEN", common.MainBotToken)
		os.Setenv("CLIENT_SECRET", common.ClientSecret)
		os.Setenv("PYTHONPYCACHEPREFIX", common.RootPath+"/data/pycache")
		if os.Getenv("PYLOG_LEVEL") != "debug" {
			os.Setenv("LOGURU_LEVEL", "INFO")
		}
		devserver := exec.Command(common.PythonPath, "-c", pyCmd)

		if common.CliCmd == "db.setup" {
			log.Info("Applying stdin patch")
			userInput := make(chan string)
			go readInput(userInput)
			stdin, err := devserver.StdinPipe()
			if err != nil {
				log.Fatal(err)
			}
			go func() {
				defer stdin.Close()
				io.WriteString(stdin, <-userInput)
			}()
		}
		devserver.Dir = common.RootPath
		devserver.Env = os.Environ()
		devserver.Stdout = os.Stdout
		devserver.Stderr = os.Stderr
		devserver.Run()
	}
	os.Exit(0)
}

// STDIN patch
func readInput(input chan<- string) {
	for {
		var u string
		_, err := fmt.Scanf("%s\n", &u)
		if err != nil {
			panic(err)
		}
		input <- u
	}
}
