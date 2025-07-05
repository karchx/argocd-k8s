package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Users struct {
	ID       uuid.UUID `gorm:"type:uuid;default:uuid_generate_v4()"`
	Name     string    `gorm:"size:255"`
	Username string    `gorm:"size:255;uniqueIndex;not null"`
	Password string    `gorm:"size:255;not null"`
	gorm.Model
}
