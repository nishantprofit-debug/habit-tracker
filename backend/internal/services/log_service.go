package services

import (
	"context"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// LogService handles daily log business logic
type LogService struct {
	logRepo         *repository.LogRepository
	habitRepo       *repository.HabitRepository
	streakRepo      *repository.StreakRepository
	gamificationSvc *GamificationService
}

// NewLogService creates a new LogService
func NewLogService(
	logRepo *repository.LogRepository,
	habitRepo *repository.HabitRepository,
	streakRepo *repository.StreakRepository,
	gamificationSvc *GamificationService,
) *LogService {
	return &LogService{
		logRepo:         logRepo,
		habitRepo:       habitRepo,
		streakRepo:      streakRepo,
		gamificationSvc: gamificationSvc,
	}
}

// CreateOrUpdateLog creates or updates a daily log
func (s *LogService) CreateOrUpdateLog(ctx context.Context, userID uuid.UUID, req *models.DailyLogCreateRequest) (*models.DailyLog, error) {
	// Verify habit ownership
	habit, err := s.habitRepo.GetByIDAndUserID(ctx, req.HabitID, userID)
	if err != nil {
		return nil, err
	}

	// Parse log date
	logDate, err := time.Parse("2006-01-02", req.LogDate)
	if err != nil {
		return nil, err
	}

	// Check if log exists
	existingLog, err := s.logRepo.GetByHabitAndDate(ctx, req.HabitID, logDate)
	wasCompletedBefore := err == nil && existingLog.Completed

	dailyLog := &models.DailyLog{
		HabitID:      req.HabitID,
		UserID:       userID,
		LogDate:      logDate,
		Completed:    req.Completed,
		LearningNote: req.LearningNote,
		HabitTitle:   habit.Title,
	}

	if existingLog != nil {
		dailyLog.ID = existingLog.ID
	}

	if err := s.logRepo.CreateOrUpdate(ctx, dailyLog); err != nil {
		return nil, err
	}

	// Update streak if completed status changed
	if req.Completed && !wasCompletedBefore {
		// Habit was completed, update streak
		if err := s.streakRepo.UpdateStreakAfterCompletion(ctx, req.HabitID, logDate); err != nil {
			log.Printf("failed to update streak for habit %s: %v", req.HabitID, err)
		}

		// Award XP
		if err := s.gamificationSvc.AwardHabitCompletionXP(ctx, userID, req.HabitID, false); err != nil {
			log.Printf("failed to award habit completion XP to user %s: %v", userID, err)
		}
	}

	// Award XP for learning note if new
	if req.LearningNote != nil && *req.LearningNote != "" && (existingLog == nil || existingLog.LearningNote == nil || *existingLog.LearningNote == "") {
		if err := s.gamificationSvc.AwardLearningNoteXP(ctx, userID, dailyLog.ID); err != nil {
			log.Printf("failed to award learning note XP to user %s: %v", userID, err)
		}
	}

	return dailyLog, nil
}

// GetLog retrieves a daily log by ID
func (s *LogService) GetLog(ctx context.Context, userID, logID uuid.UUID) (*models.DailyLog, error) {
	dailyLog, err := s.logRepo.GetByID(ctx, logID)
	if err != nil {
		return nil, err
	}

	// Verify ownership
	if dailyLog.UserID != userID {
		return nil, repository.ErrLogNotFound
	}

	return dailyLog, nil
}

// GetTodayLogs retrieves today's logs for all habits
func (s *LogService) GetTodayLogs(ctx context.Context, userID uuid.UUID) ([]*models.DailyLog, error) {
	return s.logRepo.GetTodayLogs(ctx, userID)
}

// GetLogsByDateRange retrieves logs within a date range
func (s *LogService) GetLogsByDateRange(ctx context.Context, userID uuid.UUID, startDate, endDate string) ([]*models.DailyLog, error) {
	start, err := time.Parse("2006-01-02", startDate)
	if err != nil {
		return nil, err
	}

	end, err := time.Parse("2006-01-02", endDate)
	if err != nil {
		return nil, err
	}

	return s.logRepo.GetByUserAndDateRange(ctx, userID, start, end)
}

// GetLogsByHabit retrieves logs for a specific habit
func (s *LogService) GetLogsByHabit(ctx context.Context, userID, habitID uuid.UUID, limit, offset int) ([]*models.DailyLog, error) {
	// Verify ownership
	_, err := s.habitRepo.GetByIDAndUserID(ctx, habitID, userID)
	if err != nil {
		return nil, err
	}

	return s.logRepo.GetByHabit(ctx, habitID, limit, offset)
}

// GetCalendarData retrieves calendar data for a month
func (s *LogService) GetCalendarData(ctx context.Context, userID uuid.UUID, year, month int) (*models.CalendarMonthResponse, error) {
	data, err := s.logRepo.GetCalendarData(ctx, userID, year, month)
	if err != nil {
		return nil, err
	}

	return &models.CalendarMonthResponse{
		Month: time.Month(month).String(),
		Year:  year,
		Days:  data,
	}, nil
}

// GetLogsUpdatedSince retrieves logs updated since a given time (for sync)
func (s *LogService) GetLogsUpdatedSince(ctx context.Context, userID uuid.UUID, since time.Time) ([]*models.DailyLog, error) {
	return s.logRepo.GetUpdatedSince(ctx, userID, since)
}

// QuickComplete quickly marks a habit as completed for today
func (s *LogService) QuickComplete(ctx context.Context, userID, habitID uuid.UUID) (*models.DailyLog, error) {
	today := time.Now().Format("2006-01-02")
	completed := true

	return s.CreateOrUpdateLog(ctx, userID, &models.DailyLogCreateRequest{
		HabitID:   habitID,
		LogDate:   today,
		Completed: completed,
	})
}

// AddLearningNote adds a learning note to today's log
func (s *LogService) AddLearningNote(ctx context.Context, userID, habitID uuid.UUID, note string) (*models.DailyLog, error) {
	today := time.Now().Format("2006-01-02")

	return s.CreateOrUpdateLog(ctx, userID, &models.DailyLogCreateRequest{
		HabitID:      habitID,
		LogDate:      today,
		Completed:    true,
		LearningNote: &note,
	})
}
