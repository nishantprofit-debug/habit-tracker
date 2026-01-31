package models

import (
	"time"

	"github.com/google/uuid"
)

// AuthRegisterRequest represents the registration request
type AuthRegisterRequest struct {
	FirebaseToken string  `json:"firebase_token" binding:"required"`
	Email         string  `json:"email" binding:"required,email"`
	DisplayName   *string `json:"display_name,omitempty"`
}

// AuthLoginRequest represents the login request
type AuthLoginRequest struct {
	FirebaseToken string `json:"firebase_token" binding:"required"`
}

// AuthRefreshRequest represents the token refresh request
type AuthRefreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// AuthTokenResponse represents the authentication response with tokens
type AuthTokenResponse struct {
	AccessToken  string        `json:"access_token"`
	RefreshToken string        `json:"refresh_token"`
	ExpiresIn    int64         `json:"expires_in"`
	TokenType    string        `json:"token_type"`
	User         *UserResponse `json:"user"`
}

// FCMTokenUpdateRequest represents the FCM token update request
type FCMTokenUpdateRequest struct {
	FCMToken string `json:"fcm_token" binding:"required"`
}

// TokenClaims represents JWT token claims
type TokenClaims struct {
	UserID      uuid.UUID `json:"user_id"`
	FirebaseUID string    `json:"firebase_uid"`
	Email       string    `json:"email"`
	ExpiresAt   time.Time `json:"exp"`
	IssuedAt    time.Time `json:"iat"`
}

// PasswordResetRequest represents password reset request
type PasswordResetRequest struct {
	Email string `json:"email" binding:"required,email"`
}

// PasswordResetConfirmRequest represents password reset confirmation
type PasswordResetConfirmRequest struct {
	Token       string `json:"token" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=8"`
}
