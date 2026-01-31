package repository

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrUserNotFound = errors.New("user not found")
	ErrUserExists   = errors.New("user already exists")
)

// UserRepository handles user database operations
type UserRepository struct {
	db *pgxpool.Pool
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(db *pgxpool.Pool) *UserRepository {
	return &UserRepository{db: db}
}

// Create creates a new user
func (r *UserRepository) Create(ctx context.Context, user *models.User) error {
	query := `
		INSERT INTO users (
			id, firebase_uid, email, display_name, avatar_url, xp, level, timezone,
			notification_enabled, morning_reminder_time, evening_reminder_time,
			fcm_token, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
		)
	`

	user.ID = uuid.New()
	user.CreatedAt = time.Now()
	user.UpdatedAt = time.Now()

	_, err := r.db.Exec(ctx, query,
		user.ID,
		user.FirebaseUID,
		user.Email,
		user.DisplayName,
		user.AvatarURL,
		user.XP,
		user.Level,
		user.Timezone,
		user.NotificationEnabled,
		user.MorningReminderTime,
		user.EveningReminderTime,
		user.FCMToken,
		user.CreatedAt,
		user.UpdatedAt,
	)

	return err
}

// GetByID retrieves a user by ID
func (r *UserRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	query := `
		SELECT id, firebase_uid, email, display_name, avatar_url, xp, level, timezone,
			notification_enabled, morning_reminder_time, evening_reminder_time,
			fcm_token, created_at, updated_at, deleted_at
		FROM users
		WHERE id = $1 AND deleted_at IS NULL
	`

	user := &models.User{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&user.ID,
		&user.FirebaseUID,
		&user.Email,
		&user.DisplayName,
		&user.AvatarURL,
		&user.XP,
		&user.Level,
		&user.Timezone,
		&user.NotificationEnabled,
		&user.MorningReminderTime,
		&user.EveningReminderTime,
		&user.FCMToken,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.DeletedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrUserNotFound
	}

	return user, err
}

// GetByFirebaseUID retrieves a user by Firebase UID
func (r *UserRepository) GetByFirebaseUID(ctx context.Context, firebaseUID string) (*models.User, error) {
	query := `
		SELECT id, firebase_uid, email, display_name, avatar_url, xp, level, timezone,
			notification_enabled, morning_reminder_time, evening_reminder_time,
			fcm_token, created_at, updated_at, deleted_at
		FROM users
		WHERE firebase_uid = $1 AND deleted_at IS NULL
	`

	user := &models.User{}
	err := r.db.QueryRow(ctx, query, firebaseUID).Scan(
		&user.ID,
		&user.FirebaseUID,
		&user.Email,
		&user.DisplayName,
		&user.AvatarURL,
		&user.XP,
		&user.Level,
		&user.Timezone,
		&user.NotificationEnabled,
		&user.MorningReminderTime,
		&user.EveningReminderTime,
		&user.FCMToken,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.DeletedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrUserNotFound
	}

	return user, err
}

// GetByEmail retrieves a user by email
func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*models.User, error) {
	query := `
		SELECT id, firebase_uid, email, display_name, avatar_url, xp, level, timezone,
			notification_enabled, morning_reminder_time, evening_reminder_time,
			fcm_token, created_at, updated_at, deleted_at
		FROM users
		WHERE email = $1 AND deleted_at IS NULL
	`

	user := &models.User{}
	err := r.db.QueryRow(ctx, query, email).Scan(
		&user.ID,
		&user.FirebaseUID,
		&user.Email,
		&user.DisplayName,
		&user.AvatarURL,
		&user.XP,
		&user.Level,
		&user.Timezone,
		&user.NotificationEnabled,
		&user.MorningReminderTime,
		&user.EveningReminderTime,
		&user.FCMToken,
		&user.CreatedAt,
		&user.UpdatedAt,
		&user.DeletedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrUserNotFound
	}

	return user, err
}

// Update updates a user
func (r *UserRepository) Update(ctx context.Context, user *models.User) error {
	query := `
		UPDATE users SET
			display_name = $2,
			avatar_url = $3,
			timezone = $4,
			notification_enabled = $5,
			morning_reminder_time = $6,
			evening_reminder_time = $7,
			fcm_token = $8,
			updated_at = $9
		WHERE id = $1 AND deleted_at IS NULL
	`

	user.UpdatedAt = time.Now()

	result, err := r.db.Exec(ctx, query,
		user.ID,
		user.DisplayName,
		user.AvatarURL,
		user.Timezone,
		user.NotificationEnabled,
		user.MorningReminderTime,
		user.EveningReminderTime,
		user.FCMToken,
		user.UpdatedAt,
	)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}

// UpdateFCMToken updates user's FCM token
func (r *UserRepository) UpdateFCMToken(ctx context.Context, userID uuid.UUID, fcmToken string) error {
	query := `
		UPDATE users SET fcm_token = $2, updated_at = $3
		WHERE id = $1 AND deleted_at IS NULL
	`

	result, err := r.db.Exec(ctx, query, userID, fcmToken, time.Now())
	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}

// SoftDelete soft deletes a user
func (r *UserRepository) SoftDelete(ctx context.Context, id uuid.UUID) error {
	query := `
		UPDATE users SET deleted_at = $2, updated_at = $2
		WHERE id = $1 AND deleted_at IS NULL
	`

	now := time.Now()
	result, err := r.db.Exec(ctx, query, id, now)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}

// Exists checks if a user exists by Firebase UID
func (r *UserRepository) Exists(ctx context.Context, firebaseUID string) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM users WHERE firebase_uid = $1 AND deleted_at IS NULL)`

	var exists bool
	err := r.db.QueryRow(ctx, query, firebaseUID).Scan(&exists)

	return exists, err
}
