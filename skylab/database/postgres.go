package database

import (
	"fmt"

	log "github.com/gothew/l-og"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type PostgresConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	DBName   string
	Env      string
	db       *gorm.DB
}

func NewPostgresConfig(host, password, dbName, user, env string, port int) *PostgresConfig {
	return &PostgresConfig{
		Host:     host,
		Port:     port,
		User:     user,
		Password: password,
		DBName:   dbName,
		Env:      env,
	}
}

func (cfg *PostgresConfig) connectionString() string {
	return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s",
		cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.DBName,
	)
}

func (cfg *PostgresConfig) connectionStringMigration() string {
	return fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=disable",
		cfg.User, cfg.Password, cfg.Host, cfg.Port, cfg.DBName,
	)
}

func (cfg *PostgresConfig) ConnectDB() (gorm.DB, error) {
	db, err := gorm.Open(postgres.New(postgres.Config{
		DSN: cfg.connectionString(),
	}), &gorm.Config{})

	if err != nil {
		return gorm.DB{}, err
	}
	cfg.db = db
	return *db, nil
}

func (cfg *PostgresConfig) Migrate(models ...any) error {
	if cfg.Env == "production" {
		postgresConnStr := cfg.connectionStringMigration()
		log.Infof("Please run migrations migrate -database %s -path database/migrations up", postgresConnStr)
		return nil
	}
	err := cfg.db.AutoMigrate(models...)
	dropUnusedColumns(cfg.db, models...)
	return err
}

func dropUnusedColumns(db *gorm.DB, dst ...any) {
	stmt := &gorm.Statement{DB: db}
	for _, d := range dst {
		stmt.Parse(d)
		fields := stmt.Schema.Fields
		columns, _ := db.Migrator().ColumnTypes(d)

		for _, column := range columns {
			found := false
			for j := range fields {
				if column.Name() == fields[j].DBName {
					found = true
					break
				}
			}
			if !found {
				log.Infof("Dropping column %s from table %s", column.Name(), stmt.Table)
				db.Migrator().DropColumn(d, column.Name())
			}
		}
	}
}
