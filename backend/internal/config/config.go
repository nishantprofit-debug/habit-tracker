package config

import (
	"os"
	"time"
)

// Config holds all configuration for the application
type Config struct {
	// Server
	Port string
	Env  string

	// Database
	DatabaseURL string

	// Redis
	RedisURL string

	// Firebase
	FirebaseProjectID      string
	FirebaseCredentialsJSON string

	// Gemini AI
	GeminiAPIKey string

	// JWT
	JWTSecret     string
	JWTExpiry     time.Duration
	RefreshExpiry time.Duration

	// App Settings
	AllowedOrigins []string
}

// Load loads configuration from environment variables
func Load() *Config {
	return &Config{
		// Server
		Port: getEnv("PORT", "8080"),
		Env:  getEnv("APP_ENV", "development"),

		// Database
		DatabaseURL: getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/habittracker?sslmode=disable"),

		// Redis
		RedisURL: getEnv("REDIS_URL", "redis://localhost:6379"),

		// Firebase
		FirebaseProjectID:      getEnv("FIREBASE_PROJECT_ID", ""),
		FirebaseCredentialsJSON: getEnv("FIREBASE_CREDENTIALS_JSON", ""),

		// Gemini AI
		GeminiAPIKey: getEnv("GEMINI_API_KEY", ""),

		// JWT
		JWTSecret:     getEnv("JWT_SECRET", "your-super-secret-key-change-in-production"),
		JWTExpiry:     parseDuration(getEnv("JWT_EXPIRY", "24h")),
		RefreshExpiry: parseDuration(getEnv("REFRESH_EXPIRY", "168h")), // 7 days

		// App Settings
		AllowedOrigins: []string{"http://localhost:3000", "http://localhost:8080"},
	}
}

// getEnv gets an environment variable or returns a default value.
// It checks for standard keys and custom prefixes requested by the user.
func getEnv(key, defaultValue string) string {
	// 1. Check for custom user-requested keys first (e.g., NISHANT_DATABASE_URL)
	customKey := "NISHANT_" + key
	if value := os.Getenv(customKey); value != "" {
		return value
	}

	// 2. Check for standard keys
	if value := os.Getenv(key); value != "" {
		return value
	}

	return defaultValue
}

// parseDuration parses a duration string or returns a default
func parseDuration(s string) time.Duration {
	d, err := time.ParseDuration(s)
	if err != nil {
		return 24 * time.Hour
	}
	return d
}

// IsDevelopment returns true if running in development mode
func (c *Config) IsDevelopment() bool {
	return c.Env == "development"
}

// IsProduction returns true if running in production mode
func (c *Config) IsProduction() bool {
	return c.Env == "production"
}
