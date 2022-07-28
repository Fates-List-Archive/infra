// Based on https://github.com/gorilla/websocket/blob/master/examples/chat/main.go

// Copyright 2013 The Gorilla WebSocket Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package webserver

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"flamepaw/common"
	"flamepaw/types"
	"flamepaw/uptime"
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"

	jsoniter "github.com/json-iterator/go"

	"github.com/bwmarrin/discordgo"
	"github.com/davecgh/go-spew/spew"
	"github.com/gin-gonic/gin"
	ginlogrus "github.com/toorop/gin-logrus"

	"github.com/go-redis/redis/v8"
	"github.com/jackc/pgx/v4/pgxpool"
	log "github.com/sirupsen/logrus"

	webpush "github.com/SherClockHolmes/webpush-go"
)

var (
	json   = jsoniter.ConfigCompatibleWithStandardLibrary
	logger = log.New()
)

// API return
func apiReturn(c *gin.Context, statusCode int, done bool, reason interface{}, context interface{}) {
	if reason == "EOF" {
		reason = "Request body required"
	}

	if reason == "" {
		reason = nil
	}

	var ret = gin.H{"done": done, "reason": reason}
	if context != nil {
		ret["ctx"] = context
	}
	c.Header("Content-Type", "application/json")
	body, err := json.MarshalToString(ret)
	if err != nil {
		body, _ = json.MarshalToString(gin.H{"done": false, "reason": "Internal server error: " + err.Error()})
		statusCode = 500
	}
	c.String(statusCode, body)
}

