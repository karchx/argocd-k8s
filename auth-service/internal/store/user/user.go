package user

import (
	"anto/internal/models"

	"gorm.io/gorm"
)

type UserStore struct {
	db *gorm.DB
}

func NewUserStore(db *gorm.DB) *UserStore {
	return &UserStore{
		db: db,
	}
}

func (u *UserStore) CreateUser(user *models.Users) error {
	return u.db.Create(user).Error
}
