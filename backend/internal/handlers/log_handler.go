package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/services"
)

// LogHandler handles daily log endpoints
type LogHandler struct {
	logService   *services.LogService
	habitService *services.HabitService
}

// NewLogHandler creates a new LogHandler
func NewLogHandler(logService *services.LogService, habitService *services.HabitService) *LogHandler {
	return &LogHandler{
		logService:   logService,
		habitService: habitService,
	}
}

// GetLogs handles getting logs with date filters
// @Summary Get daily logs
// @Tags Logs
// @Security BearerAuth
// @Produce json
// @Param start_date query string false "Start date (YYYY-MM-DD)"
// @Param end_date query string false "End date (YYYY-MM-DD)"
// @Success 200 {object} models.DailyLogListResponse
// @Failure 401 {object} ErrorResponse
// @Router /logs [get]
func (h *LogHandler) GetLogs(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	if startDate == "" || endDate == "" {
		// Default to today
		startDate = "2020-01-01"
		endDate = "2099-12-31"
	}

	logs, err := h.logService.GetLogsByDateRange(c.Request.Context(), userID.(uuid.UUID), startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	var responses []*models.DailyLogResponse
	for _, log := range logs {
		responses = append(responses, log.ToResponse())
	}

	c.JSON(http.StatusOK, models.DailyLogListResponse{
		Logs:       responses,
		TotalCount: len(responses),
	})
}

// GetTodayLogs handles getting today's logs
// @Summary Get today's logs
// @Tags Logs
// @Security BearerAuth
// @Produce json
// @Success 200 {object} models.TodayLogsResponse
// @Failure 401 {object} ErrorResponse
// @Router /logs/today [get]
func (h *LogHandler) GetTodayLogs(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	todayStatus, err := h.habitService.GetTodayHabitsStatus(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, todayStatus)
}

// CreateOrUpdateLog handles creating or updating a daily log
// @Summary Create or update a daily log
// @Tags Logs
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param body body models.DailyLogCreateRequest true "Log creation request"
// @Success 200 {object} models.DailyLogResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /logs [post]
func (h *LogHandler) CreateOrUpdateLog(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	var req models.DailyLogCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_request",
			"message": err.Error(),
		})
		return
	}

	log, err := h.logService.CreateOrUpdateLog(c.Request.Context(), userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "creation_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, log.ToResponse())
}

// GetLogsByHabit handles getting logs for a specific habit
// @Summary Get logs for a habit
// @Tags Logs
// @Security BearerAuth
// @Produce json
// @Param id path string true "Habit ID"
// @Param limit query int false "Limit" default(30)
// @Param offset query int false "Offset" default(0)
// @Success 200 {object} models.DailyLogListResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /logs/habit/{id} [get]
func (h *LogHandler) GetLogsByHabit(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	habitID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_id",
			"message": "Invalid habit ID",
		})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "30"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	logs, err := h.logService.GetLogsByHabit(c.Request.Context(), userID.(uuid.UUID), habitID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	var responses []*models.DailyLogResponse
	for _, log := range logs {
		responses = append(responses, log.ToResponse())
	}

	c.JSON(http.StatusOK, models.DailyLogListResponse{
		Logs:       responses,
		TotalCount: len(responses),
	})
}

// GetCalendarData handles getting calendar view data for a month
// @Summary Get calendar data for a month
// @Tags Logs
// @Security BearerAuth
// @Produce json
// @Param month path string true "Month (YYYY-MM)"
// @Success 200 {object} models.CalendarMonthResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /logs/calendar/{month} [get]
func (h *LogHandler) GetCalendarData(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	monthStr := c.Param("month")
	if len(monthStr) != 7 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_month",
			"message": "Month format should be YYYY-MM",
		})
		return
	}

	year, err := strconv.Atoi(monthStr[:4])
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_year",
			"message": "Invalid year",
		})
		return
	}

	month, err := strconv.Atoi(monthStr[5:7])
	if err != nil || month < 1 || month > 12 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_month",
			"message": "Invalid month",
		})
		return
	}

	calendar, err := h.logService.GetCalendarData(c.Request.Context(), userID.(uuid.UUID), year, month)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, calendar)
}

// QuickComplete handles quickly marking a habit as complete for today
// @Summary Quick complete a habit for today
// @Tags Logs
// @Security BearerAuth
// @Produce json
// @Param habit_id path string true "Habit ID"
// @Success 200 {object} models.DailyLogResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /logs/quick-complete/{habit_id} [post]
func (h *LogHandler) QuickComplete(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	habitID, err := uuid.Parse(c.Param("habit_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_id",
			"message": "Invalid habit ID",
		})
		return
	}

	log, err := h.logService.QuickComplete(c.Request.Context(), userID.(uuid.UUID), habitID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "completion_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, log.ToResponse())
}
