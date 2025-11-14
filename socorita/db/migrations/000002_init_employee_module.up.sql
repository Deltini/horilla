-- Employee Module: Users, Employees, and related tables

-- Users table (for authentication)
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_superuser BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Employees table
CREATE TABLE employees (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    employee_number VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    badge_id VARCHAR(50) UNIQUE,
    phone VARCHAR(50),
    mobile VARCHAR(50),
    address TEXT,
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    zip_code VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(20),
    marital_status VARCHAR(20),
    profile_picture VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_employees_user_id ON employees(user_id);
CREATE INDEX idx_employees_employee_number ON employees(employee_number);
CREATE INDEX idx_employees_is_active ON employees(is_active);
CREATE INDEX idx_employees_badge_id ON employees(badge_id);

-- Employee work information
CREATE TABLE employee_work_info (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE RESTRICT,
    department_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
    job_position_id BIGINT REFERENCES job_positions(id) ON DELETE SET NULL,
    job_role_id BIGINT REFERENCES job_roles(id) ON DELETE SET NULL,
    shift_id BIGINT REFERENCES employee_shifts(id) ON DELETE SET NULL,
    work_type_id BIGINT REFERENCES work_types(id) ON DELETE SET NULL,
    reporting_to_id BIGINT REFERENCES employees(id) ON DELETE SET NULL,
    date_joined DATE NOT NULL,
    employment_type VARCHAR(50), -- Full-time, Part-time, Contract, etc.
    employee_status VARCHAR(50) DEFAULT 'active', -- active, on_leave, terminated, etc.
    probation_end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(employee_id)
);

CREATE INDEX idx_employee_work_info_employee_id ON employee_work_info(employee_id);
CREATE INDEX idx_employee_work_info_company_id ON employee_work_info(company_id);
CREATE INDEX idx_employee_work_info_department_id ON employee_work_info(department_id);
CREATE INDEX idx_employee_work_info_job_position_id ON employee_work_info(job_position_id);
CREATE INDEX idx_employee_work_info_reporting_to_id ON employee_work_info(reporting_to_id);

-- Add manager_id foreign key to departments (now that employees table exists)
ALTER TABLE departments ADD CONSTRAINT fk_departments_manager
    FOREIGN KEY (manager_id) REFERENCES employees(id) ON DELETE SET NULL;

-- Employee bank details
CREATE TABLE employee_bank_details (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    bank_name VARCHAR(255),
    account_number VARCHAR(100),
    routing_number VARCHAR(100),
    account_holder_name VARCHAR(255),
    bank_address TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(employee_id)
);

CREATE INDEX idx_employee_bank_details_employee_id ON employee_bank_details(employee_id);

-- Emergency contacts
CREATE TABLE emergency_contacts (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    relationship VARCHAR(100),
    phone VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    address TEXT,
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_emergency_contacts_employee_id ON emergency_contacts(employee_id);

-- Employee notes
CREATE TABLE employee_notes (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    created_by_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_employee_notes_employee_id ON employee_notes(employee_id);
CREATE INDEX idx_employee_notes_created_by_id ON employee_notes(created_by_id);

-- Tags table (for categorizing employees, departments, etc.)
CREATE TABLE tags (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    color VARCHAR(7), -- Hex color code
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tags_name ON tags(name);

-- Employee tags (many-to-many)
CREATE TABLE employee_tags (
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    tag_id BIGINT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (employee_id, tag_id)
);

CREATE INDEX idx_employee_tags_employee_id ON employee_tags(employee_id);
CREATE INDEX idx_employee_tags_tag_id ON employee_tags(tag_id);
