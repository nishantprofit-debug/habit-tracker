package services

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// ReportService handles report business logic
type ReportService struct {
	reportRepo   *repository.ReportRepository
	habitRepo    *repository.HabitRepository
	logRepo      *repository.LogRepository
	revisionRepo *repository.RevisionRepository
	geminiSvc    *GeminiService
}

// NewReportService creates a new ReportService
func NewReportService(
	reportRepo *repository.ReportRepository,
	habitRepo *repository.HabitRepository,
	logRepo *repository.LogRepository,
	revisionRepo *repository.RevisionRepository,
	geminiSvc *GeminiService,
) *ReportService {
	return &ReportService{
		reportRepo:   reportRepo,
		habitRepo:    habitRepo,
		logRepo:      logRepo,
		revisionRepo: revisionRepo,
		geminiSvc:    geminiSvc,
	}
}

// GenerateReport generates a monthly report for a user
func (s *ReportService) GenerateReport(ctx context.Context, userID uuid.UUID, year, month int) (*models.Report, error) {
	// Create report month date (first day of month)
	reportMonth := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)

	// Check if report already exists
	existing, err := s.reportRepo.GetByUserAndMonth(ctx, userID, reportMonth)
	if err == nil && existing != nil {
		// Report exists, return it
		return existing, nil
	}

	// Gather habit completion data
	habitData, err := s.reportRepo.GetHabitCompletionDataForMonth(ctx, userID, year, month)
	if err != nil {
		return nil, err
	}

	// Get learning notes
	learningNotes, err := s.logRepo.GetLearningNotesByUserAndMonth(ctx, userID, year, month)
	if err != nil {
		return nil, err
	}

	// Add learning notes to habit data
	for _, habit := range habitData {
		if notes, ok := learningNotes[habit.HabitID]; ok {
			habit.LearningNotes = notes
		}
	}

	// Calculate overall completion
	var totalCompletion float64
	for _, habit := range habitData {
		totalCompletion += habit.CompletionRate
	}
	if len(habitData) > 0 {
		totalCompletion /= float64(len(habitData))
	}

	// Prepare input for AI
	input := &models.ReportGenerationInput{
		UserID:            userID,
		Month:             reportMonth.Format("2006-01"),
		Habits:            habitData,
		TotalHabits:       len(habitData),
		OverallCompletion: totalCompletion,
	}

	// Generate AI report
	reportContent, err := s.geminiSvc.GenerateMonthlyReport(ctx, input)
	if err != nil {
		return nil, err
	}

	// Serialize report content
	contentJSON, err := json.Marshal(reportContent)
	if err != nil {
		return nil, err
	}

	// Serialize habits completion percentage
	habitsPercentage := make(map[string]float64)
	for _, habit := range habitData {
		habitsPercentage[habit.HabitID.String()] = habit.CompletionRate
	}
	habitsPercentageJSON, err := json.Marshal(habitsPercentage)
	if err != nil {
		return nil, err
	}

	// Serialize revision suggestions
	suggestionsJSON, err := json.Marshal(reportContent.RevisionSuggestions)
	if err != nil {
		return nil, err
	}

	// Create report
	report := &models.Report{
		UserID:                    userID,
		ReportMonth:               reportMonth,
		ReportContent:             contentJSON,
		SkillsLearned:             reportContent.SkillsLearned,
		HabitsCompletedPercentage: habitsPercentageJSON,
		RevisionSuggestions:       suggestionsJSON,
	}

	if err := s.reportRepo.Create(ctx, report); err != nil {
		return nil, err
	}

	// Create revision habits from suggestions
	if len(reportContent.RevisionSuggestions) > 0 {
		if err := s.reportRepo.CreateRevisionHabitsFromReport(ctx, userID, reportMonth, reportContent.RevisionSuggestions); err != nil {
			log.Printf("failed to create revision habits for user %s: %v", userID, err)
		}
	}

	return report, nil
}

// GetReport retrieves a report by month
func (s *ReportService) GetReport(ctx context.Context, userID uuid.UUID, monthStr string) (*models.Report, error) {
	reportMonth, err := time.Parse("2006-01", monthStr)
	if err != nil {
		return nil, err
	}

	return s.reportRepo.GetByUserAndMonth(ctx, userID, reportMonth)
}

// GetAllReports retrieves all reports for a user
func (s *ReportService) GetAllReports(ctx context.Context, userID uuid.UUID) ([]*models.Report, error) {
	return s.reportRepo.GetByUser(ctx, userID)
}

// RegenerateReport regenerates a report for a month
func (s *ReportService) RegenerateReport(ctx context.Context, userID uuid.UUID, year, month int) (*models.Report, error) {
	reportMonth := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)

	// Delete existing report if any
	existing, err := s.reportRepo.GetByUserAndMonth(ctx, userID, reportMonth)
	if err == nil && existing != nil {
		// Update instead of create
		habitData, err := s.reportRepo.GetHabitCompletionDataForMonth(ctx, userID, year, month)
		if err != nil {
			return nil, err
		}

		learningNotes, err := s.logRepo.GetLearningNotesByUserAndMonth(ctx, userID, year, month)
		if err != nil {
			return nil, err
		}

		for _, habit := range habitData {
			if notes, ok := learningNotes[habit.HabitID]; ok {
				habit.LearningNotes = notes
			}
		}

		var totalCompletion float64
		for _, habit := range habitData {
			totalCompletion += habit.CompletionRate
		}
		if len(habitData) > 0 {
			totalCompletion /= float64(len(habitData))
		}

		input := &models.ReportGenerationInput{
			UserID:            userID,
			Month:             reportMonth.Format("2006-01"),
			Habits:            habitData,
			TotalHabits:       len(habitData),
			OverallCompletion: totalCompletion,
		}

		reportContent, err := s.geminiSvc.GenerateMonthlyReport(ctx, input)
		if err != nil {
			return nil, err
		}

		contentJSON, err := json.Marshal(reportContent)
		if err != nil {
			return nil, err
		}
		suggestionsJSON, err := json.Marshal(reportContent.RevisionSuggestions)
		if err != nil {
			return nil, err
		}
		habitsPercentage := make(map[string]float64)
		for _, habit := range habitData {
			habitsPercentage[habit.HabitID.String()] = habit.CompletionRate
		}
		habitsPercentageJSON, err := json.Marshal(habitsPercentage)
		if err != nil {
			return nil, err
		}

		existing.ReportContent = contentJSON
		existing.SkillsLearned = reportContent.SkillsLearned
		existing.HabitsCompletedPercentage = habitsPercentageJSON
		existing.RevisionSuggestions = suggestionsJSON

		if err := s.reportRepo.Update(ctx, existing); err != nil {
			return nil, err
		}

		return existing, nil
	}

	// Generate new report
	return s.GenerateReport(ctx, userID, year, month)
}
