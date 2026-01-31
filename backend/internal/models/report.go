package models

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// Report represents a monthly AI-generated report
type Report struct {
	ID                        uuid.UUID       `json:"id"`
	UserID                    uuid.UUID       `json:"user_id"`
	ReportMonth               time.Time       `json:"report_month"`
	ReportContent             json.RawMessage `json:"report_content"`
	SkillsLearned             []string        `json:"skills_learned"`
	HabitsCompletedPercentage json.RawMessage `json:"habits_completed_percentage"`
	RevisionSuggestions       json.RawMessage `json:"revision_suggestions"`
	GeneratedAt               time.Time       `json:"generated_at"`
}

// ReportContent represents the structure of AI-generated report content
type ReportContent struct {
	Summary             string               `json:"summary"`
	Improvements        []string             `json:"improvements"`
	SkillsLearned       []string             `json:"skills_learned"`
	AreasToImprove      []string             `json:"areas_to_improve"`
	RevisionSuggestions []RevisionSuggestion `json:"revision_suggestions"`
	MotivationalNote    string               `json:"motivational_note"`
}

// RevisionSuggestion represents an AI-suggested revision habit
type RevisionSuggestion struct {
	Skill                 string `json:"skill"`
	Reason                string `json:"reason"`
	SuggestedDurationDays int    `json:"suggested_duration_days"`
	DailyMinutes          int    `json:"daily_minutes"`
}

// HabitCompletionData represents habit completion data for report generation
type HabitCompletionData struct {
	HabitID        uuid.UUID `json:"habit_id"`
	HabitTitle     string    `json:"habit_title"`
	Category       string    `json:"category"`
	CompletionRate float64   `json:"completion_rate"`
	Streak         int       `json:"streak"`
	LearningNotes  []string  `json:"learning_notes"`
}

// ReportGenerationInput represents input data for AI report generation
type ReportGenerationInput struct {
	UserID            uuid.UUID              `json:"user_id"`
	Month             string                 `json:"month"` // Format: YYYY-MM
	Habits            []*HabitCompletionData `json:"habits"`
	TotalHabits       int                    `json:"total_habits"`
	OverallCompletion float64                `json:"overall_completion"`
}

// ReportResponse is the API response for report data
type ReportResponse struct {
	ID            uuid.UUID      `json:"id"`
	ReportMonth   string         `json:"report_month"`
	Content       *ReportContent `json:"content"`
	SkillsLearned []string       `json:"skills_learned"`
	GeneratedAt   time.Time      `json:"generated_at"`
}

// ToResponse converts Report to ReportResponse
func (r *Report) ToResponse() (*ReportResponse, error) {
	var content ReportContent
	if err := json.Unmarshal(r.ReportContent, &content); err != nil {
		return nil, err
	}

	return &ReportResponse{
		ID:            r.ID,
		ReportMonth:   r.ReportMonth.Format("2006-01"),
		Content:       &content,
		SkillsLearned: r.SkillsLearned,
		GeneratedAt:   r.GeneratedAt,
	}, nil
}

// ReportListResponse wraps a list of reports
type ReportListResponse struct {
	Reports    []*ReportResponse `json:"reports"`
	TotalCount int               `json:"total_count"`
}
