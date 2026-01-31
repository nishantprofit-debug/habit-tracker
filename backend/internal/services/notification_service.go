package services

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/config"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// NotificationService handles push notifications
type NotificationService struct {
	userRepo   *repository.UserRepository
	habitRepo  *repository.HabitRepository
	streakRepo *repository.StreakRepository
	config     *config.Config
	httpClient *http.Client
}

// NewNotificationService creates a new NotificationService
func NewNotificationService(
	userRepo *repository.UserRepository,
	habitRepo *repository.HabitRepository,
	streakRepo *repository.StreakRepository,
	cfg *config.Config,
) *NotificationService {
	return &NotificationService{
		userRepo:   userRepo,
		habitRepo:  habitRepo,
		streakRepo: streakRepo,
		config:     cfg,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// NotificationType represents the type of notification
type NotificationType string

const (
	NotificationTypeMorningReminder NotificationType = "morning_reminder"
	NotificationTypeEveningReminder NotificationType = "evening_reminder"
	NotificationTypeStreakAlert     NotificationType = "streak_alert"
	NotificationTypeReportReady     NotificationType = "report_ready"
	NotificationTypeRevisionReminder NotificationType = "revision_reminder"
)

// FCMMessage represents an FCM message
type FCMMessage struct {
	To           string            `json:"to"`
	Notification FCMNotification   `json:"notification"`
	Data         map[string]string `json:"data,omitempty"`
}

// FCMNotification represents the notification payload
type FCMNotification struct {
	Title string `json:"title"`
	Body  string `json:"body"`
}

// SendNotification sends a push notification to a user
func (s *NotificationService) SendNotification(ctx context.Context, userID uuid.UUID, notificationType NotificationType, title, body string, data map[string]string) error {
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return err
	}

	if user.FCMToken == nil || *user.FCMToken == "" {
		return fmt.Errorf("user has no FCM token")
	}

	if !user.NotificationEnabled {
		return nil // Notifications disabled, skip
	}

	return s.sendFCMNotification(*user.FCMToken, title, body, data)
}

// sendFCMNotification sends a notification via FCM
func (s *NotificationService) sendFCMNotification(token, title, body string, data map[string]string) error {
	// For development/testing, just log the notification
	// In production, implement actual FCM sending
	fmt.Printf("FCM Notification - Token: %s, Title: %s, Body: %s\n", token[:20]+"...", title, body)
	return nil
}

// SendMorningReminder sends morning reminder notifications
func (s *NotificationService) SendMorningReminder(ctx context.Context, user *models.User) error {
	habits, err := s.habitRepo.GetActiveByUserID(ctx, user.ID)
	if err != nil {
		return err
	}

	if len(habits) == 0 {
		return nil
	}

	title := "Good morning! ☀️"
	body := fmt.Sprintf("Ready to crush your %d habits today?", len(habits))

	data := map[string]string{
		"type":   string(NotificationTypeMorningReminder),
		"screen": "home",
	}

	return s.SendNotification(ctx, user.ID, NotificationTypeMorningReminder, title, body, data)
}

// SendEveningReminder sends evening reminder notifications
func (s *NotificationService) SendEveningReminder(ctx context.Context, user *models.User, incompleteCount int) error {
	if incompleteCount == 0 {
		return nil
	}

	title := "Don't forget! 🌙"
	body := fmt.Sprintf("You have %d habits left to complete today.", incompleteCount)

	data := map[string]string{
		"type":   string(NotificationTypeEveningReminder),
		"screen": "home",
	}

	return s.SendNotification(ctx, user.ID, NotificationTypeEveningReminder, title, body, data)
}

// SendStreakAtRiskAlert sends streak at risk notifications
func (s *NotificationService) SendStreakAtRiskAlert(ctx context.Context, user *models.User, habitTitle string, streak int) error {
	title := "Streak at risk! 🔥"
	body := fmt.Sprintf("Your %d-day streak for '%s' is at risk! Complete it now.", streak, habitTitle)

	data := map[string]string{
		"type":   string(NotificationTypeStreakAlert),
		"screen": "home",
	}

	return s.SendNotification(ctx, user.ID, NotificationTypeStreakAlert, title, body, data)
}

// SendReportReadyNotification sends report ready notifications
func (s *NotificationService) SendReportReadyNotification(ctx context.Context, user *models.User, month string) error {
	title := "Your report is ready! 📊"
	body := fmt.Sprintf("Your %s progress report is ready. See your achievements!", month)

	data := map[string]string{
		"type":   string(NotificationTypeReportReady),
		"screen": "reports",
		"month":  month,
	}

	return s.SendNotification(ctx, user.ID, NotificationTypeReportReady, title, body, data)
}

// SendRevisionReminderNotification sends revision reminder notifications
func (s *NotificationService) SendRevisionReminderNotification(ctx context.Context, user *models.User, skill string, days int) error {
	title := "Time to revise! 📚"
	body := fmt.Sprintf("AI suggests revising '%s' for %d days. Ready to refresh?", skill, days)

	data := map[string]string{
		"type":   string(NotificationTypeRevisionReminder),
		"screen": "revisions",
	}

	return s.SendNotification(ctx, user.ID, NotificationTypeRevisionReminder, title, body, data)
}

// CheckAndSendStreakAlerts checks for at-risk streaks and sends alerts
func (s *NotificationService) CheckAndSendStreakAlerts(ctx context.Context) error {
	// This would be called by a cron job
	// Implementation would iterate through users and check their streaks
	return nil
}

// ScheduleNotification schedules a notification for later
type ScheduledNotification struct {
	UserID           uuid.UUID
	NotificationType NotificationType
	Title            string
	Body             string
	Data             map[string]string
	ScheduledFor     time.Time
}

// ScheduleNotificationPayload is used for serialization
type ScheduleNotificationPayload struct {
	UserID           string            `json:"user_id"`
	NotificationType string            `json:"notification_type"`
	Title            string            `json:"title"`
	Body             string            `json:"body"`
	Data             map[string]string `json:"data"`
	ScheduledFor     string            `json:"scheduled_for"`
}

// ToJSON converts the scheduled notification to JSON
func (sn *ScheduledNotification) ToJSON() ([]byte, error) {
	payload := ScheduleNotificationPayload{
		UserID:           sn.UserID.String(),
		NotificationType: string(sn.NotificationType),
		Title:            sn.Title,
		Body:             sn.Body,
		Data:             sn.Data,
		ScheduledFor:     sn.ScheduledFor.Format(time.RFC3339),
	}
	return json.Marshal(payload)
}
