package user

import "anto/internal/models"

type UserRepository interface {
	CreateUser(user *models.Users) error
}
