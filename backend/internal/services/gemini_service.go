package services

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/habittracker/backend/internal/config"
	"github.com/habittracker/backend/internal/models"
)

// GeminiService handles Gemini AI integration
type GeminiService struct {
	apiKey     string
	httpClient *http.Client
}

// NewGeminiService creates a new GeminiService
func NewGeminiService(cfg *config.Config) *GeminiService {
	return &GeminiService{
		apiKey: cfg.GeminiAPIKey,
		httpClient: &http.Client{
			Timeout: 60 * time.Second,
		},
	}
}

// GeminiRequest represents the request to Gemini API
type GeminiRequest struct {
	Contents []GeminiContent `json:"contents"`
}

// GeminiContent represents content in Gemini request
type GeminiContent struct {
	Parts []GeminiPart `json:"parts"`
}

// GeminiPart represents a part of content
type GeminiPart struct {
	Text string `json:"text"`
}

// GeminiResponse represents the response from Gemini API
type GeminiResponse struct {
	Candidates []struct {
		Content struct {
			Parts []struct {
				Text string `json:"text"`
			} `json:"parts"`
		} `json:"content"`
	} `json:"candidates"`
}

// GenerateMonthlyReport generates a monthly AI report
func (s *GeminiService) GenerateMonthlyReport(ctx context.Context, input *models.ReportGenerationInput) (*models.ReportContent, error) {
	if s.apiKey == "" {
		// Return a mock report if API key is not configured
		return s.generateMockReport(input), nil
	}

	prompt := s.buildReportPrompt(input)

	response, err := s.callGeminiAPI(ctx, prompt)
	if err != nil {
		// Fall back to mock report on error
		return s.generateMockReport(input), nil
	}

	// Parse the response
	var reportContent models.ReportContent
	if err := json.Unmarshal([]byte(response), &reportContent); err != nil {
		// Try to extract JSON from the response
		reportContent = s.parseReportFromText(response, input)
	}

	return &reportContent, nil
}

// buildReportPrompt builds the prompt for report generation
func (s *GeminiService) buildReportPrompt(input *models.ReportGenerationInput) string {
	habitsJSON, _ := json.MarshalIndent(input.Habits, "", "  ")

	return fmt.Sprintf(`You are an AI assistant for a habit tracking app. Generate a monthly progress report based on the following data.

User's habit data for %s:
%s

Total habits tracked: %d
Overall completion rate: %.1f%%

Generate a JSON response with the following structure:
{
  "summary": "A 2-3 sentence motivational summary of the month",
  "improvements": ["Array of 2-4 specific improvements the user made"],
  "skills_learned": ["Array of skills/topics learned from the learning notes"],
  "areas_to_improve": ["Array of 1-3 areas where the user could improve"],
  "revision_suggestions": [
    {
      "skill": "Name of skill to revise",
      "reason": "Why this skill should be revised",
      "suggested_duration_days": 7,
      "daily_minutes": 30
    }
  ],
  "motivational_note": "A short encouraging message"
}

Rules:
1. Be encouraging but honest
2. Base skills_learned on the learning_notes in the data
3. Suggest revisions for skills learned 2-4 weeks ago
4. Keep the response concise and actionable
5. Only output valid JSON, no other text

JSON Response:`, input.Month, string(habitsJSON), input.TotalHabits, input.OverallCompletion)
}

// callGeminiAPI calls the Gemini API
func (s *GeminiService) callGeminiAPI(ctx context.Context, prompt string) (string, error) {
	url := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=%s", s.apiKey)

	reqBody := GeminiRequest{
		Contents: []GeminiContent{
			{
				Parts: []GeminiPart{
					{Text: prompt},
				},
			},
		},
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", url, bytes.NewBuffer(jsonBody))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("Gemini API error: %s", string(body))
	}

	var geminiResp GeminiResponse
	if err := json.Unmarshal(body, &geminiResp); err != nil {
		return "", err
	}

	if len(geminiResp.Candidates) == 0 || len(geminiResp.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("empty response from Gemini")
	}

	return geminiResp.Candidates[0].Content.Parts[0].Text, nil
}

// parseReportFromText attempts to extract report data from text response
func (s *GeminiService) parseReportFromText(text string, input *models.ReportGenerationInput) models.ReportContent {
	// Try to find JSON in the text
	start := -1
	end := -1
	braceCount := 0

	for i, c := range text {
		if c == '{' {
			if start == -1 {
				start = i
			}
			braceCount++
		} else if c == '}' {
			braceCount--
			if braceCount == 0 && start != -1 {
				end = i + 1
				break
			}
		}
	}

	if start != -1 && end != -1 {
		jsonStr := text[start:end]
		var report models.ReportContent
		if err := json.Unmarshal([]byte(jsonStr), &report); err == nil {
			return report
		}
	}

	// Fall back to mock report
	return *s.generateMockReport(input)
}

// generateMockReport generates a mock report when Gemini is unavailable
func (s *GeminiService) generateMockReport(input *models.ReportGenerationInput) *models.ReportContent {
	// Extract skills from learning notes
	var skillsLearned []string
	skillSet := make(map[string]bool)

	for _, habit := range input.Habits {
		for _, note := range habit.LearningNotes {
			if note != "" && !skillSet[note] {
				skillSet[note] = true
				if len(skillsLearned) < 5 {
					skillsLearned = append(skillsLearned, note)
				}
			}
		}
	}

	if len(skillsLearned) == 0 {
		skillsLearned = []string{"Consistent practice", "Building good habits"}
	}

	// Generate improvements
	var improvements []string
	for _, habit := range input.Habits {
		if habit.CompletionRate >= 70 {
			improvements = append(improvements, fmt.Sprintf("Great consistency with %s (%.0f%% completion)", habit.HabitTitle, habit.CompletionRate))
		}
		if len(improvements) >= 3 {
			break
		}
	}

	if len(improvements) == 0 {
		improvements = []string{"Started tracking habits consistently", "Building awareness of daily routines"}
	}

	// Generate areas to improve
	var areasToImprove []string
	for _, habit := range input.Habits {
		if habit.CompletionRate < 50 {
			areasToImprove = append(areasToImprove, fmt.Sprintf("Consider adjusting %s - currently at %.0f%% completion", habit.HabitTitle, habit.CompletionRate))
		}
		if len(areasToImprove) >= 2 {
			break
		}
	}

	if len(areasToImprove) == 0 {
		areasToImprove = []string{"Keep pushing for higher completion rates"}
	}

	// Generate revision suggestions
	var revisionSuggestions []models.RevisionSuggestion
	for _, skill := range skillsLearned[:min(2, len(skillsLearned))] {
		revisionSuggestions = append(revisionSuggestions, models.RevisionSuggestion{
			Skill:                 skill,
			Reason:                "Learned recently - reinforce through revision",
			SuggestedDurationDays: 7,
			DailyMinutes:          30,
		})
	}

	return &models.ReportContent{
		Summary:             fmt.Sprintf("You tracked %d habits this month with an overall completion rate of %.1f%%. Keep up the great work building consistent routines!", input.TotalHabits, input.OverallCompletion),
		Improvements:        improvements,
		SkillsLearned:       skillsLearned,
		AreasToImprove:      areasToImprove,
		RevisionSuggestions: revisionSuggestions,
		MotivationalNote:    "Every day you show up is a win. Keep building those positive habits!",
	}
}
