.PHONY: help build run dev test migrate-up migrate-down migrate-create sqlc templ clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

build: ## Build the application
	@echo "Building..."
	@go build -o bin/server cmd/server/main.go

run: ## Run the application
	@echo "Running..."
	@go run cmd/server/main.go

dev: ## Run with air for hot reload (requires air to be installed)
	@air

test: ## Run tests
	@echo "Running tests..."
	@go test -v ./...

sqlc: ## Generate sqlc code
	@echo "Generating sqlc code..."
	@sqlc generate

templ: ## Generate templ code
	@echo "Generating templ templates..."
	@templ generate

migrate-up: ## Run database migrations up
	@echo "Running migrations up..."
	@migrate -path db/migrations -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)" up

migrate-down: ## Rollback last migration
	@echo "Rolling back migration..."
	@migrate -path db/migrations -database "postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)" down 1

migrate-create: ## Create a new migration file (use name=migration_name)
	@echo "Creating migration..."
	@migrate create -ext sql -dir db/migrations -seq $(name)

clean: ## Clean build artifacts
	@echo "Cleaning..."
	@rm -rf bin/
	@go clean

install-tools: ## Install required development tools
	@echo "Installing tools..."
	@go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
	@go install github.com/a-h/templ/cmd/templ@latest
	@go install github.com/cosmtrek/air@latest
	@go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
