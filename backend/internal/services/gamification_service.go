package services

import (
	"context"
	"math"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// GamificationService handles XP, levels, and badges
type GamificationService struct {
	userRepo *repository.UserRepository
	// In a real app, we'd have an xpLogRepo and badgeRepo
}

// NewGamificationService creates a new GamificationService
func NewGamificationService(userRepo *repository.UserRepository) *GamificationService {
	return &GamificationService{
		userRepo: userRepo,
	}
}

// AwardXP awards XP to a user for a specific action
func (s *GamificationService) AwardXP(ctx context.Context, userID uuid.UUID, action models.XPAction, amount int, referenceID *uuid.UUID) error {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return err
	}

	user.XP += amount
	
	// Check for level up
	newLevel := s.CalculateLevel(user.XP)
	if newLevel > user.Level {
		user.Level = newLevel
		// Trigger level up notification or badge award in the future
	}

	return s.userRepo.Update(ctx, user)
}

// CalculateLevel calculates level based on total XP
// Formula: Level = floor(sqrt(XP / 100)) + 1
func (s *GamificationService) CalculateLevel(xp int) int {
	if xp <= 0 {
		return 1
	}
	return int(math.Floor(math.Sqrt(float64(xp)/100))) + 1
}

// GetXPToNextLevel returns the total XP needed for the next level
func (s *GamificationService) GetXPToNextLevel(currentLevel int) int {
	return (currentLevel * currentLevel) * 100
}

// AwardHabitCompletionXP awards XP for completing a habit
func (s *GamificationService) AwardHabitCompletionXP(ctx context.Context, userID uuid.UUID, habitID uuid.UUID, isStreakBonus bool) error {
	amount := 10
	action := models.ActionHabitComplete
	
	if isStreakBonus {
		amount += 50
		// We could send a separate log for the bonus if needed
	}

	return s.AwardXP(ctx, userID, action, amount, &habitID)
}

// AwardLearningNoteXP awards XP for adding a learning note
func (s *GamificationService) AwardLearningNoteXP(ctx context.Context, userID uuid.UUID, logID uuid.UUID) error {
	return s.AwardXP(ctx, userID, models.ActionHabitComplete, 15, &logID)
}
