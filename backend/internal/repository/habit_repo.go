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
	ErrHabitNotFound = errors.New("habit not found")
)

// HabitRepository handles habit database operations
type HabitRepository struct {
	db *pgxpool.Pool
}

// NewHabitRepository creates a new HabitRepository
func NewHabitRepository(db *pgxpool.Pool) *HabitRepository {
	return &HabitRepository{db: db}
}

// Create creates a new habit
func (r *HabitRepository) Create(ctx context.Context, habit *models.Habit) error {
	query := `
		INSERT INTO habits (
			id, user_id, title, description, category, frequency,
			is_active, is_learning_habit, color, icon, reminder_time,
			created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13
		)
	`

	habit.ID = uuid.New()
	habit.CreatedAt = time.Now()
	habit.UpdatedAt = time.Now()

	_, err := r.db.Exec(ctx, query,
		habit.ID,
		habit.UserID,
		habit.Title,
		habit.Description,
		habit.Category,
		habit.Frequency,
		habit.IsActive,
		habit.IsLearningHabit,
		habit.Color,
		habit.Icon,
		habit.ReminderTime,
		habit.CreatedAt,
		habit.UpdatedAt,
	)

	if err != nil {
		return err
	}

	// Create initial streak record
	streakQuery := `
		INSERT INTO streaks (id, habit_id, user_id, current_streak, longest_streak, updated_at)
		VALUES ($1, $2, $3, 0, 0, $4)
	`
	_, err = r.db.Exec(ctx, streakQuery, uuid.New(), habit.ID, habit.UserID, time.Now())

	return err
}

// GetByID retrieves a habit by ID
func (r *HabitRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.Habit, error) {
	query := `
		SELECT h.id, h.user_id, h.title, h.description, h.category, h.frequency,
			h.is_active, h.is_learning_habit, h.color, h.icon, h.reminder_time,
			h.created_at, h.updated_at, h.deleted_at,
			COALESCE(s.current_streak, 0), COALESCE(s.longest_streak, 0)
		FROM habits h
		LEFT JOIN streaks s ON h.id = s.habit_id
		WHERE h.id = $1 AND h.deleted_at IS NULL
	`

	habit := &models.Habit{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&habit.ID,
		&habit.UserID,
		&habit.Title,
		&habit.Description,
		&habit.Category,
		&habit.Frequency,
		&habit.IsActive,
		&habit.IsLearningHabit,
		&habit.Color,
		&habit.Icon,
		&habit.ReminderTime,
		&habit.CreatedAt,
		&habit.UpdatedAt,
		&habit.DeletedAt,
		&habit.CurrentStreak,
		&habit.LongestStreak,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrHabitNotFound
	}

	return habit, err
}

// GetByUserID retrieves all habits for a user
func (r *HabitRepository) GetByUserID(ctx context.Context, userID uuid.UUID) ([]*models.Habit, error) {
	query := `
		SELECT h.id, h.user_id, h.title, h.description, h.category, h.frequency,
			h.is_active, h.is_learning_habit, h.color, h.icon, h.reminder_time,
			h.created_at, h.updated_at, h.deleted_at,
			COALESCE(s.current_streak, 0), COALESCE(s.longest_streak, 0)
		FROM habits h
		LEFT JOIN streaks s ON h.id = s.habit_id
		WHERE h.user_id = $1 AND h.deleted_at IS NULL
		ORDER BY h.created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var habits []*models.Habit
	for rows.Next() {
		habit := &models.Habit{}
		err := rows.Scan(
			&habit.ID,
			&habit.UserID,
			&habit.Title,
			&habit.Description,
			&habit.Category,
			&habit.Frequency,
			&habit.IsActive,
			&habit.IsLearningHabit,
			&habit.Color,
			&habit.Icon,
			&habit.ReminderTime,
			&habit.CreatedAt,
			&habit.UpdatedAt,
			&habit.DeletedAt,
			&habit.CurrentStreak,
			&habit.LongestStreak,
		)
		if err != nil {
			return nil, err
		}
		habits = append(habits, habit)
	}

	return habits, rows.Err()
}

// GetActiveByUserID retrieves all active habits for a user
func (r *HabitRepository) GetActiveByUserID(ctx context.Context, userID uuid.UUID) ([]*models.Habit, error) {
	query := `
		SELECT h.id, h.user_id, h.title, h.description, h.category, h.frequency,
			h.is_active, h.is_learning_habit, h.color, h.icon, h.reminder_time,
			h.created_at, h.updated_at, h.deleted_at,
			COALESCE(s.current_streak, 0), COALESCE(s.longest_streak, 0)
		FROM habits h
		LEFT JOIN streaks s ON h.id = s.habit_id
		WHERE h.user_id = $1 AND h.is_active = true AND h.deleted_at IS NULL
		ORDER BY h.created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var habits []*models.Habit
	for rows.Next() {
		habit := &models.Habit{}
		err := rows.Scan(
			&habit.ID,
			&habit.UserID,
			&habit.Title,
			&habit.Description,
			&habit.Category,
			&habit.Frequency,
			&habit.IsActive,
			&habit.IsLearningHabit,
			&habit.Color,
			&habit.Icon,
			&habit.ReminderTime,
			&habit.CreatedAt,
			&habit.UpdatedAt,
			&habit.DeletedAt,
			&habit.CurrentStreak,
			&habit.LongestStreak,
		)
		if err != nil {
			return nil, err
		}
		habits = append(habits, habit)
	}

	return habits, rows.Err()
}

