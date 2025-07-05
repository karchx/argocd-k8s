package user_test

import (
	"anto/internal/models"
	"anto/internal/store/user"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func TestCreateUser(t *testing.T) {
	mockDb, _, _ := sqlmock.New()

	dialector := postgres.New(postgres.Config{
		Conn:       mockDb,
		DriverName: "postgres",
	})

	db, _ := gorm.Open(dialector, &gorm.Config{})
	us := user.NewUserStore(db)
	us.CreateUser(&models.Users{
		Name:     "test",
		Username: "test_username",
		Password: "pass",
	})
}
