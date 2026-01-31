package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// UserHandler handles user endpoints
type UserHandler struct {
	userRepo *repository.UserRepository
}

// NewUserHandler creates a new UserHandler
func NewUserHandler(userRepo *repository.UserRepository) *UserHandler {
	return &UserHandler{
		userRepo: userRepo,
	}
}

// GetProfile handles getting user profile
// @Summary Get user profile
// @Tags User
// @Security BearerAuth
// @Produce json
// @Success 200 {object} models.UserResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /user/profile [get]
func (h *UserHandler) GetProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	user, err := h.userRepo.GetByID(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "not_found",
			"message": "User not found",
		})
		return
	}

	c.JSON(http.StatusOK, user.ToResponse())
}

// UpdateProfile handles updating user profile
// @Summary Update user profile
// @Tags User
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param body body models.UserUpdateRequest true "Profile update"
// @Success 200 {object} models.UserResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /user/profile [put]
func (h *UserHandler) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	var req models.UserUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_request",
			"message": err.Error(),
		})
		return
	}

	user, err := h.userRepo.GetByID(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "not_found",
			"message": "User not found",
		})
		return
	}

	// Apply updates
	if req.DisplayName != nil {
		user.DisplayName = req.DisplayName
	}
	if req.Timezone != nil {
		user.Timezone = *req.Timezone
	}
	if req.NotificationEnabled != nil {
		user.NotificationEnabled = *req.NotificationEnabled
	}
	if req.MorningReminderTime != nil {
		user.MorningReminderTime = *req.MorningReminderTime
	}
	if req.EveningReminderTime != nil {
		user.EveningReminderTime = *req.EveningReminderTime
	}

	if err := h.userRepo.Update(c.Request.Context(), user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "update_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, user.ToResponse())
}

// UpdateSettings handles updating user notification settings
// @Summary Update user settings
// @Tags User
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param body body models.UserSettingsRequest true "Settings update"
// @Success 200 {object} models.UserResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /user/settings [put]
func (h *UserHandler) UpdateSettings(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	var req models.UserSettingsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_request",
			"message": err.Error(),
		})
		return
	}

	user, err := h.userRepo.GetByID(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "not_found",
			"message": "User not found",
		})
		return
	}

	// Apply settings updates
	if req.NotificationEnabled != nil {
		user.NotificationEnabled = *req.NotificationEnabled
	}
	if req.MorningReminderTime != nil {
		user.MorningReminderTime = *req.MorningReminderTime
	}
	if req.EveningReminderTime != nil {
		user.EveningReminderTime = *req.EveningReminderTime
	}
	if req.FCMToken != nil {
		user.FCMToken = req.FCMToken
	}

	if err := h.userRepo.Update(c.Request.Context(), user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "update_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, user.ToResponse())
}

// DeleteAccount handles user account deletion
// @Summary Delete user account
// @Tags User
// @Security BearerAuth
// @Success 200 {object} SuccessResponse
// @Failure 401 {object} ErrorResponse
// @Router /user/account [delete]
func (h *UserHandler) DeleteAccount(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	if err := h.userRepo.SoftDelete(c.Request.Context(), userID.(uuid.UUID)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "delete_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Account deleted successfully",
	})
}
