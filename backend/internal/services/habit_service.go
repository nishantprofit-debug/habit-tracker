package services

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// HabitService handles habit business logic
type HabitService struct {
	habitRepo  *repository.HabitRepository
	logRepo    *repository.LogRepository
	streakRepo *repository.StreakRepository
}

// NewHabitService creates a new HabitService
func NewHabitService(
	habitRepo *repository.HabitRepository,
	logRepo *repository.LogRepository,
	streakRepo *repository.StreakRepository,
) *HabitService {
	return &HabitService{
		habitRepo:  habitRepo,
		logRepo:    logRepo,
		streakRepo: streakRepo,
	}
}

// CreateHabit creates a new habit for a user
func (s *HabitService) CreateHabit(ctx context.Context, userID uuid.UUID, req *models.HabitCreateRequest) (*models.Habit, error) {
	habit := &models.Habit{
		UserID:          userID,
		Title:           req.Title,
		Description:     req.Description,
		Category:        req.Category,
		Frequency:       req.Frequency,
		IsActive:        true,
		IsLearningHabit: req.IsLearningHabit,
		Color:           req.Color,
		Icon:            req.Icon,
		ReminderTime:    req.ReminderTime,
	}

	// Set defaults
	if habit.Category == "" {
		habit.Category = models.CategoryPersonal
	}
	if habit.Frequency == "" {
		habit.Frequency = models.FrequencyDaily
	}
	if habit.Color == "" {
		habit.Color = "#424242"
	}
	if habit.Icon == "" {
		habit.Icon = "check"
	}

	if err := s.habitRepo.Create(ctx, habit); err != nil {
		return nil, err
	}

	return habit, nil
}

// GetHabit retrieves a habit by ID for a user
func (s *HabitService) GetHabit(ctx context.Context, userID, habitID uuid.UUID) (*models.Habit, error) {
	habit, err := s.habitRepo.GetByIDAndUserID(ctx, habitID, userID)
	if err != nil {
		return nil, err
	}

	// Check if completed today
	completed, err := s.logRepo.CheckTodayCompleted(ctx, habitID)
	if err == nil {
		habit.TodayCompleted = completed
	}

	return habit, nil
}

// GetUserHabits retrieves all habits for a user
func (s *HabitService) GetUserHabits(ctx context.Context, userID uuid.UUID) ([]*models.Habit, error) {
	habits, err := s.habitRepo.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	// Check today's completion for each habit
	for _, habit := range habits {
		completed, err := s.logRepo.CheckTodayCompleted(ctx, habit.ID)
		if err == nil {
			habit.TodayCompleted = completed
		}
	}

	return habits, nil
}

// GetActiveUserHabits retrieves all active habits for a user
func (s *HabitService) GetActiveUserHabits(ctx context.Context, userID uuid.UUID) ([]*models.Habit, error) {
	habits, err := s.habitRepo.GetActiveByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	// Check today's completion for each habit
	for _, habit := range habits {
		completed, err := s.logRepo.CheckTodayCompleted(ctx, habit.ID)
		if err == nil {
			habit.TodayCompleted = completed
		}
	}

	return habits, nil
}

// UpdateHabit updates a habit
func (s *HabitService) UpdateHabit(ctx context.Context, userID, habitID uuid.UUID, req *models.HabitUpdateRequest) (*models.Habit, error) {
	habit, err := s.habitRepo.GetByIDAndUserID(ctx, habitID, userID)
	if err != nil {
		return nil, err
	}

	// Apply updates
	if req.Title != nil {
		habit.Title = *req.Title
	}
	if req.Description != nil {
		habit.Description = req.Description
	}
	if req.Category != nil {
		habit.Category = *req.Category
	}
	if req.Frequency != nil {
		habit.Frequency = *req.Frequency
	}
	if req.IsActive != nil {
		habit.IsActive = *req.IsActive
	}
	if req.IsLearningHabit != nil {
		habit.IsLearningHabit = *req.IsLearningHabit
	}
	if req.Color != nil {
		habit.Color = *req.Color
	}
	if req.Icon != nil {
		habit.Icon = *req.Icon
	}
	if req.ReminderTime != nil {
		habit.ReminderTime = req.ReminderTime
	}

	if err := s.habitRepo.Update(ctx, habit); err != nil {
		return nil, err
	}

	return habit, nil
}

// DeleteHabit soft deletes a habit
func (s *HabitService) DeleteHabit(ctx context.Context, userID, habitID uuid.UUID) error {
	// Verify ownership
	_, err := s.habitRepo.GetByIDAndUserID(ctx, habitID, userID)
	if err != nil {
		return err
	}

	return s.habitRepo.SoftDelete(ctx, habitID)
}

// GetHabitStreak retrieves streak information for a habit
func (s *HabitService) GetHabitStreak(ctx context.Context, userID, habitID uuid.UUID) (*models.Streak, error) {
	// Verify ownership
	_, err := s.habitRepo.GetByIDAndUserID(ctx, habitID, userID)
	if err != nil {
		return nil, err
	}

	return s.streakRepo.GetByHabitID(ctx, habitID)
}

// GetTodayHabitsStatus retrieves today's status for all active habits
func (s *HabitService) GetTodayHabitsStatus(ctx context.Context, userID uuid.UUID) (*models.TodayLogsResponse, error) {
	habits, err := s.habitRepo.GetActiveByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}

	today := time.Now()
	todayLogs, err := s.logRepo.GetTodayLogs(ctx, userID)
	if err != nil {
		return nil, err
	}

	// Create a map of habit ID to log
	logMap := make(map[uuid.UUID]*models.DailyLog)
	for _, log := range todayLogs {
		logMap[log.HabitID] = log
	}

	var habitStatuses []*models.TodayHabitStatus
	for _, habit := range habits {
		status := &models.TodayHabitStatus{
			HabitID:       habit.ID,
			HabitTitle:    habit.Title,
			Category:      string(habit.Category),
			IsLearning:    habit.IsLearningHabit,
			Completed:     false,
			CurrentStreak: habit.CurrentStreak,
		}

		if log, ok := logMap[habit.ID]; ok {
			status.Completed = log.Completed
			status.LearningNote = log.LearningNote
		}

		habitStatuses = append(habitStatuses, status)
	}

	return &models.TodayLogsResponse{
		Date:   today.Format("2006-01-02"),
		Habits: habitStatuses,
	}, nil
}

// GetHabitsUpdatedSince retrieves habits updated since a given time (for sync)
func (s *HabitService) GetHabitsUpdatedSince(ctx context.Context, userID uuid.UUID, since time.Time) ([]*models.Habit, error) {
	return s.habitRepo.GetUpdatedSince(ctx, userID, since)
}
