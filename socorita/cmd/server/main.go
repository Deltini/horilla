package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/Deltini/socorita/internal/shared/config"
	"github.com/Deltini/socorita/internal/shared/database"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Connect to database
	db, err := database.New(cfg.GetDSN())
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Set up router
	mux := setupRoutes(db, cfg)

	// Create HTTP server
	server := &http.Server{
		Addr:         fmt.Sprintf(":%s", cfg.Server.Port),
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in a goroutine
	go func() {
		log.Printf("Starting server on %s:%s", cfg.Server.Host, cfg.Server.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// Graceful shutdown with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}

func setupRoutes(db *database.DB, cfg *config.Config) *http.ServeMux {
	mux := http.NewServeMux()

	// Health check endpoint
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, `{"status":"ok","app":"%s"}`, cfg.App.Name)
	})

	// Home page
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/html")
		fmt.Fprintf(w, `
<!DOCTYPE html>
<html>
<head>
    <title>%s</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .module { background: #f4f4f4; padding: 15px; margin: 10px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Welcome to %s</h1>
    <p>A modern HR Management System built with Go and templ</p>

    <h2>Core Modules</h2>
    <div class="module"><strong>Base Module:</strong> Companies, Departments, Job Positions, Shifts</div>
    <div class="module"><strong>Employee Module:</strong> Employee Management</div>
    <div class="module"><strong>Attendance Module:</strong> Time Tracking & Attendance</div>
    <div class="module"><strong>Leave Module:</strong> Leave Requests & Management</div>

    <h2>API Endpoints</h2>
    <ul>
        <li><a href="/health">/health</a> - Health check</li>
        <li>/api/companies - Company management</li>
        <li>/api/departments - Department management</li>
        <li>/api/employees - Employee management</li>
        <li>/api/attendance - Attendance tracking</li>
        <li>/api/leave - Leave management</li>
    </ul>
</body>
</html>
`, cfg.App.Name, cfg.App.Name)
	})

	// Static files
	fs := http.FileServer(http.Dir("web/static"))
	mux.Handle("/static/", http.StripPrefix("/static/", fs))

	// TODO: Add module routes here
	// - Base module routes (companies, departments, job positions)
	// - Employee module routes
	// - Attendance module routes
	// - Leave module routes
	// - Auth routes

	return mux
}
