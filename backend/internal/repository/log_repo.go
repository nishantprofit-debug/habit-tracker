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
	ErrLogNotFound = errors.New("daily log not found")
)

// LogRepository handles daily log database operations
type LogRepository struct {
	db *pgxpool.Pool
}

// NewLogRepository creates a new LogRepository
func NewLogRepository(db *pgxpool.Pool) *LogRepository {
	return &LogRepository{db: db}
}

// CreateOrUpdate creates or updates a daily log (upsert)
func (r *LogRepository) CreateOrUpdate(ctx context.Context, log *models.DailyLog) error {
	query := `
		INSERT INTO daily_logs (
			id, habit_id, user_id, log_date, completed, learning_note,
			completed_at, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9
		)
		ON CONFLICT (habit_id, log_date) DO UPDATE SET
			completed = EXCLUDED.completed,
			learning_note = EXCLUDED.learning_note,
			completed_at = CASE
				WHEN EXCLUDED.completed = true AND daily_logs.completed = false
				THEN EXCLUDED.completed_at
				ELSE daily_logs.completed_at
			END,
			updated_at = EXCLUDED.updated_at
		RETURNING id
	`

	if log.ID == uuid.Nil {
		log.ID = uuid.New()
	}
	log.CreatedAt = time.Now()
	log.UpdatedAt = time.Now()

	if log.Completed && log.CompletedAt == nil {
		now := time.Now()
		log.CompletedAt = &now
	}

	err := r.db.QueryRow(ctx, query,
		log.ID,
		log.HabitID,
		log.UserID,
		log.LogDate,
		log.Completed,
		log.LearningNote,
		log.CompletedAt,
		log.CreatedAt,
		log.UpdatedAt,
	).Scan(&log.ID)

	return err
}

// GetByID retrieves a daily log by ID
func (r *LogRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.DailyLog, error) {
	query := `
		SELECT dl.id, dl.habit_id, dl.user_id, dl.log_date, dl.completed,
			dl.learning_note, dl.completed_at, dl.created_at, dl.updated_at,
			h.title
		FROM daily_logs dl
		JOIN habits h ON dl.habit_id = h.id
		WHERE dl.id = $1
	`

	log := &models.DailyLog{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&log.ID,
		&log.HabitID,
		&log.UserID,
		&log.LogDate,
		&log.Completed,
		&log.LearningNote,
		&log.CompletedAt,
		&log.CreatedAt,
		&log.UpdatedAt,
		&log.HabitTitle,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrLogNotFound
	}

	return log, err
}

// GetByHabitAndDate retrieves a daily log by habit ID and date
func (r *LogRepository) GetByHabitAndDate(ctx context.Context, habitID uuid.UUID, logDate time.Time) (*models.DailyLog, error) {
	query := `
		SELECT dl.id, dl.habit_id, dl.user_id, dl.log_date, dl.completed,
			dl.learning_note, dl.completed_at, dl.created_at, dl.updated_at,
			h.title
		FROM daily_logs dl
		JOIN habits h ON dl.habit_id = h.id
		WHERE dl.habit_id = $1 AND dl.log_date = $2
	`

	log := &models.DailyLog{}
	err := r.db.QueryRow(ctx, query, habitID, logDate).Scan(
		&log.ID,
		&log.HabitID,
		&log.UserID,
		&log.LogDate,
		&log.Completed,
		&log.LearningNote,
		&log.CompletedAt,
		&log.CreatedAt,
		&log.UpdatedAt,
		&log.HabitTitle,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrLogNotFound
	}

	return log, err
}

