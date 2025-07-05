package database

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Config struct {
	DB *gorm.DB
}

func New(dsn string) (*Config, error) {
	dial := postgres.Open(dsn)

	db, err := gorm.Open(dial, &gorm.Config{}) // add logger
	if err != nil {
		return nil, err
	}
	return &Config{
		DB: db,
	}, nil
}

func (c *Config) AutoMigrate(models ...any) {
	c.DB.AutoMigrate(models...)
}
