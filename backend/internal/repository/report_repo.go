package repository

import (
	"context"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrReportNotFound = errors.New("report not found")
	ErrReportExists   = errors.New("report already exists for this month")
)

// ReportRepository handles report database operations
type ReportRepository struct {
	db *pgxpool.Pool
}

// NewReportRepository creates a new ReportRepository
func NewReportRepository(db *pgxpool.Pool) *ReportRepository {
	return &ReportRepository{db: db}
}

// Create creates a new report
func (r *ReportRepository) Create(ctx context.Context, report *models.Report) error {
	query := `
		INSERT INTO reports (
			id, user_id, report_month, report_content, skills_learned,
			habits_completed_percentage, revision_suggestions, generated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8
		)
	`

	report.ID = uuid.New()
	report.GeneratedAt = time.Now()

	_, err := r.db.Exec(ctx, query,
		report.ID,
		report.UserID,
		report.ReportMonth,
		report.ReportContent,
		report.SkillsLearned,
		report.HabitsCompletedPercentage,
		report.RevisionSuggestions,
		report.GeneratedAt,
	)

	return err
}

// GetByID retrieves a report by ID
func (r *ReportRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.Report, error) {
	query := `
		SELECT id, user_id, report_month, report_content, skills_learned,
			habits_completed_percentage, revision_suggestions, generated_at
		FROM reports
		WHERE id = $1
	`

	report := &models.Report{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&report.ID,
		&report.UserID,
		&report.ReportMonth,
		&report.ReportContent,
		&report.SkillsLearned,
		&report.HabitsCompletedPercentage,
		&report.RevisionSuggestions,
		&report.GeneratedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrReportNotFound
	}

	return report, err
}

// GetByUserAndMonth retrieves a report by user ID and month
func (r *ReportRepository) GetByUserAndMonth(ctx context.Context, userID uuid.UUID, reportMonth time.Time) (*models.Report, error) {
	query := `
		SELECT id, user_id, report_month, report_content, skills_learned,
			habits_completed_percentage, revision_suggestions, generated_at
		FROM reports
		WHERE user_id = $1 AND report_month = $2
	`

	report := &models.Report{}
	err := r.db.QueryRow(ctx, query, userID, reportMonth).Scan(
		&report.ID,
		&report.UserID,
		&report.ReportMonth,
		&report.ReportContent,
		&report.SkillsLearned,
		&report.HabitsCompletedPercentage,
		&report.RevisionSuggestions,
		&report.GeneratedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrReportNotFound
	}

	return report, err
}

