-- name: GetEmployee :one
SELECT * FROM employees
WHERE id = $1 AND is_active = true LIMIT 1;

-- name: GetEmployeeByNumber :one
SELECT * FROM employees
WHERE employee_number = $1 AND is_active = true LIMIT 1;

-- name: GetEmployeeByUserID :one
SELECT * FROM employees
WHERE user_id = $1 AND is_active = true LIMIT 1;

-- name: ListEmployees :many
SELECT * FROM employees
WHERE is_active = true
ORDER BY first_name, last_name;

-- name: CreateEmployee :one
INSERT INTO employees (
    user_id, employee_number, first_name, last_name, middle_name, badge_id,
    phone, mobile, address, country, state, city, zip_code,
    date_of_birth, gender, marital_status, profile_picture
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
) RETURNING *;

-- name: UpdateEmployee :one
UPDATE employees
SET first_name = $2,
    last_name = $3,
    middle_name = $4,
    badge_id = $5,
    phone = $6,
    mobile = $7,
    address = $8,
    country = $9,
    state = $10,
    city = $11,
    zip_code = $12,
    date_of_birth = $13,
    gender = $14,
    marital_status = $15,
    profile_picture = $16,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: DeleteEmployee :exec
UPDATE employees
SET is_active = false, updated_at = NOW()
WHERE id = $1;

-- name: GetEmployeeWithWorkInfo :one
SELECT
    e.*,
    ewi.company_id,
    ewi.department_id,
    ewi.job_position_id,
    ewi.date_joined,
    ewi.employment_type,
    ewi.employee_status,
    c.name as company_name,
    d.name as department_name,
    jp.title as job_title
FROM employees e
LEFT JOIN employee_work_info ewi ON e.id = ewi.employee_id
LEFT JOIN companies c ON ewi.company_id = c.id
LEFT JOIN departments d ON ewi.department_id = d.id
LEFT JOIN job_positions jp ON ewi.job_position_id = jp.id
WHERE e.id = $1 AND e.is_active = true
LIMIT 1;

-- name: ListEmployeesByDepartment :many
SELECT e.*
FROM employees e
INNER JOIN employee_work_info ewi ON e.id = ewi.employee_id
WHERE ewi.department_id = $1 AND e.is_active = true
ORDER BY e.first_name, e.last_name;

-- name: ListEmployeesByCompany :many
SELECT e.*
FROM employees e
INNER JOIN employee_work_info ewi ON e.id = ewi.employee_id
WHERE ewi.company_id = $1 AND e.is_active = true
ORDER BY e.first_name, e.last_name;
