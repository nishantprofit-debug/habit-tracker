package models

import (
	"time"

	"github.com/google/uuid"
)

// Streak represents a habit's streak data
type Streak struct {
	ID                uuid.UUID  `json:"id"`
	HabitID           uuid.UUID  `json:"habit_id"`
	UserID            uuid.UUID  `json:"user_id"`
	CurrentStreak     int        `json:"current_streak"`
	LongestStreak     int        `json:"longest_streak"`
	LastCompletedDate *time.Time `json:"last_completed_date,omitempty"`
	UpdatedAt         time.Time  `json:"updated_at"`
}

// StreakResponse is the API response for streak data
type StreakResponse struct {
	HabitID           uuid.UUID `json:"habit_id"`
	CurrentStreak     int       `json:"current_streak"`
	LongestStreak     int       `json:"longest_streak"`
	LastCompletedDate *string   `json:"last_completed_date,omitempty"`
}

// ToResponse converts Streak to StreakResponse
func (s *Streak) ToResponse() *StreakResponse {
	var lastCompleted *string
	if s.LastCompletedDate != nil {
		formatted := s.LastCompletedDate.Format("2006-01-02")
		lastCompleted = &formatted
	}

	return &StreakResponse{
		HabitID:           s.HabitID,
		CurrentStreak:     s.CurrentStreak,
		LongestStreak:     s.LongestStreak,
		LastCompletedDate: lastCompleted,
	}
}