// GetByUser retrieves all reports for a user
func (r *ReportRepository) GetByUser(ctx context.Context, userID uuid.UUID) ([]*models.Report, error) {
	query := `
		SELECT id, user_id, report_month, report_content, skills_learned,
			habits_completed_percentage, revision_suggestions, generated_at
		FROM reports
		WHERE user_id = $1
		ORDER BY report_month DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var reports []*models.Report
	for rows.Next() {
		report := &models.Report{}
		err := rows.Scan(
			&report.ID,
			&report.UserID,
			&report.ReportMonth,
			&report.ReportContent,
			&report.SkillsLearned,
			&report.HabitsCompletedPercentage,
			&report.RevisionSuggestions,
			&report.GeneratedAt,
		)
		if err != nil {
			return nil, err
		}
		reports = append(reports, report)
	}

	return reports, rows.Err()
}

// Exists checks if a report exists for a user and month
func (r *ReportRepository) Exists(ctx context.Context, userID uuid.UUID, reportMonth time.Time) (bool, error) {
	query := `SELECT EXISTS(SELECT 1 FROM reports WHERE user_id = $1 AND report_month = $2)`

	var exists bool
	err := r.db.QueryRow(ctx, query, userID, reportMonth).Scan(&exists)

	return exists, err
}

// GetHabitCompletionDataForMonth retrieves habit completion data for report generation
func (r *ReportRepository) GetHabitCompletionDataForMonth(ctx context.Context, userID uuid.UUID, year, month int) ([]*models.HabitCompletionData, error) {
	query := `
		WITH habit_stats AS (
			SELECT
				h.id as habit_id,
				h.title as habit_title,
				h.category,
				COALESCE(s.current_streak, 0) as streak,
				COUNT(dl.id) as total_days,
				COUNT(dl.id) FILTER (WHERE dl.completed = true) as completed_days
			FROM habits h
			LEFT JOIN streaks s ON h.id = s.habit_id
			LEFT JOIN daily_logs dl ON h.id = dl.habit_id
				AND EXTRACT(YEAR FROM dl.log_date) = $2
				AND EXTRACT(MONTH FROM dl.log_date) = $3
			WHERE h.user_id = $1
				AND h.is_active = true
				AND h.deleted_at IS NULL
			GROUP BY h.id, h.title, h.category, s.current_streak
		)
		SELECT
			habit_id,
			habit_title,
			category,
			streak,
			CASE
				WHEN total_days > 0 THEN (completed_days::float / total_days) * 100
				ELSE 0
			END as completion_rate
		FROM habit_stats
	`

	rows, err := r.db.Query(ctx, query, userID, year, month)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var data []*models.HabitCompletionData
	for rows.Next() {
		item := &models.HabitCompletionData{}
		err := rows.Scan(
			&item.HabitID,
			&item.HabitTitle,
			&item.Category,
			&item.Streak,
			&item.CompletionRate,
		)
		if err != nil {
			return nil, err
		}
		data = append(data, item)
	}

	return data, rows.Err()
}

// Update updates a report
func (r *ReportRepository) Update(ctx context.Context, report *models.Report) error {
	query := `
		UPDATE reports SET
			report_content = $2,
			skills_learned = $3,
			habits_completed_percentage = $4,
			revision_suggestions = $5,
			generated_at = $6
		WHERE id = $1
	`

	report.GeneratedAt = time.Now()

	result, err := r.db.Exec(ctx, query,
		report.ID,
		report.ReportContent,
		report.SkillsLearned,
		report.HabitsCompletedPercentage,
		report.RevisionSuggestions,
		report.GeneratedAt,
	)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return ErrReportNotFound
	}

	return nil
}

// CreateRevisionHabitsFromReport creates revision habits from report suggestions
func (r *ReportRepository) CreateRevisionHabitsFromReport(ctx context.Context, userID uuid.UUID, reportMonth time.Time, suggestions []models.RevisionSuggestion) error {
	for _, suggestion := range suggestions {
		query := `
			INSERT INTO revision_habits (
				id, user_id, original_skill, source_month, duration_days,
				daily_duration_minutes, status, created_at, updated_at
			) VALUES (
				$1, $2, $3, $4, $5, $6, $7, $8, $9
			)
		`

		now := time.Now()
		_, err := r.db.Exec(ctx, query,
			uuid.New(),
			userID,
			suggestion.Skill,
			reportMonth,
			suggestion.SuggestedDurationDays,
			suggestion.DailyMinutes,
			models.RevisionStatusPending,
			now,
			now,
		)

		if err != nil {
			return err
		}
	}

	return nil
}

// GetReportWithSuggestions retrieves a report with its revision suggestions parsed
func (r *ReportRepository) GetReportWithSuggestions(ctx context.Context, id uuid.UUID) (*models.Report, []models.RevisionSuggestion, error) {
	report, err := r.GetByID(ctx, id)
	if err != nil {
		return nil, nil, err
	}

	var suggestions []models.RevisionSuggestion
	if len(report.RevisionSuggestions) > 0 {
		if err := json.Unmarshal(report.RevisionSuggestions, &suggestions); err != nil {
			return nil, nil, err
		}
	}

	return report, suggestions, nil
}
