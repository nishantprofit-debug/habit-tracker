package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/services"
)

// SyncHandler handles sync endpoints
type SyncHandler struct {
	syncService *services.SyncService
}

// NewSyncHandler creates a new SyncHandler
func NewSyncHandler(syncService *services.SyncService) *SyncHandler {
	return &SyncHandler{
		syncService: syncService,
	}
}

// PushChanges handles pushing offline changes to server
// @Summary Push offline changes
// @Tags Sync
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param body body models.SyncPushRequest true "Sync push request"
// @Success 200 {object} models.SyncPushResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /sync/push [post]
func (h *SyncHandler) PushChanges(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	var req models.SyncPushRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_request",
			"message": err.Error(),
		})
		return
	}

	response, err := h.syncService.PushChanges(c.Request.Context(), userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "sync_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// PullChanges handles pulling latest data from server
// @Summary Pull latest data
// @Tags Sync
// @Security BearerAuth
// @Produce json
// @Param last_synced_at query string false "Last synced timestamp (RFC3339)"
// @Success 200 {object} models.SyncPullResponse
// @Failure 401 {object} ErrorResponse
// @Router /sync/pull [get]
func (h *SyncHandler) PullChanges(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	var lastSyncedAt *time.Time
	if lastSyncedStr := c.Query("last_synced_at"); lastSyncedStr != "" {
		t, err := time.Parse(time.RFC3339, lastSyncedStr)
		if err == nil {
			lastSyncedAt = &t
		}
	}

	response, err := h.syncService.PullChanges(c.Request.Context(), userID.(uuid.UUID), lastSyncedAt)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "sync_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, response)
}

// GetSyncStatus handles getting sync status
// @Summary Get sync status
// @Tags Sync
// @Security BearerAuth
// @Produce json
// @Success 200 {object} models.SyncStatusResponse
// @Failure 401 {object} ErrorResponse
// @Router /sync/status [get]
func (h *SyncHandler) GetSyncStatus(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	status, err := h.syncService.GetSyncStatus(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, status)
}
