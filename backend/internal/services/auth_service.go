package services

import (
	"context"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/config"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

var (
	ErrInvalidToken     = errors.New("invalid token")
	ErrTokenExpired     = errors.New("token expired")
	ErrUserNotFound     = errors.New("user not found")
	ErrInvalidFirebase  = errors.New("invalid firebase token")
)

// AuthService handles authentication logic
type AuthService struct {
	userRepo *repository.UserRepository
	config   *config.Config
}

// NewAuthService creates a new AuthService
func NewAuthService(userRepo *repository.UserRepository, cfg *config.Config) *AuthService {
	return &AuthService{
		userRepo: userRepo,
		config:   cfg,
	}
}

// JWTClaims represents JWT claims
type JWTClaims struct {
	UserID      uuid.UUID `json:"user_id"`
	FirebaseUID string    `json:"firebase_uid"`
	Email       string    `json:"email"`
	jwt.RegisteredClaims
}

// RegisterUser registers a new user after Firebase authentication
func (s *AuthService) RegisterUser(ctx context.Context, req *models.AuthRegisterRequest, firebaseUID string) (*models.AuthTokenResponse, error) {
	// Check if user already exists
	exists, err := s.userRepo.Exists(ctx, firebaseUID)
	if err != nil {
		return nil, err
	}

	var user *models.User
	if exists {
		// User exists, get their data
		user, err = s.userRepo.GetByFirebaseUID(ctx, firebaseUID)
		if err != nil {
			return nil, err
		}
	} else {
		// Create new user
		user = &models.User{
			FirebaseUID:         firebaseUID,
			Email:               req.Email,
			DisplayName:         req.DisplayName,
			Timezone:            "UTC",
			NotificationEnabled: true,
			MorningReminderTime: "06:00:00",
			EveningReminderTime: "21:00:00",
		}

		if err := s.userRepo.Create(ctx, user); err != nil {
			return nil, err
		}
	}

	// Generate tokens
	return s.generateTokenResponse(user)
}

// Login authenticates a user with Firebase token
func (s *AuthService) Login(ctx context.Context, firebaseUID string) (*models.AuthTokenResponse, error) {
	user, err := s.userRepo.GetByFirebaseUID(ctx, firebaseUID)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}

	return s.generateTokenResponse(user)
}

// RefreshToken refreshes the access token
func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string) (*models.AuthTokenResponse, error) {
	claims, err := s.ValidateToken(refreshToken)
	if err != nil {
		return nil, err
	}

	user, err := s.userRepo.GetByID(ctx, claims.UserID)
	if err != nil {
		return nil, err
	}

	return s.generateTokenResponse(user)
}

// ValidateToken validates a JWT token and returns claims
func (s *AuthService) ValidateToken(tokenString string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(s.config.JWTSecret), nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrTokenExpired
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*JWTClaims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

// GetUserFromToken extracts user from JWT token
func (s *AuthService) GetUserFromToken(ctx context.Context, tokenString string) (*models.User, error) {
	claims, err := s.ValidateToken(tokenString)
	if err != nil {
		return nil, err
	}

	return s.userRepo.GetByID(ctx, claims.UserID)
}

// generateTokenResponse generates access and refresh tokens
func (s *AuthService) generateTokenResponse(user *models.User) (*models.AuthTokenResponse, error) {
	accessToken, err := s.generateAccessToken(user)
	if err != nil {
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(user)
	if err != nil {
		return nil, err
	}

	return &models.AuthTokenResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int64(s.config.JWTExpiry.Seconds()),
		TokenType:    "Bearer",
		User:         user.ToResponse(),
	}, nil
}

// generateAccessToken generates an access token
func (s *AuthService) generateAccessToken(user *models.User) (string, error) {
	claims := &JWTClaims{
		UserID:      user.ID,
		FirebaseUID: user.FirebaseUID,
		Email:       user.Email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.config.JWTExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "habit-tracker",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.config.JWTSecret))
}

// generateRefreshToken generates a refresh token
func (s *AuthService) generateRefreshToken(user *models.User) (string, error) {
	claims := &JWTClaims{
		UserID:      user.ID,
		FirebaseUID: user.FirebaseUID,
		Email:       user.Email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.config.RefreshExpiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "habit-tracker-refresh",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.config.JWTSecret))
}

// UpdateFCMToken updates user's FCM token
func (s *AuthService) UpdateFCMToken(ctx context.Context, userID uuid.UUID, fcmToken string) error {
	return s.userRepo.UpdateFCMToken(ctx, userID, fcmToken)
}
