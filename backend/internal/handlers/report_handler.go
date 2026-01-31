package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/repository"
	"github.com/habittracker/backend/internal/services"
)

// ReportHandler handles report endpoints
type ReportHandler struct {
	reportService *services.ReportService
}

// NewReportHandler creates a new ReportHandler
func NewReportHandler(reportService *services.ReportService) *ReportHandler {
	return &ReportHandler{
		reportService: reportService,
	}
}

// GetReports handles getting all reports for a user
// @Summary Get all reports
// @Tags Reports
// @Security BearerAuth
// @Produce json
// @Success 200 {object} models.ReportListResponse
// @Failure 401 {object} ErrorResponse
// @Router /reports [get]
func (h *ReportHandler) GetReports(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	reports, err := h.reportService.GetAllReports(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	var responses []*interface{}
	for _, report := range reports {
		resp, err := report.ToResponse()
		if err != nil {
			continue
		}
		var r interface{} = resp
		responses = append(responses, &r)
	}

	c.JSON(http.StatusOK, gin.H{
		"reports":     responses,
		"total_count": len(responses),
	})
}

// GetReport handles getting a specific report by month
// @Summary Get report by month
// @Tags Reports
// @Security BearerAuth
// @Produce json
// @Param month path string true "Month (YYYY-MM)"
// @Success 200 {object} models.ReportResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /reports/{month} [get]
func (h *ReportHandler) GetReport(c *gin.Context) {
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

	report, err := h.reportService.GetReport(c.Request.Context(), userID.(uuid.UUID), monthStr)
	if err != nil {
		if err == repository.ErrReportNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error":   "not_found",
				"message": "Report not found for this month",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	resp, err := report.ToResponse()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "parse_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// GenerateReport handles manual report generation
// @Summary Generate monthly report
// @Tags Reports
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param year query int true "Year"
// @Param month query int true "Month (1-12)"
// @Success 200 {object} models.ReportResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /reports/generate [post]
func (h *ReportHandler) GenerateReport(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	yearStr := c.Query("year")
	monthStr := c.Query("month")

	if yearStr == "" || monthStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "missing_params",
			"message": "Year and month are required",
		})
		return
	}

	year, err := strconv.Atoi(yearStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_year",
			"message": "Invalid year",
		})
		return
	}

	month, err := strconv.Atoi(monthStr)
	if err != nil || month < 1 || month > 12 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_month",
			"message": "Month must be between 1 and 12",
		})
		return
	}

	report, err := h.reportService.GenerateReport(c.Request.Context(), userID.(uuid.UUID), year, month)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "generation_failed",
			"message": err.Error(),
		})
		return
	}

	resp, err := report.ToResponse()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "parse_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}

// RegenerateReport handles regenerating a report
// @Summary Regenerate monthly report
// @Tags Reports
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param year query int true "Year"
// @Param month query int true "Month (1-12)"
// @Success 200 {object} models.ReportResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /reports/regenerate [post]
func (h *ReportHandler) RegenerateReport(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	yearStr := c.Query("year")
	monthStr := c.Query("month")

	if yearStr == "" || monthStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "missing_params",
			"message": "Year and month are required",
		})
		return
	}

	year, err := strconv.Atoi(yearStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_year",
			"message": "Invalid year",
		})
		return
	}

	month, err := strconv.Atoi(monthStr)
	if err != nil || month < 1 || month > 12 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_month",
			"message": "Month must be between 1 and 12",
		})
		return
	}

	report, err := h.reportService.RegenerateReport(c.Request.Context(), userID.(uuid.UUID), year, month)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "generation_failed",
			"message": err.Error(),
		})
		return
	}

	resp, err := report.ToResponse()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "parse_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, resp)
}
