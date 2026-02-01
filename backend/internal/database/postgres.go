package database

import (
	"context"
	"fmt"
	"net"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// NewPostgresConnection creates a new PostgreSQL connection pool
func NewPostgresConnection(databaseURL string) (*pgxpool.Pool, error) {
	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse database URL: %w", err)
	}

	// Force IPv4 connections to work around Render's lack of IPv6 support
	// This custom dialer resolves hostnames to IPv4 addresses only
	config.ConnConfig.LookupFunc = func(ctx context.Context, host string) ([]string, error) {
		// Use custom resolver that only returns IPv4 addresses
		resolver := &net.Resolver{
			PreferGo: true,
		}

		addrs, err := resolver.LookupHost(ctx, host)
		if err != nil {
			return nil, err
		}

		// Filter to only IPv4 addresses
		var ipv4Addrs []string
		for _, addr := range addrs {
			ip := net.ParseIP(addr)
			if ip != nil && ip.To4() != nil {
				ipv4Addrs = append(ipv4Addrs, addr)
			}
		}

		if len(ipv4Addrs) == 0 {
			return nil, fmt.Errorf("no IPv4 addresses found for host %s", host)
		}

		return ipv4Addrs, nil
	}

	config.ConnConfig.DialFunc = func(ctx context.Context, network, addr string) (net.Conn, error) {
		// Force TCP4 to ensure IPv4 is used
		d := &net.Dialer{
			Timeout:   30 * time.Second,
			KeepAlive: 30 * time.Second,
		}
		return d.DialContext(ctx, "tcp4", addr)
	}

	// Connection pool settings
	config.MaxConns = 25
	config.MinConns = 5
	config.MaxConnLifetime = time.Hour
	config.MaxConnIdleTime = 30 * time.Minute
	config.HealthCheckPeriod = time.Minute

	// Create connection pool
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("failed to create connection pool: %w", err)
	}

	// Test connection
	if err := pool.Ping(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return pool, nil
}
