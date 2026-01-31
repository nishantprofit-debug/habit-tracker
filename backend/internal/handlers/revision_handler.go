package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/habittracker/backend/internal/models"
	"github.com/habittracker/backend/internal/repository"
)

// RevisionHandler handles revision endpoints
type RevisionHandler struct {
	revisionRepo *repository.RevisionRepository
	habitRepo    *repository.HabitRepository
}

// NewRevisionHandler creates a new RevisionHandler
func NewRevisionHandler(revisionRepo *repository.RevisionRepository, habitRepo *repository.HabitRepository) *RevisionHandler {
	return &RevisionHandler{
		revisionRepo: revisionRepo,
		habitRepo:    habitRepo,
	}
}

// GetRevisions handles getting revision suggestions for a user
// @Summary Get revision suggestions
// @Tags Revisions
// @Security BearerAuth
// @Produce json
// @Success 200 {object} models.RevisionHabitListResponse
// @Failure 401 {object} ErrorResponse
// @Router /revisions [get]
func (h *RevisionHandler) GetRevisions(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	revisions, err := h.revisionRepo.GetPendingByUser(c.Request.Context(), userID.(uuid.UUID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	var responses []*models.RevisionHabitResponse
	for _, revision := range revisions {
		responses = append(responses, revision.ToResponse())
	}

	c.JSON(http.StatusOK, models.RevisionHabitListResponse{
		Revisions:  responses,
		TotalCount: len(responses),
	})
}

// AcceptRevision handles accepting a revision suggestion
// @Summary Accept revision suggestion
// @Tags Revisions
// @Security BearerAuth
// @Produce json
// @Param id path string true "Revision ID"
// @Success 200 {object} models.HabitResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /revisions/{id}/accept [put]
func (h *RevisionHandler) AcceptRevision(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	revisionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_id",
			"message": "Invalid revision ID",
		})
		return
	}

	revision, err := h.revisionRepo.GetByIDAndUserID(c.Request.Context(), revisionID, userID.(uuid.UUID))
	if err != nil {
		if err == repository.ErrRevisionNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error":   "not_found",
				"message": "Revision not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	if revision.Status != models.RevisionStatusPending {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_status",
			"message": "Revision is not pending",
		})
		return
	}

	habit, err := h.revisionRepo.AcceptRevision(c.Request.Context(), revision, h.habitRepo)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "accept_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, habit.ToResponse())
}

// DeclineRevision handles declining a revision suggestion
// @Summary Decline revision suggestion
// @Tags Revisions
// @Security BearerAuth
// @Param id path string true "Revision ID"
// @Success 200 {object} SuccessResponse
// @Failure 401 {object} ErrorResponse
// @Failure 404 {object} ErrorResponse
// @Router /revisions/{id}/decline [put]
func (h *RevisionHandler) DeclineRevision(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error":   "unauthorized",
			"message": "User not authenticated",
		})
		return
	}

	revisionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_id",
			"message": "Invalid revision ID",
		})
		return
	}

	revision, err := h.revisionRepo.GetByIDAndUserID(c.Request.Context(), revisionID, userID.(uuid.UUID))
	if err != nil {
		if err == repository.ErrRevisionNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error":   "not_found",
				"message": "Revision not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "fetch_failed",
			"message": err.Error(),
		})
		return
	}

	if revision.Status != models.RevisionStatusPending {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "invalid_status",
			"message": "Revision is not pending",
		})
		return
	}

	if err := h.revisionRepo.UpdateStatus(c.Request.Context(), revisionID, models.RevisionStatusDeclined); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "decline_failed",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Revision declined successfully",
	})
}
