-- name: GetAttendance :one
SELECT * FROM attendances
WHERE id = $1 AND is_active = true LIMIT 1;

-- name: GetAttendanceByEmployeeAndDate :one
SELECT * FROM attendances
WHERE employee_id = $1 AND attendance_date = $2 AND is_active = true LIMIT 1;

-- name: ListAttendancesByEmployee :many
SELECT * FROM attendances
WHERE employee_id = $1 AND is_active = true
ORDER BY attendance_date DESC
LIMIT $2 OFFSET $3;

-- name: ListAttendancesByDateRange :many
SELECT * FROM attendances
WHERE employee_id = $1
  AND attendance_date >= $2
  AND attendance_date <= $3
  AND is_active = true
ORDER BY attendance_date DESC;

-- name: CreateAttendance :one
INSERT INTO attendances (
    employee_id, attendance_date, check_in, check_out, status
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: UpdateAttendance :one
UPDATE attendances
SET check_in = $2,
    check_out = $3,
    worked_hours = $4,
    overtime_hours = $5,
    status = $6,
    notes = $7,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: ClockIn :one
UPDATE attendances
SET check_in = $2, status = 'present', updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: ClockOut :one
UPDATE attendances
SET check_out = $2, worked_hours = $3, updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: ValidateAttendance :one
UPDATE attendances
SET is_validated = true,
    validated_by_id = $2,
    validated_at = NOW(),
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: CreateAttendanceActivity :one
INSERT INTO attendance_activities (
    attendance_id, clock_in, clock_in_ip, clock_in_location
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: UpdateAttendanceActivity :one
UPDATE attendance_activities
SET clock_out = $2,
    clock_out_ip = $3,
    clock_out_location = $4,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: GetTodayAttendance :one
SELECT * FROM attendances
WHERE employee_id = $1 AND attendance_date = CURRENT_DATE AND is_active = true
LIMIT 1;

-- name: GetActiveAttendanceActivity :one
SELECT * FROM attendance_activities
WHERE attendance_id = $1 AND clock_out IS NULL AND is_active = true
ORDER BY clock_in DESC
LIMIT 1;