// GetByUserAndDateRange retrieves daily logs for a user within a date range
func (r *LogRepository) GetByUserAndDateRange(ctx context.Context, userID uuid.UUID, startDate, endDate time.Time) ([]*models.DailyLog, error) {
	query := `
		SELECT dl.id, dl.habit_id, dl.user_id, dl.log_date, dl.completed,
			dl.learning_note, dl.completed_at, dl.created_at, dl.updated_at,
			h.title
		FROM daily_logs dl
		JOIN habits h ON dl.habit_id = h.id
		WHERE dl.user_id = $1 AND dl.log_date >= $2 AND dl.log_date <= $3
		ORDER BY dl.log_date DESC, dl.created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []*models.DailyLog
	for rows.Next() {
		log := &models.DailyLog{}
		err := rows.Scan(
			&log.ID,
			&log.HabitID,
			&log.UserID,
			&log.LogDate,
			&log.Completed,
			&log.LearningNote,
			&log.CompletedAt,
			&log.CreatedAt,
			&log.UpdatedAt,
			&log.HabitTitle,
		)
		if err != nil {
			return nil, err
		}
		logs = append(logs, log)
	}

	return logs, rows.Err()
}

// GetTodayLogs retrieves today's logs for a user
func (r *LogRepository) GetTodayLogs(ctx context.Context, userID uuid.UUID) ([]*models.DailyLog, error) {
	today := time.Now().Truncate(24 * time.Hour)
	return r.GetByUserAndDateRange(ctx, userID, today, today)
}

// GetByHabit retrieves all logs for a specific habit
func (r *LogRepository) GetByHabit(ctx context.Context, habitID uuid.UUID, limit, offset int) ([]*models.DailyLog, error) {
	query := `
		SELECT dl.id, dl.habit_id, dl.user_id, dl.log_date, dl.completed,
			dl.learning_note, dl.completed_at, dl.created_at, dl.updated_at,
			h.title
		FROM daily_logs dl
		JOIN habits h ON dl.habit_id = h.id
		WHERE dl.habit_id = $1
		ORDER BY dl.log_date DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := r.db.Query(ctx, query, habitID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []*models.DailyLog
	for rows.Next() {
		log := &models.DailyLog{}
		err := rows.Scan(
			&log.ID,
			&log.HabitID,
			&log.UserID,
			&log.LogDate,
			&log.Completed,
			&log.LearningNote,
			&log.CompletedAt,
			&log.CreatedAt,
			&log.UpdatedAt,
			&log.HabitTitle,
		)
		if err != nil {
			return nil, err
		}
		logs = append(logs, log)
	}

	return logs, rows.Err()
}

// GetCalendarData retrieves calendar data for a specific month
func (r *LogRepository) GetCalendarData(ctx context.Context, userID uuid.UUID, year, month int) ([]*models.CalendarDayData, error) {
	query := `
		WITH active_habits AS (
			SELECT COUNT(*) as total
			FROM habits
			WHERE user_id = $1 AND is_active = true AND deleted_at IS NULL
		),
		daily_stats AS (
			SELECT
				dl.log_date,
				COUNT(*) FILTER (WHERE dl.completed = true) as completed_count
			FROM daily_logs dl
			JOIN habits h ON dl.habit_id = h.id
			WHERE dl.user_id = $1
				AND EXTRACT(YEAR FROM dl.log_date) = $2
				AND EXTRACT(MONTH FROM dl.log_date) = $3
				AND h.is_active = true
				AND h.deleted_at IS NULL
			GROUP BY dl.log_date
		)
		SELECT
			ds.log_date::date as date,
			ah.total as total_habits,
			ds.completed_count,
			CASE
				WHEN ah.total > 0 THEN ROUND((ds.completed_count::float / ah.total) * 100)
				ELSE 0
			END as percentage
		FROM daily_stats ds
		CROSS JOIN active_habits ah
		ORDER BY ds.log_date
	`

	rows, err := r.db.Query(ctx, query, userID, year, month)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var data []*models.CalendarDayData
	for rows.Next() {
		day := &models.CalendarDayData{}
		var date time.Time
		err := rows.Scan(
			&date,
			&day.TotalHabits,
			&day.CompletedCount,
			&day.Percentage,
		)
		if err != nil {
			return nil, err
		}
		day.Date = date.Format("2006-01-02")
		data = append(data, day)
	}

	return data, rows.Err()
}

// GetLearningNotesByUserAndMonth retrieves learning notes for report generation
func (r *LogRepository) GetLearningNotesByUserAndMonth(ctx context.Context, userID uuid.UUID, year, month int) (map[uuid.UUID][]string, error) {
	query := `
		SELECT dl.habit_id, dl.learning_note
		FROM daily_logs dl
		JOIN habits h ON dl.habit_id = h.id
		WHERE dl.user_id = $1
			AND EXTRACT(YEAR FROM dl.log_date) = $2
			AND EXTRACT(MONTH FROM dl.log_date) = $3
			AND dl.learning_note IS NOT NULL
			AND dl.learning_note != ''
			AND h.is_learning_habit = true
		ORDER BY dl.log_date ASC
	`

	rows, err := r.db.Query(ctx, query, userID, year, month)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	notes := make(map[uuid.UUID][]string)
	for rows.Next() {
		var habitID uuid.UUID
		var note string
		if err := rows.Scan(&habitID, &note); err != nil {
			return nil, err
		}
		notes[habitID] = append(notes[habitID], note)
	}

	return notes, rows.Err()
}

// GetCompletionRateByHabitAndMonth calculates completion rate for a habit in a month
func (r *LogRepository) GetCompletionRateByHabitAndMonth(ctx context.Context, habitID uuid.UUID, year, month int) (float64, error) {
	query := `
		SELECT
			COALESCE(
				COUNT(*) FILTER (WHERE completed = true)::float /
				NULLIF(COUNT(*), 0) * 100,
				0
			) as completion_rate
		FROM daily_logs
		WHERE habit_id = $1
			AND EXTRACT(YEAR FROM log_date) = $2
			AND EXTRACT(MONTH FROM log_date) = $3
	`

	var rate float64
	err := r.db.QueryRow(ctx, query, habitID, year, month).Scan(&rate)

	return rate, err
}

// GetUpdatedSince retrieves logs updated since a given time (for sync)
func (r *LogRepository) GetUpdatedSince(ctx context.Context, userID uuid.UUID, since time.Time) ([]*models.DailyLog, error) {
	query := `
		SELECT dl.id, dl.habit_id, dl.user_id, dl.log_date, dl.completed,
			dl.learning_note, dl.completed_at, dl.created_at, dl.updated_at,
			h.title
		FROM daily_logs dl
		JOIN habits h ON dl.habit_id = h.id
		WHERE dl.user_id = $1 AND dl.updated_at > $2
		ORDER BY dl.updated_at ASC
	`

	rows, err := r.db.Query(ctx, query, userID, since)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []*models.DailyLog
	for rows.Next() {
		log := &models.DailyLog{}
		err := rows.Scan(
			&log.ID,
			&log.HabitID,
			&log.UserID,
			&log.LogDate,
			&log.Completed,
			&log.LearningNote,
			&log.CompletedAt,
			&log.CreatedAt,
			&log.UpdatedAt,
			&log.HabitTitle,
		)
		if err != nil {
			return nil, err
		}
		logs = append(logs, log)
	}

	return logs, rows.Err()
}

// CheckTodayCompleted checks if a habit is completed for today
func (r *LogRepository) CheckTodayCompleted(ctx context.Context, habitID uuid.UUID) (bool, error) {
	today := time.Now().Truncate(24 * time.Hour)
	query := `
		SELECT completed FROM daily_logs
		WHERE habit_id = $1 AND log_date = $2
	`

	var completed bool
	err := r.db.QueryRow(ctx, query, habitID, today).Scan(&completed)

	if errors.Is(err, pgx.ErrNoRows) {
		return false, nil
	}

	return completed, err
}