func StartWebserver(db *pgxpool.Pool, redis *redis.Client, discord *discordgo.Session) {
	gin.SetMode(gin.ReleaseMode)

	r := gin.New()

	r.Use(ginlogrus.Logger(logger), gin.Recovery())

	r.NoRoute(func(c *gin.Context) {
		apiReturn(c, 404, false, "Not Found", nil)
	})
	router := r.Group("/flamepaw")

	router.GET("/ping", func(c *gin.Context) {
		apiReturn(c, 200, true, nil, nil)
	})

	router.GET("/_uptime", func(c *gin.Context) {
		c.JSON(200, uptime.Uptime)
	})

	router.POST("/_remind", func(c *gin.Context) {
		if c.Request.Header.Get("X-Forwarded-For") != "" {
			apiReturn(c, 404, false, "Not Found", nil)
			return
		}

		var vapid types.VAPID

		err := c.ShouldBindJSON(&vapid)

		if err != nil {
			apiReturn(c, 400, false, err.Error(), nil)
			return
		}

		sub := webpush.Subscription{
			Endpoint: vapid.Endpoint,
			Keys: webpush.Keys{
				Auth:   vapid.Auth,
				P256dh: vapid.P256dh,
			},
		}

		// Send Notification
		resp, err := webpush.SendNotification([]byte(vapid.Data), &sub, &webpush.Options{
			Subscriber:      "sandhoners123@gmail.com",
			VAPIDPublicKey:  common.NotifPubKey,
			VAPIDPrivateKey: common.NotifPrivKey,
			TTL:             30,
		})
		if err != nil {
			// TODO: Handle error
			apiReturn(c, 400, false, err.Error(), nil)
		}
		defer resp.Body.Close()
		msg, _ := ioutil.ReadAll(resp.Body)
		log.Info(resp.StatusCode, msg)
		apiReturn(c, 200, false, "", nil)
	})

	router.POST("/github", func(c *gin.Context) {
		var bodyBytes []byte
		if c.Request.Body != nil {
			bodyBytes, _ = ioutil.ReadAll(c.Request.Body)
		}

		// Restore the io.ReadCloser to its original state
		c.Request.Body = ioutil.NopCloser(bytes.NewBuffer(bodyBytes))

		var signature = c.Request.Header.Get("X-Hub-Signature-256")

		mac := hmac.New(sha256.New, []byte(common.GHWebhookSecret))
		mac.Write([]byte(bodyBytes))
		expected := hex.EncodeToString(mac.Sum(nil))

		if "sha256="+expected != signature {
			log.Error(expected + " " + signature + " ")
			apiReturn(c, 401, false, "Invalid signature", nil)
			return
		}

		var gh types.GithubWebhook
		err := c.BindJSON(&gh)
		if err != nil {
			log.Error(err)
			apiReturn(c, 422, false, err.Error(), nil)
			return
		}

		var header = c.Request.Header.Get("X-GitHub-Event")

		var messageSend discordgo.MessageSend

		if header == "push" {
			var commitList string
			for _, commit := range gh.Commits {
				commitList += fmt.Sprintf("%s [%s](%s) | [%s](%s)\n", commit.Message, commit.ID[:7], commit.URL, commit.Author.Username, "https://github.com/"+commit.Author.Username)
			}

			messageSend = discordgo.MessageSend{
				Embeds: []*discordgo.MessageEmbed{
					{
						Color: 0x00ff1a,
						URL:   gh.Repo.URL,
						Author: &discordgo.MessageEmbedAuthor{
							Name:    gh.Sender.Login,
							IconURL: gh.Sender.AvatarURL,
						},
						Title: "Push on " + gh.Repo.FullName,
						Fields: []*discordgo.MessageEmbedField{
							{
								Name:  "Branch",
								Value: "**Ref:** " + gh.Ref + "\n" + "**Base Ref:** " + gh.BaseRef,
							},
							{
								Name:  "Commits",
								Value: commitList,
							},
							{
								Name:  "Pusher",
								Value: fmt.Sprintf("[%s](%s)", gh.Pusher.Name, "https://github.com/"+gh.Pusher.Name),
							},
						},
					},
				},
			}
		} else if header == "star" {
			var color int
			var title string
			if gh.Action == "created" {
				color = 0x00ff1a
				title = "Starred: " + gh.Repo.FullName
			} else {
				color = 0xff0000
				title = "Unstarred: " + gh.Repo.FullName
			}
			messageSend = discordgo.MessageSend{
				Embeds: []*discordgo.MessageEmbed{
					{
						Color: color,
						URL:   gh.Repo.URL,
						Title: title,
						Fields: []*discordgo.MessageEmbedField{
							{
								Name:  "User",
								Value: "[" + gh.Sender.Login + "]" + "(" + gh.Sender.HTMLURL + ")",
							},
						},
					},
				},
			}
		} else if header == "issues" {
			var body string = gh.Issue.Body
			if len(gh.Issue.Body) > 1000 {
				body = gh.Issue.Body[:1000]
			}

			if body == "" {
				body = "No description available"
			}

			var color int
			if gh.Action == "deleted" || gh.Action == "unpinned" {
				color = 0xff0000
			} else {
				color = 0x00ff1a
			}

			messageSend = discordgo.MessageSend{
				Embeds: []*discordgo.MessageEmbed{
					{
						Color: color,
						URL:   gh.Issue.HTMLURL,
						Author: &discordgo.MessageEmbedAuthor{
							Name:    gh.Sender.Login,
							IconURL: gh.Sender.AvatarURL,
						},
						Title: fmt.Sprintf("Issue %s on %s (#%d)", gh.Action, gh.Repo.FullName, gh.Issue.Number),
						Fields: []*discordgo.MessageEmbedField{
							{
								Name:  "Action",
								Value: gh.Action,
							},
							{
								Name:  "User",
								Value: fmt.Sprintf("[%s](%s)", gh.Sender.Login, gh.Sender.HTMLURL),
							},
							{
								Name:  "Title",
								Value: gh.Issue.Title,
							},
							{
								Name:  "Body",
								Value: body,
							},
						},
					},
				},
			}
		} else if header == "pull_request" {
			var body string = gh.PullRequest.Body
			if len(gh.PullRequest.Body) > 1000 {
				body = gh.PullRequest.Body[:1000]
			}

			if body == "" {
				body = "No description available"
			}

			var color int
			if gh.Action == "closed" {
				color = 0xff0000
			} else {
				color = 0x00ff1a
			}

			messageSend = discordgo.MessageSend{
				Embeds: []*discordgo.MessageEmbed{
					{
						Color: color,
						URL:   gh.PullRequest.HTMLURL,
						Author: &discordgo.MessageEmbedAuthor{
							Name:    gh.Sender.Login,
							IconURL: gh.Sender.AvatarURL,
						},
						Title: fmt.Sprintf("Pull Request %s on %s (#%d)", gh.Action, gh.Repo.FullName, gh.PullRequest.Number),
						Fields: []*discordgo.MessageEmbedField{
							{
								Name:  "Action",
								Value: gh.Action,
							},
							{
								Name:  "User",
								Value: fmt.Sprintf("[%s](%s)", gh.Sender.Login, gh.Sender.HTMLURL),
							},
							{
								Name:  "Title",
								Value: gh.PullRequest.Title,
							},
							{
								Name:  "Body",
								Value: body,
							},
							{
								Name:  "More Information",
								Value: fmt.Sprintf("**Base Ref:** %s\n**Base Label:** %s\n**Head Ref:** %s\n**Head Label:** %s", gh.PullRequest.Base.Ref, gh.PullRequest.Base.Label, gh.PullRequest.Head.Ref, gh.PullRequest.Head.Label),
							},
						},
					},
				},
			}
		} else if header == "issue_comment" {
			var body string = gh.Issue.Body
			if len(gh.Issue.Body) > 1000 {
				body = gh.Issue.Body[:1000]
			}

			if body == "" {
				body = "No description available"
			}

			var color int
			if gh.Action == "deleted" {
				color = 0xff0000
			} else {
				color = 0x00ff1a
			}

			messageSend = discordgo.MessageSend{
				Embeds: []*discordgo.MessageEmbed{
					{
						Color: color,
						URL:   gh.Issue.HTMLURL,
						Author: &discordgo.MessageEmbedAuthor{
							Name:    gh.Sender.Login,
							IconURL: gh.Sender.AvatarURL,
						},
						Title: fmt.Sprintf("Comment on %s (#%d) %s", gh.Repo.FullName, gh.Issue.Number, gh.Action),
						Fields: []*discordgo.MessageEmbedField{
							{
								Name:  "User",
								Value: fmt.Sprintf("[%s](%s)", gh.Sender.Login, gh.Sender.HTMLURL),
							},
							{
								Name:  "Title",
								Value: gh.Issue.Title,
							},
							{
								Name:  "Body",
								Value: body,
							},
						},
					},
				},
			}
		} else if header == "pull_request_review_comment" {
			var body string = gh.PullRequest.Body
			if len(gh.PullRequest.Body) > 1000 {
				body = gh.PullRequest.Body[:1000]
			}

			if body == "" {
				body = "No description available"
			}

			var color int
			if gh.Action == "deleted" {
				color = 0xff0000
			} else {
				color = 0x00ff1a
			}

			messageSend = discordgo.MessageSend{
				Embeds: []*discordgo.MessageEmbed{
					{
						Color: color,
						URL:   gh.PullRequest.HTMLURL,
						Author: &discordgo.MessageEmbedAuthor{
							Name:    gh.Sender.Login,
							IconURL: gh.Sender.AvatarURL,
						},
						Title: "Pull Request Review Comment on " + gh.Repo.FullName + " (#" + strconv.Itoa(gh.PullRequest.Number) + ")",
						Fields: []*discordgo.MessageEmbedField{
							{
								Name:  "User",
								Value: fmt.Sprintf("[%s](%s)", gh.Sender.Login, gh.Sender.HTMLURL),
							},
							{
								Name:  "Title",
								Value: gh.PullRequest.Title,
							},
							{
								Name:  "Body",
								Value: body,
							},
						},
					},
				},
			}
		} else {
			messageSend = discordgo.MessageSend{
				Content: "**Action: " + header + "**",
				TTS:     false,
				File: &discordgo.File{
					Name:        "gh-event.txt",
					ContentType: "application/octet-stream",
					Reader:      strings.NewReader(spew.Sdump(gh)),
				},
			}
		}

		_, err = discord.ChannelMessageSendComplex(common.GithubChannel, &messageSend)

		if err != nil {
			log.Error(err)
			apiReturn(c, 400, false, "Error sending message: "+err.Error(), nil)
			return
		}

		apiReturn(c, 200, true, nil, nil)
	})

	err := r.Run("127.0.0.1:1293")
	if err != nil {
		log.Fatal("could not start listening: ", err)
		return
	}
}
