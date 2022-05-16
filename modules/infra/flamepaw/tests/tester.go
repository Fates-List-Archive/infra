package tests

import (
	"net/http"
	"strconv"
	"time"

	log "github.com/sirupsen/logrus"
)

var TestsDone int
var TestsSuccess int

// Simple command tester
func TestURLStatus(method string, url string, statusCode ...int) bool {
	log.Info("Testing " + url + " with method " + method)
	TestsDone += 1
	client := http.Client{Timeout: 15 * time.Second}
	var resp *http.Response
	var err error

	if method == "GET" {
		resp, err = client.Get(url)
	} else if method == "HEAD" {
		resp, err = client.Head(url)
	} else {
		log.Error("FAIL: Invalid method " + method + " in test for URL " + url)
		return false
	}

	if err != nil {
		log.Error("FAIL: " + err.Error())
		return false
	}

	if resp.StatusCode == 408 {
		log.Error("FAIL: Got maintainance page")
		return false
	}

	var checkPassed = false
	var codes = ""
	var no5xx = false
	for i, code := range statusCode {
		if resp.StatusCode == code || code == 0 {
			checkPassed = true
		} else if code == 0 {
			no5xx = true
		}
		if i == 0 {
			codes += strconv.Itoa(code)
		} else {
			codes = codes + "/" + strconv.Itoa(code)
		}
	}

	if !checkPassed {
		log.Error("FAIL: Expected status code " + codes + " but got status code " + strconv.Itoa(resp.StatusCode))
		return false
	}

	if no5xx && resp.StatusCode >= 500 {
		log.Error("FAIL: Got 5xx error: " + strconv.Itoa(resp.StatusCode))
		return false
	}

	log.Info("PASS: With status code " + strconv.Itoa(resp.StatusCode))
	TestsSuccess += 1
	return true
}
