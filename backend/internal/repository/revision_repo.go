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
	ErrRevisionNotFound = errors.New("revision habit not found")
)

// RevisionRepository handles revision habit database operations
type RevisionRepository struct {
	db *pgxpool.Pool
}

// NewRevisionRepository creates a new RevisionRepository
func NewRevisionRepository(db *pgxpool.Pool) *RevisionRepository {
	return &RevisionRepository{db: db}
}

// Create creates a new revision habit
func (r *RevisionRepository) Create(ctx context.Context, revision *models.RevisionHabit) error {
	query := `
		INSERT INTO revision_habits (
			id, user_id, original_skill, source_month, duration_days,
			daily_duration_minutes, status, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9
		)
	`

	revision.ID = uuid.New()
	revision.CreatedAt = time.Now()
	revision.UpdatedAt = time.Now()

	_, err := r.db.Exec(ctx, query,
		revision.ID,
		revision.UserID,
		revision.OriginalSkill,
		revision.SourceMonth,
		revision.DurationDays,
		revision.DailyDurationMinutes,
		revision.Status,
		revision.CreatedAt,
		revision.UpdatedAt,
	)

	return err
}

// GetByID retrieves a revision habit by ID
func (r *RevisionRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.RevisionHabit, error) {
	query := `
		SELECT id, user_id, original_skill, source_month, duration_days,
			daily_duration_minutes, status, created_at, updated_at
		FROM revision_habits
		WHERE id = $1
	`

	revision := &models.RevisionHabit{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&revision.ID,
		&revision.UserID,
		&revision.OriginalSkill,
		&revision.SourceMonth,
		&revision.DurationDays,
		&revision.DailyDurationMinutes,
		&revision.Status,
		&revision.CreatedAt,
		&revision.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrRevisionNotFound
	}

	return revision, err
}

// GetByUser retrieves all revision habits for a user
func (r *RevisionRepository) GetByUser(ctx context.Context, userID uuid.UUID) ([]*models.RevisionHabit, error) {
	query := `
		SELECT id, user_id, original_skill, source_month, duration_days,
			daily_duration_minutes, status, created_at, updated_at
		FROM revision_habits
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var revisions []*models.RevisionHabit
	for rows.Next() {
		revision := &models.RevisionHabit{}
		err := rows.Scan(
			&revision.ID,
			&revision.UserID,
			&revision.OriginalSkill,
			&revision.SourceMonth,
			&revision.DurationDays,
			&revision.DailyDurationMinutes,
			&revision.Status,
			&revision.CreatedAt,
			&revision.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		revisions = append(revisions, revision)
	}

	return revisions, rows.Err()
}

// GetPendingByUser retrieves pending revision habits for a user
func (r *RevisionRepository) GetPendingByUser(ctx context.Context, userID uuid.UUID) ([]*models.RevisionHabit, error) {
	query := `
		SELECT id, user_id, original_skill, source_month, duration_days,
			daily_duration_minutes, status, created_at, updated_at
		FROM revision_habits
		WHERE user_id = $1 AND status = 'pending'
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var revisions []*models.RevisionHabit
	for rows.Next() {
		revision := &models.RevisionHabit{}
		err := rows.Scan(
			&revision.ID,
			&revision.UserID,
			&revision.OriginalSkill,
			&revision.SourceMonth,
			&revision.DurationDays,
			&revision.DailyDurationMinutes,
			&revision.Status,
			&revision.CreatedAt,
			&revision.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		revisions = append(revisions, revision)
	}

	return revisions, rows.Err()
}

// UpdateStatus updates the status of a revision habit
func (r *RevisionRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status models.RevisionStatus) error {
	query := `
		UPDATE revision_habits SET status = $2, updated_at = $3
		WHERE id = $1
	`

	result, err := r.db.Exec(ctx, query, id, status, time.Now())

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrRevisionNotFound
	}

	return nil
}

// GetByIDAndUserID retrieves a revision habit by ID and user ID (for authorization)
func (r *RevisionRepository) GetByIDAndUserID(ctx context.Context, id, userID uuid.UUID) (*models.RevisionHabit, error) {
	query := `
		SELECT id, user_id, original_skill, source_month, duration_days,
			daily_duration_minutes, status, created_at, updated_at
		FROM revision_habits
		WHERE id = $1 AND user_id = $2
	`

	revision := &models.RevisionHabit{}
	err := r.db.QueryRow(ctx, query, id, userID).Scan(
		&revision.ID,
		&revision.UserID,
		&revision.OriginalSkill,
		&revision.SourceMonth,
		&revision.DurationDays,
		&revision.DailyDurationMinutes,
		&revision.Status,
		&revision.CreatedAt,
		&revision.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrRevisionNotFound
	}

	return revision, err
}

// Delete deletes a revision habit
func (r *RevisionRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM revision_habits WHERE id = $1`

	result, err := r.db.Exec(ctx, query, id)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrRevisionNotFound
	}

	return nil
}

// AcceptRevision accepts a revision and creates a temporary habit
func (r *RevisionRepository) AcceptRevision(ctx context.Context, revision *models.RevisionHabit, habitRepo *HabitRepository) (*models.Habit, error) {
	// Update revision status
	if err := r.UpdateStatus(ctx, revision.ID, models.RevisionStatusAccepted); err != nil {
		return nil, err
	}

	// Create a new habit for the revision
	habit := &models.Habit{
		UserID:          revision.UserID,
		Title:           "Revise: " + revision.OriginalSkill,
		Description:     stringPtr("Revision habit from " + revision.SourceMonth.Format("January 2006")),
		Category:        models.CategoryLearning,
		Frequency:       models.FrequencyDaily,
		IsActive:        true,
		IsLearningHabit: true,
		Color:           "#424242",
		Icon:            "refresh",
	}

	if err := habitRepo.Create(ctx, habit); err != nil {
		return nil, err
	}

	return habit, nil
}

func stringPtr(s string) *string {
	return &s
}
