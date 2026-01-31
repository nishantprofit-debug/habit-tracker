package models

import (
	"time"

	"github.com/google/uuid"
)

// DailyLog represents a daily habit completion log
type DailyLog struct {
	ID           uuid.UUID  `json:"id"`
	HabitID      uuid.UUID  `json:"habit_id"`
	UserID       uuid.UUID  `json:"user_id"`
	LogDate      time.Time  `json:"log_date"`
	Completed    bool       `json:"completed"`
	LearningNote *string    `json:"learning_note,omitempty"`
	CompletedAt  *time.Time `json:"completed_at,omitempty"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`

	// Related data
	HabitTitle string `json:"habit_title,omitempty"`
}

// DailyLogCreateRequest represents the request body for creating/updating a daily log
type DailyLogCreateRequest struct {
	HabitID      uuid.UUID `json:"habit_id" binding:"required"`
	LogDate      string    `json:"log_date" binding:"required"` // Format: YYYY-MM-DD
	Completed    bool      `json:"completed"`
	LearningNote *string   `json:"learning_note,omitempty"`
}

// DailyLogUpdateRequest represents the request body for updating a daily log
type DailyLogUpdateRequest struct {
	Completed    *bool   `json:"completed,omitempty"`
	LearningNote *string `json:"learning_note,omitempty"`
}

// DailyLogResponse is the API response for daily log data
type DailyLogResponse struct {
	ID           uuid.UUID  `json:"id"`
	HabitID      uuid.UUID  `json:"habit_id"`
	HabitTitle   string     `json:"habit_title,omitempty"`
	LogDate      string     `json:"log_date"`
	Completed    bool       `json:"completed"`
	LearningNote *string    `json:"learning_note,omitempty"`
	CompletedAt  *time.Time `json:"completed_at,omitempty"`
}

// ToResponse converts DailyLog to DailyLogResponse
func (dl *DailyLog) ToResponse() *DailyLogResponse {
	return &DailyLogResponse{
		ID:           dl.ID,
		HabitID:      dl.HabitID,
		HabitTitle:   dl.HabitTitle,
		LogDate:      dl.LogDate.Format("2006-01-02"),
		Completed:    dl.Completed,
		LearningNote: dl.LearningNote,
		CompletedAt:  dl.CompletedAt,
	}
}

// DailyLogListResponse wraps a list of daily logs
type DailyLogListResponse struct {
	Logs       []*DailyLogResponse `json:"logs"`
	TotalCount int                 `json:"total_count"`
}

// TodayLogsResponse represents today's logs with habit info
type TodayLogsResponse struct {
	Date   string              `json:"date"`
	Habits []*TodayHabitStatus `json:"habits"`
}

// TodayHabitStatus represents a habit's status for today
type TodayHabitStatus struct {
	HabitID       uuid.UUID `json:"habit_id"`
	HabitTitle    string    `json:"habit_title"`
	Category      string    `json:"category"`
	IsLearning    bool      `json:"is_learning"`
	Completed     bool      `json:"completed"`
	LearningNote  *string   `json:"learning_note,omitempty"`
	CurrentStreak int       `json:"current_streak"`
}

// CalendarDayData represents data for a single day in calendar view
type CalendarDayData struct {
	Date           string `json:"date"`
	TotalHabits    int    `json:"total_habits"`
	CompletedCount int    `json:"completed_count"`
	Percentage     int    `json:"percentage"`
}

// CalendarMonthResponse represents calendar data for a month
type CalendarMonthResponse struct {
	Month string             `json:"month"`
	Year  int                `json:"year"`
	Days  []*CalendarDayData `json:"days"`
}
