package main

import (
	"context"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	log "github.com/gothew/l-og"
	"github.com/joho/godotenv"
	"github.com/karchx/skylab/database"
)

type Server struct {
	Port   string
	router *http.ServeMux
}

func NewServer(port string) *Server {
	router := http.NewServeMux()
	return &Server{
		Port:   port,
		router: router,
	}
}

func (s *Server) Run() *http.Server {
	srv := &http.Server{
		Addr:    s.Port,
		Handler: s.router,
	}
	log.Infof("Server is running at :%s/", s.Port)
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()
	return srv
}

func loadEnv() {
	if err := godotenv.Load(); err != nil {
		log.Warn("No .env file found, relying on environment variables")
	}
}

func main() {
	loadEnv()
	dbport, err := strconv.Atoi(os.Getenv("DB_PORT"))
	if err != nil {
		log.Warnf("Invalid PORT value, defaulting to 3000: %v", err)
		dbport = 5432
	}
	postgres := database.NewPostgresConfig(
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_USER"),
		os.Getenv("ENV"),
		dbport,
	)
	db, err := postgres.ConnectDB()
	if err != nil {
		panic(err)
	}
	log.Infof("Database connect successfully %s", db.Name())
	postgres.Migrate()

	srv := NewServer(":" + os.Getenv("PORT"))
	srvRoutine := srv.Run()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Info("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srvRoutine.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}
}
