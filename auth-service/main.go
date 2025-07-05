package main

import (
	"anto/internal/database"
	"anto/internal/models"
	"fmt"
	"os"

	"github.com/gin-gonic/gin"
	log "github.com/gothew/l-og"
	"github.com/joho/godotenv"
)

func main() {
	loadEnv()
	r := gin.Default()
	dataSourceName := fmt.Sprintf("host=%s port=%s user=%s dbname=%s sslmode=disable password=%s",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_DATABASE"),
		os.Getenv("DB_PASSWORD"),
	)
	db, err := database.New(dataSourceName)
	if err != nil {
		log.Errorf("Error connection database %s", err)
	}
	db.AutoMigrate(&models.Users{})

	err = r.Run(fmt.Sprintf(":%s", os.Getenv("PORT")))
	if err != nil {
		log.Errorf("Error run server %s", err)
		panic(err)
	}
}

func loadEnv() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatalf("Error loading .env file")
	}
}
