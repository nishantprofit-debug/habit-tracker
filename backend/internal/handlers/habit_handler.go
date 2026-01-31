package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
	"github.com/habittracker/backend/internal/services"
)

// HabitHandler handles habit endpoints
type HabitHandler struct {
	habitService *services.HabitService
}

// NewHabitHandler creates a new HabitHandler
func NewHabitHandler(habitService *services.HabitService) *HabitHandler {
	return &HabitHandler{
		habitService: habitService,
	}
}

// GetHabits handles getting all habits for a user
// @Summary Get all habits
// @Tags Habits
// @Security BearerAuth
// @Produce json
// @Success 200 {object} models.HabitListResponse
// @Failure 401 {object} ErrorResponse
// @Router /habits [get]
func (h *HabitHandler) GetHabits(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	habits, err := h.habitService.GetUserHabits(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	var responses []*models.HabitResponse
	for _, habit := range habits {
		responses = append(responses, habit.ToResponse())
	}

	c.JSON(http.StatusOK, models.HabitListResponse{
		Habits:     responses,
		TotalCount: len(responses),
	})
}

// CreateHabit handles creating a new habit
// @Summary Create a new habit
// @Tags Habits
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param body body models.HabitCreateRequest true "Habit creation request"
// @Success 201 {object} models.HabitResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Router /habits [post]
func (h *HabitHandler) CreateHabit(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	var req models.HabitCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_request",
			"message": err.Error(),
		})
		return
	}

	habit, err := h.habitService.CreateHabit(c.Request.Context(), userID.(uuid.UUID), &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "creation_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, habit.ToResponse())
}

// GetHabit handles getting a single habit
// @Summary Get a habit by ID
// @Tags Habits
// @Security BearerAuth
// @Produce json
// @Param id path string true "Habit ID"
// @Success 200 {object} models.HabitResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /habits/{id} [get]
func (h *HabitHandler) GetHabit(c *gin.Context) {
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

	habit, err := h.habitService.GetHabit(c.Request.Context(), userID.(uuid.UUID), habitID)
	if err != nil {
		if err == repository.ErrHabitNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error":   "not_found",
				"message": "Habit not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, habit.ToResponse())
}

// UpdateHabit handles updating a habit
// @Summary Update a habit
// @Tags Habits
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path string true "Habit ID"
// @Param body body models.HabitUpdateRequest true "Habit update request"
// @Success 200 {object} models.HabitResponse
// @Failure 400 {object} ErrorResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /habits/{id} [put]
func (h *HabitHandler) UpdateHabit(c *gin.Context) {
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

	var req models.HabitUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_request",
			"message": err.Error(),
		})
		return
	}

	habit, err := h.habitService.UpdateHabit(c.Request.Context(), userID.(uuid.UUID), habitID, &req)
	if err != nil {
		if err == repository.ErrHabitNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error":   "not_found",
				"message": "Habit not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "update_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, habit.ToResponse())
}

// DeleteHabit handles deleting a habit
// @Summary Delete a habit
// @Tags Habits
// @Security BearerAuth
// @Param id path string true "Habit ID"
// @Success 200 {object} SuccessResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /habits/{id} [delete]
func (h *HabitHandler) DeleteHabit(c *gin.Context) {
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

	if err := h.habitService.DeleteHabit(c.Request.Context(), userID.(uuid.UUID), habitID); err != nil {
		if err == repository.ErrHabitNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error":   "not_found",
				"message": "Habit not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "delete_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Habit deleted successfully",
	})
}

// GetHabitStreak handles getting streak info for a habit
// @Summary Get habit streak
// @Tags Habits
// @Security BearerAuth
// @Produce json
// @Param id path string true "Habit ID"
// @Success 200 {object} models.StreakResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /habits/{id}/streak [get]
func (h *HabitHandler) GetHabitStreak(c *gin.Context) {
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

	streak, err := h.habitService.GetHabitStreak(c.Request.Context(), userID.(uuid.UUID), habitID)
	if err != nil {
		if err == repository.ErrHabitNotFound || err == repository.ErrStreakNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error":   "not_found",
				"message": "Habit or streak not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, streak.ToResponse())
}
