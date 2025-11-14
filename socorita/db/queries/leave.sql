-- name: GetLeaveType :one
SELECT * FROM leave_types
WHERE id = $1 AND is_active = true LIMIT 1;

-- name: ListLeaveTypes :many
SELECT * FROM leave_types
WHERE is_active = true
ORDER BY name;

-- name: ListLeaveTypesByCompany :many
SELECT * FROM leave_types
WHERE company_id = $1 AND is_active = true
ORDER BY name;

-- name: CreateLeaveType :one
INSERT INTO leave_types (
    name, company_id, is_paid, total_days, carryforward_allowed,
    carryforward_max_days, exclude_holidays, exclude_company_leaves, description
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9
) RETURNING *;

-- name: UpdateLeaveType :one
UPDATE leave_types
SET name = $2,
    is_paid = $3,
    total_days = $4,
    carryforward_allowed = $5,
    carryforward_max_days = $6,
    exclude_holidays = $7,
    exclude_company_leaves = $8,
    description = $9,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: GetAvailableLeave :one
SELECT * FROM available_leaves
WHERE employee_id = $1 AND leave_type_id = $2 AND year = $3 AND is_active = true
LIMIT 1;

-- name: ListAvailableLeavesByEmployee :many
SELECT al.*, lt.name as leave_type_name, lt.is_paid
FROM available_leaves al
INNER JOIN leave_types lt ON al.leave_type_id = lt.id
WHERE al.employee_id = $1 AND al.year = $2 AND al.is_active = true
ORDER BY lt.name;

-- name: CreateAvailableLeave :one
INSERT INTO available_leaves (
    employee_id, leave_type_id, total_days, available_days, year
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: UpdateAvailableLeave :one
UPDATE available_leaves
SET total_days = $2,
    used_days = $3,
    available_days = $4,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: GetLeaveRequest :one
SELECT * FROM leave_requests
WHERE id = $1 AND is_active = true LIMIT 1;

-- name: ListLeaveRequests :many
SELECT lr.*, lt.name as leave_type_name, e.first_name, e.last_name
FROM leave_requests lr
INNER JOIN leave_types lt ON lr.leave_type_id = lt.id
INNER JOIN employees e ON lr.employee_id = e.id
WHERE lr.is_active = true
ORDER BY lr.created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListLeaveRequestsByEmployee :many
SELECT lr.*, lt.name as leave_type_name
FROM leave_requests lr
INNER JOIN leave_types lt ON lr.leave_type_id = lt.id
WHERE lr.employee_id = $1 AND lr.is_active = true
ORDER BY lr.start_date DESC;

-- name: ListLeaveRequestsByStatus :many
SELECT lr.*, lt.name as leave_type_name, e.first_name, e.last_name
FROM leave_requests lr
INNER JOIN leave_types lt ON lr.leave_type_id = lt.id
INNER JOIN employees e ON lr.employee_id = e.id
WHERE lr.status = $1 AND lr.is_active = true
ORDER BY lr.created_at DESC;

-- name: CreateLeaveRequest :one
INSERT INTO leave_requests (
    employee_id, leave_type_id, start_date, end_date, leave_days,
    leave_portion, reason, attachment
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8
) RETURNING *;

-- name: UpdateLeaveRequestStatus :one
UPDATE leave_requests
SET status = $2,
    approved_by_id = $3,
    approved_at = CASE WHEN $2 = 'approved' THEN NOW() ELSE approved_at END,
    rejection_reason = $4,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: CancelLeaveRequest :one
UPDATE leave_requests
SET status = 'cancelled', updated_at = NOW()
WHERE id = $1 AND employee_id = $2 AND status = 'pending' AND is_active = true
RETURNING *;
