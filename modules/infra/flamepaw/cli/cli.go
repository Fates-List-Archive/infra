package cli

import (
	"context"
	"flamepaw/common"
	"flamepaw/tests"
	"flamepaw/uptime"
	"flamepaw/webserver"
	"io"
	"math/rand"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/bwmarrin/discordgo"
	"github.com/go-redis/redis/v8"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v4/pgxpool"
	log "github.com/sirupsen/logrus"
)

var (
	db      *pgxpool.Pool
	discord *discordgo.Session
	rdb     *redis.Client
	ctx     context.Context = context.Background()
	err     error
)

func CreateUUID() string {
	uuid, err := uuid.NewRandom()
	if err != nil || uuid.String() == "" {
		return CreateUUID()
	}
	return uuid.String()
}

func Test() {
	rPage := func() string {
		rand.Seed(time.Now().UnixNano())
		pageRand := strconv.Itoa(rand.Intn(7))
		return pageRand
	}

	logFile, err := os.OpenFile("modules/infra/flamepaw/_logs/dragon-"+CreateUUID(), os.O_RDWR|os.O_CREATE, 0600)
	if err != nil {
		log.Error(err)
	}
	defer logFile.Close()
	if err != nil {
		panic(err.Error())
	}

	mw := io.MultiWriter(os.Stdout, logFile)
	log.SetOutput(mw)

	// Tests
	tests.TestURLStatus("GET", "https://fateslist.xyz", 200)
	tests.TestURLStatus("GET", "https://fateslist.xyz/frostpaw/search?target_type=bot&q=mew", 200)
	tests.TestURLStatus("GET", "https://fateslist.xyz/frostpaw/search?target_type=server&q=mew", 200)
	tests.TestURLStatus("GET", "https://fateslist.xyz/mewbot", 200)
	tests.TestURLStatus("GET", "https://fateslist.xyz/furry", 200)
	tests.TestURLStatus("GET", "https://fateslist.xyz/_private", 404)
	tests.TestURLStatus("GET", "https://fateslist.xyz/frostpaw/tos", 200)
	tests.TestURLStatus("GET", "https://fateslist.xyz/frostpaw/thisshouldfail/maga2024", 404)
	tests.TestURLStatus("GET", "https://fateslist.xyz/bot/519850436899897346", 200)
	tests.TestURLStatus("GET", "https://api.fateslist.xyz/bots/0/random", 200)

	// Review html testing
	bots := []string{"519850436899897346", "101", "thisshouldfail", "1818181818188181818181818181"}
	var i int
	for i <= 10 {
		for _, bot := range bots {
			tests.TestURLStatus("GET", "https://api.fateslist.xyz/reviews/"+bot+"?target_type=0&page="+rPage(), 200, 404, 400, 422)
		}
		i += 1
	}
	log.Info("Result: " + strconv.Itoa(tests.TestsDone) + " tests done with " + strconv.Itoa(tests.TestsSuccess) + " successful")
}

func Server() {
	db, err = pgxpool.Connect(ctx, "")
	if err != nil {
		panic(err)
	}

	discord, err = discordgo.New("Bot " + common.MainBotToken)
	if err != nil {
		panic(err)
	}
	discord.SyncEvents = false

	discord.Identify.Intents = discordgo.IntentsGuilds | discordgo.IntentsGuildPresences | discordgo.IntentsGuildMembers

	// https://gist.github.com/ryanfitz/4191392
	onReady := func(s *discordgo.Session, m *discordgo.Ready) {
		log.Info("Logged in as ", m.User.Username)
		go func() {
			d := 5 * time.Minute
			uptime.UptimeFunc(ctx, db, discord, time.Now())
			for x := range time.Tick(d) {
				uptime.UptimeFunc(ctx, db, discord, x)
			}
		}()
	}

	discord.AddHandler(func(s *discordgo.Session, m *discordgo.GuildMemberAdd) {
		if common.IPCOnly {
			return
		}

		log.Info("New user found. Handling them...")

		if m.Member.GuildID == common.MainServer && m.Member.User.Bot {
			// Auto kick code. Minotaur handles autoroles and does it better than me
			_, err := s.State.Member(common.StaffServer, m.Member.User.ID)
			if err != nil {
				return
			}
			s.GuildMemberDeleteWithReason(common.StaffServer, m.Member.User.ID, "Done testing and invited to main server")
		}
	})

	discord.AddHandler(onReady)

	err = discord.Open()
	if err != nil {
		panic(err)
	}

	rdb = redis.NewClient(&redis.Options{
		Addr:     "localhost:1001",
		Password: "",
		DB:       1,
	})

	// Delete socket file
	if !common.IPCOnly {
		os.Remove("/home/meow/fatesws.sock")
	}

	// Channel for signal handling
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs,
		syscall.SIGINT,
		syscall.SIGQUIT)

	// Start IPC code
	if !common.RegisterCommands {
		if !common.IPCOnly {
			go webserver.StartWebserver(db, rdb, discord)
		}
	}
	s := <-sigs
	log.Info("Going to exit gracefully due to signal", s, "\n")

	// Close all connections
	db.Close()
	rdb.Close()
	discord.Close()

	os.Exit(0)
}
