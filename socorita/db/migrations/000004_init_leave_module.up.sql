-- Leave Module: Leave types, requests, and allocations

-- Leave types table
CREATE TABLE leave_types (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    is_paid BOOLEAN DEFAULT true,
    total_days INT DEFAULT 0,
    carryforward_allowed BOOLEAN DEFAULT false,
    carryforward_max_days INT DEFAULT 0,
    carryforward_expire_months INT DEFAULT 12,
    reset_cycle VARCHAR(20) DEFAULT 'yearly', -- yearly, monthly, weekly, never
    reset_day INT, -- Day of month/week for reset
    exclude_holidays BOOLEAN DEFAULT true,
    exclude_company_leaves BOOLEAN DEFAULT true,
    require_attachment BOOLEAN DEFAULT false,
    is_compensatory BOOLEAN DEFAULT false,
    is_encashable BOOLEAN DEFAULT false,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leave_types_company_id ON leave_types(company_id);
CREATE INDEX idx_leave_types_is_active ON leave_types(is_active);

-- Available leave (employee leave balance)
CREATE TABLE available_leaves (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    leave_type_id BIGINT NOT NULL REFERENCES leave_types(id) ON DELETE CASCADE,
    total_days DECIMAL(5, 2) DEFAULT 0,
    used_days DECIMAL(5, 2) DEFAULT 0,
    available_days DECIMAL(5, 2) DEFAULT 0,
    carryforward_days DECIMAL(5, 2) DEFAULT 0,
    carryforward_expire_date DATE,
    year INT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(employee_id, leave_type_id, year)
);

CREATE INDEX idx_available_leaves_employee_id ON available_leaves(employee_id);
CREATE INDEX idx_available_leaves_leave_type_id ON available_leaves(leave_type_id);
CREATE INDEX idx_available_leaves_year ON available_leaves(year);

-- Leave requests
CREATE TABLE leave_requests (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    leave_type_id BIGINT NOT NULL REFERENCES leave_types(id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    leave_days DECIMAL(5, 2) NOT NULL,
    leave_portion VARCHAR(20) DEFAULT 'full_day', -- full_day, first_half, second_half
    reason TEXT NOT NULL,
    attachment VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected, cancelled
    approved_by_id BIGINT REFERENCES employees(id) ON DELETE SET NULL,
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leave_requests_employee_id ON leave_requests(employee_id);
CREATE INDEX idx_leave_requests_leave_type_id ON leave_requests(leave_type_id);
CREATE INDEX idx_leave_requests_status ON leave_requests(status);
CREATE INDEX idx_leave_requests_dates ON leave_requests(start_date, end_date);

-- Leave allocations (admin-assigned leave)
CREATE TABLE leave_allocations (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    leave_type_id BIGINT NOT NULL REFERENCES leave_types(id) ON DELETE CASCADE,
    allocated_days DECIMAL(5, 2) NOT NULL,
    reason TEXT,
    allocated_by_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    year INT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leave_allocations_employee_id ON leave_allocations(employee_id);
CREATE INDEX idx_leave_allocations_leave_type_id ON leave_allocations(leave_type_id);
CREATE INDEX idx_leave_allocations_year ON leave_allocations(year);

-- Leave approval workflow (for multi-level approvals)
CREATE TABLE leave_approval_conditions (
    id BIGSERIAL PRIMARY KEY,
    leave_type_id BIGINT NOT NULL REFERENCES leave_types(id) ON DELETE CASCADE,
    department_id BIGINT REFERENCES departments(id) ON DELETE CASCADE,
    min_days DECIMAL(5, 2),
    max_days DECIMAL(5, 2),
    approver_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    approval_order INT DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leave_approval_conditions_leave_type_id ON leave_approval_conditions(leave_type_id);
CREATE INDEX idx_leave_approval_conditions_department_id ON leave_approval_conditions(department_id);
CREATE INDEX idx_leave_approval_conditions_approver_id ON leave_approval_conditions(approver_id);

-- Leave request approvals (tracks multi-step approval process)
CREATE TABLE leave_request_approvals (
    id BIGSERIAL PRIMARY KEY,
    leave_request_id BIGINT NOT NULL REFERENCES leave_requests(id) ON DELETE CASCADE,
    approver_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    approval_order INT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
    comments TEXT,
    approved_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leave_request_approvals_leave_request_id ON leave_request_approvals(leave_request_id);
CREATE INDEX idx_leave_request_approvals_approver_id ON leave_request_approvals(approver_id);
CREATE INDEX idx_leave_request_approvals_status ON leave_request_approvals(status);

-- Company leaves (weekly offs)
CREATE TABLE company_leaves (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    week_number INT, -- Which week of the month (1-5, null for all weeks)
    day_of_week INT NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday, 6=Saturday
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_company_leaves_company_id ON company_leaves(company_id);
CREATE INDEX idx_company_leaves_day_of_week ON company_leaves(day_of_week);
