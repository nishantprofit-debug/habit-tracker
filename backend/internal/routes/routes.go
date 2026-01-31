package routes

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/habittracker/backend/internal/config"
	"github.com/habittracker/backend/internal/handlers"
	"github.com/habittracker/backend/internal/middleware"
	"github.com/habittracker/backend/internal/repository"
	"github.com/habittracker/backend/internal/services"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
)

// SetupRouter configures all routes and middleware
func SetupRouter(db *pgxpool.Pool, redis *redis.Client, cfg *config.Config) *gin.Engine {
	// Set Gin mode
	if cfg.IsProduction() {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.New()

	// Global middleware
	router.Use(gin.Recovery())
	router.Use(middleware.LoggingMiddleware())
	router.Use(middleware.CORSMiddleware(cfg))
	router.Use(middleware.RateLimitMiddleware(100, time.Minute)) // 100 req/min

	// Initialize repositories
	userRepo := repository.NewUserRepository(db)
	habitRepo := repository.NewHabitRepository(db)
	logRepo := repository.NewLogRepository(db)
	streakRepo := repository.NewStreakRepository(db)
	reportRepo := repository.NewReportRepository(db)
	revisionRepo := repository.NewRevisionRepository(db)

	// Initialize services
	authService := services.NewAuthService(userRepo, cfg)
	gamificationService := services.NewGamificationService(userRepo)
	habitService := services.NewHabitService(habitRepo, logRepo, streakRepo)
	logService := services.NewLogService(logRepo, habitRepo, streakRepo, gamificationService)
	geminiService := services.NewGeminiService(cfg)
	reportService := services.NewReportService(reportRepo, habitRepo, logRepo, revisionRepo, geminiService)
	syncService := services.NewSyncService(habitRepo, logRepo)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(authService)
	userHandler := handlers.NewUserHandler(userRepo)
	habitHandler := handlers.NewHabitHandler(habitService)
	logHandler := handlers.NewLogHandler(logService, habitService)
	reportHandler := handlers.NewReportHandler(reportService)
	revisionHandler := handlers.NewRevisionHandler(revisionRepo, habitRepo)
	syncHandler := handlers.NewSyncHandler(syncService)

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "healthy",
			"service": "habit-tracker-api",
			"version": "1.0.0",
		})
	})

	// API v1 routes
	v1 := router.Group("/api/v1")
	{
		// Auth routes (public)
		auth := v1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/refresh", authHandler.Refresh)

			// Protected auth routes
			authProtected := auth.Group("")
			authProtected.Use(middleware.AuthMiddleware(authService))
			{
				authProtected.POST("/logout", authHandler.Logout)
				authProtected.PUT("/fcm-token", authHandler.UpdateFCMToken)
			}
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(middleware.AuthMiddleware(authService))
		{
			// User routes
			user := protected.Group("/user")
			{
				user.GET("/profile", userHandler.GetProfile)
				user.PUT("/profile", userHandler.UpdateProfile)
				user.PUT("/settings", userHandler.UpdateSettings)
				user.DELETE("/account", userHandler.DeleteAccount)
			}

			// Habit routes
			habits := protected.Group("/habits")
			{
				habits.GET("", habitHandler.GetHabits)
				habits.POST("", habitHandler.CreateHabit)
				habits.GET("/:id", habitHandler.GetHabit)
				habits.PUT("/:id", habitHandler.UpdateHabit)
				habits.DELETE("/:id", habitHandler.DeleteHabit)
				habits.GET("/:id/streak", habitHandler.GetHabitStreak)
			}

			// Log routes
			logs := protected.Group("/logs")
			{
				logs.GET("", logHandler.GetLogs)
				logs.GET("/today", logHandler.GetTodayLogs)
				logs.POST("", logHandler.CreateOrUpdateLog)
				logs.GET("/habit/:id", logHandler.GetLogsByHabit)
				logs.GET("/calendar/:month", logHandler.GetCalendarData)
				logs.POST("/quick-complete/:habit_id", logHandler.QuickComplete)
			}

			// Report routes
			reports := protected.Group("/reports")
			{
				reports.GET("", reportHandler.GetReports)
				reports.GET("/:month", reportHandler.GetReport)
				reports.POST("/generate", reportHandler.GenerateReport)
				reports.POST("/regenerate", reportHandler.RegenerateReport)
			}

			// Revision routes
			revisions := protected.Group("/revisions")
			{
				revisions.GET("", revisionHandler.GetRevisions)
				revisions.PUT("/:id/accept", revisionHandler.AcceptRevision)
				revisions.PUT("/:id/decline", revisionHandler.DeclineRevision)
			}

			// Sync routes
			sync := protected.Group("/sync")
			{
				sync.POST("/push", syncHandler.PushChanges)
				sync.GET("/pull", syncHandler.PullChanges)
				sync.GET("/status", syncHandler.GetSyncStatus)
			}
		}
	}

	return router
}
