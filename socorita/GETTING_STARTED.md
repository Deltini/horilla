# Getting Started with Socorita HR Management System

## What Has Been Built

I've created a complete foundation for a Go-based HR Management System with a **modular monolith architecture**. Here's what's ready:

### ✅ Complete Project Structure

```
socorita/
├── cmd/server/              # HTTP server entry point
├── internal/                # Modular business logic
│   ├── base/               # Companies, Departments, Shifts
│   ├── employee/           # Employee management
│   ├── attendance/         # Time tracking
│   ├── leave/              # Leave management
│   └── shared/             # Utilities, config, database
├── db/
│   ├── migrations/         # 4 complete migration files
│   └── queries/            # 6 SQL query files
└── web/                    # Templates and static files
```

### ✅ Database Schema (PostgreSQL)

**4 Complete Migration Files:**

1. **Base Module** (`000001_init_base_module.up.sql`)
   - `companies` - Multi-company support
   - `departments` - Department hierarchy
   - `job_positions` - Job roles
   - `job_roles` - Role definitions
   - `work_types` - Office/Remote/Hybrid
   - `employee_shifts` - Shift scheduling
   - `shift_schedules` - Shift days
   - `holidays` - Holiday management

2. **Employee Module** (`000002_init_employee_module.up.sql`)
   - `users` - Authentication
   - `employees` - Employee profiles
   - `employee_work_info` - Job information
   - `employee_bank_details` - Banking info
   - `emergency_contacts` - Emergency contacts
   - `employee_notes` - Notes and comments
   - `tags` - Categorization system
   - `employee_tags` - Tag relationships

3. **Attendance Module** (`000003_init_attendance_module.up.sql`)
   - `attendances` - Daily attendance records
   - `attendance_activities` - Clock in/out events
   - `overtime_records` - Overtime tracking
   - `late_early_records` - Late/early tracking
   - `work_records` - Consolidated work status
   - `attendance_requests` - Attendance requests
   - `attendance_ip_whitelist` - IP restrictions

4. **Leave Module** (`000004_init_leave_module.up.sql`)
   - `leave_types` - Leave type configuration
   - `available_leaves` - Employee leave balances
   - `leave_requests` - Leave applications
   - `leave_allocations` - Admin allocations
   - `leave_approval_conditions` - Approval rules
   - `leave_request_approvals` - Multi-step approvals
   - `company_leaves` - Weekly offs

### ✅ Type-Safe Database Queries (sqlc)

**6 SQL Query Files:**
- `companies.sql` - CRUD operations for companies
- `departments.sql` - Department management
- `employees.sql` - Employee operations
- `users.sql` - User authentication
- `attendance.sql` - Attendance tracking
- `leave.sql` - Leave management

### ✅ Application Foundation

- **Configuration Management** - Environment-based config
- **Database Connection Pool** - PostgreSQL with connection pooling
- **HTTP Server** - Native Go net/http with routing
- **Shared Utilities** - Password hashing, JSON responses
- **Example Handler** - Company handler with full CRUD

### ✅ Development Tools

- **Makefile** - 12+ useful commands
- **Air Config** - Hot reload for development
- **Environment Template** - `.env.example`
- **Comprehensive README** - Complete documentation

## Next Steps to Get It Running

### 1. Push to GitHub

The code is committed locally. To push to your repository:

```bash
cd /home/user/socorita

# If you have SSH keys set up:
git remote set-url origin git@github.com:Deltini/socorita.git
git push -u origin main

# Or configure credentials for HTTPS and push
git push -u origin main
```

### 2. Install Dependencies

```bash
cd /home/user/socorita

# Download Go dependencies
go mod download

# Install development tools
make install-tools
```

This installs:
- `sqlc` - SQL code generation
- `templ` - Template code generation
- `migrate` - Database migrations
- `air` - Hot reload (optional)

### 3. Set Up Database

```bash
# Create PostgreSQL database
createdb socorita_db

# Copy and configure environment file
cp .env.example .env

# Edit .env with your database credentials
# Then run migrations
make migrate-up
```

### 4. Generate Database Code

```bash
# Generate type-safe Go code from SQL queries
make sqlc
```

