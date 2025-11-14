-- Attendance Module: Attendance tracking, overtime, and work records

-- Attendance table (daily attendance record)
CREATE TABLE attendances (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    check_in TIMESTAMP,
    check_out TIMESTAMP,
    worked_hours DECIMAL(5, 2) DEFAULT 0,
    overtime_hours DECIMAL(5, 2) DEFAULT 0,
    break_hours DECIMAL(5, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'present', -- present, absent, half_day, late, early_out
    is_validated BOOLEAN DEFAULT false,
    validated_by_id BIGINT REFERENCES employees(id) ON DELETE SET NULL,
    validated_at TIMESTAMP,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(employee_id, attendance_date)
);

CREATE INDEX idx_attendances_employee_id ON attendances(employee_id);
CREATE INDEX idx_attendances_attendance_date ON attendances(attendance_date);
CREATE INDEX idx_attendances_status ON attendances(status);
CREATE INDEX idx_attendances_is_validated ON attendances(is_validated);

-- Attendance activities (individual clock in/out events - can have multiple per day)
CREATE TABLE attendance_activities (
    id BIGSERIAL PRIMARY KEY,
    attendance_id BIGINT NOT NULL REFERENCES attendances(id) ON DELETE CASCADE,
    clock_in TIMESTAMP NOT NULL,
    clock_out TIMESTAMP,
    clock_in_ip VARCHAR(45),
    clock_out_ip VARCHAR(45),
    clock_in_location VARCHAR(255),
    clock_out_location VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_attendance_activities_attendance_id ON attendance_activities(attendance_id);
CREATE INDEX idx_attendance_activities_clock_in ON attendance_activities(clock_in);

-- Overtime tracking
CREATE TABLE overtime_records (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    attendance_id BIGINT REFERENCES attendances(id) ON DELETE SET NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    overtime_hours DECIMAL(5, 2) NOT NULL,
    approved_hours DECIMAL(5, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
    approved_by_id BIGINT REFERENCES employees(id) ON DELETE SET NULL,
    approved_at TIMESTAMP,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_overtime_records_employee_id ON overtime_records(employee_id);
CREATE INDEX idx_overtime_records_month_year ON overtime_records(month, year);
CREATE INDEX idx_overtime_records_status ON overtime_records(status);

-- Late come / Early out tracking
CREATE TABLE late_early_records (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    attendance_id BIGINT NOT NULL REFERENCES attendances(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL, -- late_come, early_out
    minutes INT NOT NULL,
    penalty_type VARCHAR(50), -- leave_deduction, monetary, none
    penalty_amount DECIMAL(10, 2) DEFAULT 0,
    is_excused BOOLEAN DEFAULT false,
    excused_by_id BIGINT REFERENCES employees(id) ON DELETE SET NULL,
    excused_at TIMESTAMP,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_late_early_records_employee_id ON late_early_records(employee_id);
CREATE INDEX idx_late_early_records_attendance_id ON late_early_records(attendance_id);
CREATE INDEX idx_late_early_records_type ON late_early_records(type);

-- Work records (consolidated daily work status)
CREATE TABLE work_records (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status VARCHAR(50) NOT NULL, -- present, absent, half_day, holiday, weekend, on_leave
    worked_hours DECIMAL(5, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(employee_id, date)
);

CREATE INDEX idx_work_records_employee_id ON work_records(employee_id);
CREATE INDEX idx_work_records_date ON work_records(date);
CREATE INDEX idx_work_records_status ON work_records(status);

-- Attendance requests (for creating/updating attendance)
CREATE TABLE attendance_requests (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    requested_check_in TIMESTAMP,
    requested_check_out TIMESTAMP,
    reason TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
    approved_by_id BIGINT REFERENCES employees(id) ON DELETE SET NULL,
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_attendance_requests_employee_id ON attendance_requests(employee_id);
CREATE INDEX idx_attendance_requests_status ON attendance_requests(status);
CREATE INDEX idx_attendance_requests_attendance_date ON attendance_requests(attendance_date);

-- IP whitelist for attendance
CREATE TABLE attendance_ip_whitelist (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    ip_address VARCHAR(45) NOT NULL,
    description VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_attendance_ip_whitelist_company_id ON attendance_ip_whitelist(company_id);
CREATE INDEX idx_attendance_ip_whitelist_ip_address ON attendance_ip_whitelist(ip_address);
