package models

import (
	"time"

	"github.com/google/uuid"
)

// User represents a user in the system
type User struct {
	ID                  uuid.UUID  `json:"id"`
	FirebaseUID         string     `json:"firebase_uid"`
	Email               string     `json:"email"`
	DisplayName         *string    `json:"display_name,omitempty"`
	AvatarURL           *string    `json:"avatar_url,omitempty"`
	XP                  int        `json:"xp"`
	Level               int        `json:"level"`
	Timezone            string     `json:"timezone"`
	NotificationEnabled bool       `json:"notification_enabled"`
	MorningReminderTime string     `json:"morning_reminder_time"`
	EveningReminderTime string     `json:"evening_reminder_time"`
	FCMToken            *string    `json:"fcm_token,omitempty"`
	CreatedAt           time.Time  `json:"created_at"`
	UpdatedAt           time.Time  `json:"updated_at"`
	DeletedAt           *time.Time `json:"deleted_at,omitempty"`
}

// UserCreateRequest represents the request body for creating a user
type UserCreateRequest struct {
	FirebaseUID string  `json:"firebase_uid" binding:"required"`
	Email       string  `json:"email" binding:"required,email"`
	DisplayName *string `json:"display_name,omitempty"`
}

// UserUpdateRequest represents the request body for updating a user
type UserUpdateRequest struct {
	DisplayName         *string `json:"display_name,omitempty"`
	Timezone            *string `json:"timezone,omitempty"`
	NotificationEnabled *bool   `json:"notification_enabled,omitempty"`
	MorningReminderTime *string `json:"morning_reminder_time,omitempty"`
	EveningReminderTime *string `json:"evening_reminder_time,omitempty"`
}

// UserSettingsRequest represents notification settings update
type UserSettingsRequest struct {
	NotificationEnabled *bool   `json:"notification_enabled,omitempty"`
	MorningReminderTime *string `json:"morning_reminder_time,omitempty"`
	EveningReminderTime *string `json:"evening_reminder_time,omitempty"`
	FCMToken            *string `json:"fcm_token,omitempty"`
}

// UserResponse is the API response for user data
type UserResponse struct {
	ID                  uuid.UUID `json:"id"`
	Email               string    `json:"email"`
	DisplayName         *string   `json:"display_name,omitempty"`
	AvatarURL           *string   `json:"avatar_url,omitempty"`
	XP                  int       `json:"xp"`
	Level               int       `json:"level"`
	Timezone            string    `json:"timezone"`
	NotificationEnabled bool      `json:"notification_enabled"`
	MorningReminderTime string    `json:"morning_reminder_time"`
	EveningReminderTime string    `json:"evening_reminder_time"`
	CreatedAt           time.Time `json:"created_at"`
}

// ToResponse converts User to UserResponse
func (u *User) ToResponse() *UserResponse {
	return &UserResponse{
		ID:                  u.ID,
		Email:               u.Email,
		DisplayName:         u.DisplayName,
		AvatarURL:           u.AvatarURL,
		XP:                  u.XP,
		Level:               u.Level,
		Timezone:            u.Timezone,
		NotificationEnabled: u.NotificationEnabled,
		MorningReminderTime: u.MorningReminderTime,
		EveningReminderTime: u.EveningReminderTime,
		CreatedAt:           u.CreatedAt,
	}
}