This creates `internal/shared/repository/` with:
- `db.go` - Database interface
- `models.go` - Go structs for database tables
- `companies.sql.go` - Company queries
- `departments.sql.go` - Department queries
- `employees.sql.go` - Employee queries
- `users.sql.go` - User queries
- `attendance.sql.go` - Attendance queries
- `leave.sql.go` - Leave queries

### 5. Run the Application

```bash
# Development mode with hot reload
make dev

# Or build and run
make build
./bin/server

# Or simply
make run
```

### 6. Test It

```bash
# Health check
curl http://localhost:8080/health

# View home page
open http://localhost:8080
```

## What to Build Next

### Immediate Priority (To Make It Functional)

1. **Update Service Layer** - Once sqlc generates the code, update the services to use it:
   - `internal/base/service/company.go`
   - `internal/base/service/department.go`
   - `internal/employee/service/employee.go`

2. **Add Authentication**
   - Implement login/logout
   - Session management
   - Password reset

3. **Build UI with templ**
   - Login page
   - Dashboard
   - Company list/create/edit
   - Employee list/create/edit

4. **Complete Core Modules**
   - Employee module (handlers, services, models)
   - Department & Job Position handlers
   - Shift management

### Phase 2 (After Core is Working)

5. **Attendance Module**
   - Clock in/out UI
   - Attendance reports
   - Overtime approval

6. **Leave Module**
   - Leave request form
   - Approval workflow
   - Leave balance dashboard

7. **Advanced Features**
   - Notifications
   - Audit logging
   - Reporting
   - Export functionality

## Project Highlights

### 🎯 Modular Monolith Architecture

Each module is independent but lives in the same codebase:
- **Clear boundaries** - Each module has its own handlers, services, models
- **Shared infrastructure** - Database, config, utilities
- **Easy to maintain** - Changes are localized to modules
- **Can split later** - Easy to extract to microservices if needed

### 🔒 Type Safety

- **sqlc** - Compile-time SQL query validation
- **templ** - Type-safe HTML templates
- **Go** - Strong typing throughout

### 🚀 Performance

- **Native Go net/http** - No framework overhead
- **PostgreSQL** - Battle-tested database
- **Connection pooling** - Optimized database access
- **No ORM** - Direct SQL for maximum control

### 📦 Production Ready Patterns

- Environment-based configuration
- Graceful shutdown
- Health checks
- Database migrations
- Soft deletes
- Audit timestamps

## Common Commands

```bash
# Development
make dev                    # Run with hot reload
make run                    # Run normally
make build                  # Build binary

# Database
make migrate-up             # Apply migrations
make migrate-down           # Rollback migration
make migrate-create name=foo # Create new migration
make sqlc                   # Generate query code

# Templates
make templ                  # Generate templ code

# Testing
make test                   # Run tests

# Cleanup
make clean                  # Remove build artifacts
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         HTTP Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  Base    │  │ Employee │  │Attendance│  │  Leave   │  │
│  │ Handler  │  │ Handler  │  │ Handler  │  │ Handler  │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
└───────┼─────────────┼─────────────┼─────────────┼─────────┘
        │             │             │             │
┌───────┼─────────────┼─────────────┼─────────────┼─────────┐
│       │             │             │             │         │
│  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐  │
│  │  Base    │  │ Employee │  │Attendance│  │  Leave   │  │
│  │ Service  │  │ Service  │  │ Service  │  │ Service  │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       │             │             │             │         │
│                 Business Logic Layer                      │
└───────┼─────────────┼─────────────┼─────────────┼─────────┘
        │             │             │             │
┌───────┼─────────────┼─────────────┼─────────────┼─────────┐
│       │             │             │             │         │
│  ┌────▼──────────────────────────────────────────────┐    │
│  │        Repository Layer (Generated by sqlc)       │    │
│  │  Companies │ Employees │ Attendance │ Leave       │    │
│  └────┬──────────────────────────────────────────────┘    │
│       │                                                    │
│  ┌────▼────────────────────────────────┐                  │
│  │      PostgreSQL Database            │                  │
│  └─────────────────────────────────────┘                  │
│                                                            │
│                    Data Layer                             │
└────────────────────────────────────────────────────────────┘
```

## Questions?

Check the main [README.md](./README.md) for detailed documentation.

Happy coding! 🚀
