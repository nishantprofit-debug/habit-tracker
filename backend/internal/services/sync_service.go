package services

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// SyncService handles offline sync logic
type SyncService struct {
	habitRepo *repository.HabitRepository
	logRepo   *repository.LogRepository
}

// NewSyncService creates a new SyncService
func NewSyncService(
	habitRepo *repository.HabitRepository,
	logRepo *repository.LogRepository,
) *SyncService {
	return &SyncService{
		habitRepo: habitRepo,
		logRepo:   logRepo,
	}
}

// PushChanges processes offline changes from the client
func (s *SyncService) PushChanges(ctx context.Context, userID uuid.UUID, req *models.SyncPushRequest) (*models.SyncPushResponse, error) {
	syncedCount := 0
	failedCount := 0
	var failedItems []uuid.UUID

	for _, item := range req.Items {
		var err error

		switch item.EntityType {
		case models.SyncEntityHabit:
			err = s.processHabitSync(ctx, userID, item)
		case models.SyncEntityDailyLog:
			err = s.processDailyLogSync(ctx, userID, item)
		}

		if err != nil {
			failedCount++
			failedItems = append(failedItems, item.EntityID)
		} else {
			syncedCount++
		}
	}

	return &models.SyncPushResponse{
		SyncedCount:  syncedCount,
		FailedCount:  failedCount,
		FailedItems:  failedItems,
		LastSyncedAt: time.Now(),
	}, nil
}

// processHabitSync processes a habit sync item
func (s *SyncService) processHabitSync(ctx context.Context, userID uuid.UUID, item *models.SyncPushItem) error {
	switch item.Action {
	case models.SyncActionCreate:
		var habit models.Habit
		if err := json.Unmarshal(item.Payload, &habit); err != nil {
			return err
		}
		habit.UserID = userID
		return s.habitRepo.Create(ctx, &habit)

	case models.SyncActionUpdate:
		var habit models.Habit
		if err := json.Unmarshal(item.Payload, &habit); err != nil {
			return err
		}
		habit.ID = item.EntityID
		habit.UserID = userID
		return s.habitRepo.Update(ctx, &habit)

	case models.SyncActionDelete:
		return s.habitRepo.SoftDelete(ctx, item.EntityID)
	}

	return nil
}

// processDailyLogSync processes a daily log sync item
func (s *SyncService) processDailyLogSync(ctx context.Context, userID uuid.UUID, item *models.SyncPushItem) error {
	switch item.Action {
	case models.SyncActionCreate, models.SyncActionUpdate:
		var log models.DailyLog
		if err := json.Unmarshal(item.Payload, &log); err != nil {
			return err
		}
		log.UserID = userID
		return s.logRepo.CreateOrUpdate(ctx, &log)

	case models.SyncActionDelete:
		// Daily logs typically aren't deleted, they're updated to completed=false
		return nil
	}

	return nil
}

// PullChanges retrieves changes since last sync
func (s *SyncService) PullChanges(ctx context.Context, userID uuid.UUID, lastSyncedAt *time.Time) (*models.SyncPullResponse, error) {
	var since time.Time
	if lastSyncedAt != nil {
		since = *lastSyncedAt
	} else {
		// If no last sync, get everything from the last 30 days
		since = time.Now().AddDate(0, 0, -30)
	}

	// Get updated habits
	habits, err := s.habitRepo.GetUpdatedSince(ctx, userID, since)
	if err != nil {
		return nil, err
	}

	// Get updated logs
	logs, err := s.logRepo.GetUpdatedSince(ctx, userID, since)
	if err != nil {
		return nil, err
	}

	return &models.SyncPullResponse{
		Habits:       habits,
		DailyLogs:    logs,
		LastSyncedAt: time.Now(),
	}, nil
}

// GetSyncStatus returns the current sync status
func (s *SyncService) GetSyncStatus(ctx context.Context, userID uuid.UUID) (*models.SyncStatusResponse, error) {
	// In a real implementation, this would check a sync queue table
	// For now, return a simple status
	return &models.SyncStatusResponse{
		PendingCount: 0,
		IsSynced:     true,
	}, nil
}
