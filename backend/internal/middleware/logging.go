package middleware

import (
	"log"
	"time"

	"github.com/gin-gonic/gin"
)

// LoggingMiddleware creates request logging middleware
func LoggingMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Start timer
		start := time.Now()

		// Process request
		c.Next()

		// Calculate latency
		latency := time.Since(start)

		// Get status code
		status := c.Writer.Status()

		// Get client IP
		clientIP := c.ClientIP()

		// Get request method and path
		method := c.Request.Method
		path := c.Request.URL.Path

		// Log request
		log.Printf("[%s] %s %s %d %v %s",
			method,
			path,
			clientIP,
			status,
			latency,
			c.Errors.ByType(gin.ErrorTypePrivate).String(),
		)
	}
}
