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
	ErrStreakNotFound = errors.New("streak not found")
)

// StreakRepository handles streak database operations
type StreakRepository struct {
	db *pgxpool.Pool
}

// NewStreakRepository creates a new StreakRepository
func NewStreakRepository(db *pgxpool.Pool) *StreakRepository {
	return &StreakRepository{db: db}
}

// GetByHabitID retrieves a streak by habit ID
func (r *StreakRepository) GetByHabitID(ctx context.Context, habitID uuid.UUID) (*models.Streak, error) {
	query := `
		SELECT id, habit_id, user_id, current_streak, longest_streak,
			last_completed_date, updated_at
		FROM streaks
		WHERE habit_id = $1
	`

	streak := &models.Streak{}
	err := r.db.QueryRow(ctx, query, habitID).Scan(
		&streak.ID,
		&streak.HabitID,
		&streak.UserID,
		&streak.CurrentStreak,
		&streak.LongestStreak,
		&streak.LastCompletedDate,
		&streak.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrStreakNotFound
	}

	return streak, err
}

// Update updates a streak record
func (r *StreakRepository) Update(ctx context.Context, streak *models.Streak) error {
	query := `
		UPDATE streaks SET
			current_streak = $2,
			longest_streak = $3,
			last_completed_date = $4,
			updated_at = $5
		WHERE habit_id = $1
	`

	streak.UpdatedAt = time.Now()

	result, err := r.db.Exec(ctx, query,
		streak.HabitID,
		streak.CurrentStreak,
		streak.LongestStreak,
		streak.LastCompletedDate,
		streak.UpdatedAt,
	)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrStreakNotFound
	}

	return nil
}

// IncrementStreak increments the streak for a habit
func (r *StreakRepository) IncrementStreak(ctx context.Context, habitID uuid.UUID) error {
	query := `
		UPDATE streaks SET
			current_streak = current_streak + 1,
			longest_streak = GREATEST(longest_streak, current_streak + 1),
			last_completed_date = $2,
			updated_at = $2
		WHERE habit_id = $1
	`

	now := time.Now()
	result, err := r.db.Exec(ctx, query, habitID, now)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrStreakNotFound
	}

	return nil
}

// ResetStreak resets the current streak for a habit
func (r *StreakRepository) ResetStreak(ctx context.Context, habitID uuid.UUID) error {
	query := `
		UPDATE streaks SET
			current_streak = 0,
			updated_at = $2
		WHERE habit_id = $1
	`

	result, err := r.db.Exec(ctx, query, habitID, time.Now())

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrStreakNotFound
	}

	return nil
}

// GetUserStreaks retrieves all streaks for a user
func (r *StreakRepository) GetUserStreaks(ctx context.Context, userID uuid.UUID) ([]*models.Streak, error) {
	query := `
		SELECT s.id, s.habit_id, s.user_id, s.current_streak, s.longest_streak,
			s.last_completed_date, s.updated_at
		FROM streaks s
		JOIN habits h ON s.habit_id = h.id
		WHERE s.user_id = $1 AND h.deleted_at IS NULL AND h.is_active = true
		ORDER BY s.current_streak DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var streaks []*models.Streak
	for rows.Next() {
		streak := &models.Streak{}
		err := rows.Scan(
			&streak.ID,
			&streak.HabitID,
			&streak.UserID,
			&streak.CurrentStreak,
			&streak.LongestStreak,
			&streak.LastCompletedDate,
			&streak.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		streaks = append(streaks, streak)
	}

	return streaks, rows.Err()
}

// UpdateStreakAfterCompletion updates streak after completing a habit
// This handles the logic of checking if it's consecutive or needs reset
func (r *StreakRepository) UpdateStreakAfterCompletion(ctx context.Context, habitID uuid.UUID, completionDate time.Time) error {
	// Get current streak info
	streak, err := r.GetByHabitID(ctx, habitID)
	if err != nil {
		return err
	}

	completionDateOnly := completionDate.Truncate(24 * time.Hour)

	if streak.LastCompletedDate != nil {
		lastDate := streak.LastCompletedDate.Truncate(24 * time.Hour)
		daysDiff := int(completionDateOnly.Sub(lastDate).Hours() / 24)

		switch {
		case daysDiff == 0:
			// Same day, no change needed
			return nil
		case daysDiff == 1:
			// Consecutive day, increment streak
			streak.CurrentStreak++
		default:
			// Gap in streak, reset to 1
			streak.CurrentStreak = 1
		}
	} else {
		// First completion
		streak.CurrentStreak = 1
	}

	// Update longest streak if needed
	if streak.CurrentStreak > streak.LongestStreak {
		streak.LongestStreak = streak.CurrentStreak
	}

	streak.LastCompletedDate = &completionDateOnly

	return r.Update(ctx, streak)
}
