package models

import (
	"time"

	"github.com/google/uuid"
)

// XPAction represents an action that grants XP
type XPAction string

const (
	ActionHabitComplete XPAction = "habit_complete"
	ActionStreakBonus   XPAction = "streak_bonus"
	ActionLevelUp       XPAction = "level_up"
	ActionReportRead    XPAction = "report_read"
)

// XPLog tracks XP transactions for a user
type XPLog struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	Action    XPAction  `json:"action"`
	Amount    int       `json:"amount"`
	Reference uuid.UUID `json:"reference_id,omitempty"` // e.g. habit_id or log_id
	CreatedAt time.Time `json:"created_at"`
}

// Badge represents a collectible achievement
type Badge struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Icon        string    `json:"icon"`
	Criteria    string    `json:"criteria"` // JSON string of criteria
	CreatedAt   time.Time `json:"created_at"`
}

// UserBadge tracks which badges a user has earned
type UserBadge struct {
	UserID    uuid.UUID `json:"user_id"`
	BadgeID   uuid.UUID `json:"badge_id"`
	EarnedAt  time.Time `json:"earned_at"`
}

// GamificationStats provides an overview for the UI
type GamificationStats struct {
	XP            int         `json:"xp"`
	Level         int         `json:"level"`
	NextLevelXP   int         `json:"next_level_xp"`
	Progress      float64     `json:"progress"` // 0.0 to 1.0
	RecentBadges  []UserBadge `json:"recent_badges"`
	RecentXPLogs  []XPLog     `json:"recent_xp_logs"`
}
