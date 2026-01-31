package models

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// SyncAction represents the type of sync action
type SyncAction string

const (
	SyncActionCreate SyncAction = "create"
	SyncActionUpdate SyncAction = "update"
	SyncActionDelete SyncAction = "delete"
)

// SyncEntityType represents the type of entity being synced
type SyncEntityType string

const (
	SyncEntityHabit    SyncEntityType = "habit"
	SyncEntityDailyLog SyncEntityType = "daily_log"
)

// SyncQueueItem represents an item in the sync queue
type SyncQueueItem struct {
	ID         uuid.UUID       `json:"id"`
	UserID     uuid.UUID       `json:"user_id"`
	Action     SyncAction      `json:"action"`
	EntityType SyncEntityType  `json:"entity_type"`
	EntityID   uuid.UUID       `json:"entity_id"`
	Payload    json.RawMessage `json:"payload"`
	Synced     bool            `json:"synced"`
	CreatedAt  time.Time       `json:"created_at"`
}

// SyncPushRequest represents a request to push offline changes
type SyncPushRequest struct {
	Items []*SyncPushItem `json:"items" binding:"required,dive"`
}

// SyncPushItem represents a single item to sync
type SyncPushItem struct {
	Action     SyncAction      `json:"action" binding:"required,oneof=create update delete"`
	EntityType SyncEntityType  `json:"entity_type" binding:"required,oneof=habit daily_log"`
	EntityID   uuid.UUID       `json:"entity_id" binding:"required"`
	Payload    json.RawMessage `json:"payload" binding:"required"`
	Timestamp  time.Time       `json:"timestamp" binding:"required"`
}

// SyncPushResponse represents the response after syncing
type SyncPushResponse struct {
	SyncedCount  int          `json:"synced_count"`
	FailedCount  int          `json:"failed_count"`
	FailedItems  []uuid.UUID  `json:"failed_items,omitempty"`
	LastSyncedAt time.Time    `json:"last_synced_at"`
}

// SyncPullRequest represents a request to pull latest data
type SyncPullRequest struct {
	LastSyncedAt *time.Time `json:"last_synced_at,omitempty"`
}

// SyncPullResponse represents the response with latest data
type SyncPullResponse struct {
	Habits       []*Habit    `json:"habits"`
	DailyLogs    []*DailyLog `json:"daily_logs"`
	LastSyncedAt time.Time   `json:"last_synced_at"`
}

// SyncStatusResponse represents the current sync status
type SyncStatusResponse struct {
	LastSyncedAt   *time.Time `json:"last_synced_at,omitempty"`
	PendingCount   int        `json:"pending_count"`
	IsSynced       bool       `json:"is_synced"`
}
