package models

import (
	"time"

	"github.com/google/uuid"
)

// RevisionStatus represents the status of a revision habit
type RevisionStatus string

const (
	RevisionStatusPending   RevisionStatus = "pending"
	RevisionStatusAccepted  RevisionStatus = "accepted"
	RevisionStatusDeclined  RevisionStatus = "declined"
	RevisionStatusCompleted RevisionStatus = "completed"
)

// RevisionHabit represents an AI-suggested revision habit
type RevisionHabit struct {
	ID                   uuid.UUID      `json:"id"`
	UserID               uuid.UUID      `json:"user_id"`
	OriginalSkill        string         `json:"original_skill"`
	SourceMonth          time.Time      `json:"source_month"`
	DurationDays         int            `json:"duration_days"`
	DailyDurationMinutes int            `json:"daily_duration_minutes"`
	Status               RevisionStatus `json:"status"`
	CreatedAt            time.Time      `json:"created_at"`
	UpdatedAt            time.Time      `json:"updated_at"`
}

// RevisionHabitResponse is the API response for revision habit data
type RevisionHabitResponse struct {
	ID                   uuid.UUID      `json:"id"`
	OriginalSkill        string         `json:"original_skill"`
	SourceMonth          string         `json:"source_month"`
	DurationDays         int            `json:"duration_days"`
	DailyDurationMinutes int            `json:"daily_duration_minutes"`
	Status               RevisionStatus `json:"status"`
	CreatedAt            time.Time      `json:"created_at"`
}

// ToResponse converts RevisionHabit to RevisionHabitResponse
func (rh *RevisionHabit) ToResponse() *RevisionHabitResponse {
	return &RevisionHabitResponse{
		ID:                   rh.ID,
		OriginalSkill:        rh.OriginalSkill,
		SourceMonth:          rh.SourceMonth.Format("2006-01"),
		DurationDays:         rh.DurationDays,
		DailyDurationMinutes: rh.DailyDurationMinutes,
		Status:               rh.Status,
		CreatedAt:            rh.CreatedAt,
	}
}

// RevisionHabitListResponse wraps a list of revision habits
type RevisionHabitListResponse struct {
	Revisions  []*RevisionHabitResponse `json:"revisions"`
	TotalCount int                      `json:"total_count"`
}

// RevisionStatusUpdateRequest represents the request to update revision status
type RevisionStatusUpdateRequest struct {
	Status RevisionStatus `json:"status" binding:"required,oneof=accepted declined completed"`
}