// Update updates a habit
func (r *HabitRepository) Update(ctx context.Context, habit *models.Habit) error {
	query := `
		UPDATE habits SET
			title = $2,
			description = $3,
			category = $4,
			frequency = $5,
			is_active = $6,
			is_learning_habit = $7,
			color = $8,
			icon = $9,
			reminder_time = $10,
			updated_at = $11
		WHERE id = $1 AND deleted_at IS NULL
	`

	habit.UpdatedAt = time.Now()

	result, err := r.db.Exec(ctx, query,
		habit.ID,
		habit.Title,
		habit.Description,
		habit.Category,
		habit.Frequency,
		habit.IsActive,
		habit.IsLearningHabit,
		habit.Color,
		habit.Icon,
		habit.ReminderTime,
		habit.UpdatedAt,
	)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrHabitNotFound
	}

	return nil
}

// SoftDelete soft deletes a habit
func (r *HabitRepository) SoftDelete(ctx context.Context, id uuid.UUID) error {
	query := `
		UPDATE habits SET deleted_at = $2, updated_at = $2
		WHERE id = $1 AND deleted_at IS NULL
	`

	now := time.Now()
	result, err := r.db.Exec(ctx, query, id, now)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrHabitNotFound
	}

	return nil
}

// GetByIDAndUserID retrieves a habit by ID and user ID (for authorization)
func (r *HabitRepository) GetByIDAndUserID(ctx context.Context, id, userID uuid.UUID) (*models.Habit, error) {
	query := `
		SELECT h.id, h.user_id, h.title, h.description, h.category, h.frequency,
			h.is_active, h.is_learning_habit, h.color, h.icon, h.reminder_time,
			h.created_at, h.updated_at, h.deleted_at,
			COALESCE(s.current_streak, 0), COALESCE(s.longest_streak, 0)
		FROM habits h
		LEFT JOIN streaks s ON h.id = s.habit_id
		WHERE h.id = $1 AND h.user_id = $2 AND h.deleted_at IS NULL
	`

	habit := &models.Habit{}
	err := r.db.QueryRow(ctx, query, id, userID).Scan(
		&habit.ID,
		&habit.UserID,
		&habit.Title,
		&habit.Description,
		&habit.Category,
		&habit.Frequency,
		&habit.IsActive,
		&habit.IsLearningHabit,
		&habit.Color,
		&habit.Icon,
		&habit.ReminderTime,
		&habit.CreatedAt,
		&habit.UpdatedAt,
		&habit.DeletedAt,
		&habit.CurrentStreak,
		&habit.LongestStreak,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrHabitNotFound
	}

	return habit, err
}

// GetUpdatedSince retrieves habits updated since a given time (for sync)
func (r *HabitRepository) GetUpdatedSince(ctx context.Context, userID uuid.UUID, since time.Time) ([]*models.Habit, error) {
	query := `
		SELECT h.id, h.user_id, h.title, h.description, h.category, h.frequency,
			h.is_active, h.is_learning_habit, h.color, h.icon, h.reminder_time,
			h.created_at, h.updated_at, h.deleted_at,
			COALESCE(s.current_streak, 0), COALESCE(s.longest_streak, 0)
		FROM habits h
		LEFT JOIN streaks s ON h.id = s.habit_id
		WHERE h.user_id = $1 AND h.updated_at > $2
		ORDER BY h.updated_at ASC
	`

	rows, err := r.db.Query(ctx, query, userID, since)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var habits []*models.Habit
	for rows.Next() {
		habit := &models.Habit{}
		err := rows.Scan(
			&habit.ID,
			&habit.UserID,
			&habit.Title,
			&habit.Description,
			&habit.Category,
			&habit.Frequency,
			&habit.IsActive,
			&habit.IsLearningHabit,
			&habit.Color,
			&habit.Icon,
			&habit.ReminderTime,
			&habit.CreatedAt,
			&habit.UpdatedAt,
			&habit.DeletedAt,
			&habit.CurrentStreak,
			&habit.LongestStreak,
		)
		if err != nil {
			return nil, err
		}
		habits = append(habits, habit)
	}

	return habits, rows.Err()
}
