package models

import (
	"time"

	"github.com/google/uuid"
)

// HabitCategory represents habit categories
type HabitCategory string

const (
	CategoryLearning     HabitCategory = "learning"
	CategoryHealth       HabitCategory = "health"
	CategoryProductivity HabitCategory = "productivity"
	CategoryPersonal     HabitCategory = "personal"
)

// HabitFrequency represents habit frequency
type HabitFrequency string

const (
	FrequencyDaily  HabitFrequency = "daily"
	FrequencyWeekly HabitFrequency = "weekly"
)

// Habit represents a habit in the system
type Habit struct {
	ID              uuid.UUID      `json:"id"`
	UserID          uuid.UUID      `json:"user_id"`
	Title           string         `json:"title"`
	Description     *string        `json:"description,omitempty"`
	Category        HabitCategory  `json:"category"`
	Frequency       HabitFrequency `json:"frequency"`
	IsActive        bool           `json:"is_active"`
	IsLearningHabit bool           `json:"is_learning_habit"`
	Color           string         `json:"color"`
	Icon            string         `json:"icon"`
	ReminderTime    *string        `json:"reminder_time,omitempty"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       *time.Time     `json:"deleted_at,omitempty"`

	// Computed fields (not stored in DB)
	CurrentStreak int `json:"current_streak,omitempty"`
	LongestStreak int `json:"longest_streak,omitempty"`
	TodayCompleted bool `json:"today_completed,omitempty"`
}

// HabitCreateRequest represents the request body for creating a habit
type HabitCreateRequest struct {
	Title           string         `json:"title" binding:"required,min=1,max=255"`
	Description     *string        `json:"description,omitempty"`
	Category        HabitCategory  `json:"category" binding:"omitempty,oneof=learning health productivity personal"`
	Frequency       HabitFrequency `json:"frequency" binding:"omitempty,oneof=daily weekly"`
	IsLearningHabit bool           `json:"is_learning_habit"`
	Color           string         `json:"color" binding:"omitempty,hexcolor"`
	Icon            string         `json:"icon" binding:"omitempty,max=50"`
	ReminderTime    *string        `json:"reminder_time,omitempty"`
}

// HabitUpdateRequest represents the request body for updating a habit
type HabitUpdateRequest struct {
	Title           *string         `json:"title,omitempty" binding:"omitempty,min=1,max=255"`
	Description     *string         `json:"description,omitempty"`
	Category        *HabitCategory  `json:"category,omitempty" binding:"omitempty,oneof=learning health productivity personal"`
	Frequency       *HabitFrequency `json:"frequency,omitempty" binding:"omitempty,oneof=daily weekly"`
	IsActive        *bool           `json:"is_active,omitempty"`
	IsLearningHabit *bool           `json:"is_learning_habit,omitempty"`
	Color           *string         `json:"color,omitempty" binding:"omitempty,hexcolor"`
	Icon            *string         `json:"icon,omitempty" binding:"omitempty,max=50"`
	ReminderTime    *string         `json:"reminder_time,omitempty"`
}

// HabitResponse is the API response for habit data
type HabitResponse struct {
	ID              uuid.UUID      `json:"id"`
	Title           string         `json:"title"`
	Description     *string        `json:"description,omitempty"`
	Category        HabitCategory  `json:"category"`
	Frequency       HabitFrequency `json:"frequency"`
	IsActive        bool           `json:"is_active"`
	IsLearningHabit bool           `json:"is_learning_habit"`
	Color           string         `json:"color"`
	Icon            string         `json:"icon"`
	ReminderTime    *string        `json:"reminder_time,omitempty"`
	CurrentStreak   int            `json:"current_streak"`
	LongestStreak   int            `json:"longest_streak"`
	TodayCompleted  bool           `json:"today_completed"`
	CreatedAt       time.Time      `json:"created_at"`
}

// ToResponse converts Habit to HabitResponse
func (h *Habit) ToResponse() *HabitResponse {
	return &HabitResponse{
		ID:              h.ID,
		Title:           h.Title,
		Description:     h.Description,
		Category:        h.Category,
		Frequency:       h.Frequency,
		IsActive:        h.IsActive,
		IsLearningHabit: h.IsLearningHabit,
		Color:           h.Color,
		Icon:            h.Icon,
		ReminderTime:    h.ReminderTime,
		CurrentStreak:   h.CurrentStreak,
		LongestStreak:   h.LongestStreak,
		TodayCompleted:  h.TodayCompleted,
		CreatedAt:       h.CreatedAt,
	}
}

// HabitListResponse wraps a list of habits
type HabitListResponse struct {
	Habits     []*HabitResponse `json:"habits"`
	TotalCount int              `json:"total_count"`
}
