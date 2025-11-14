-- name: GetDepartment :one
SELECT * FROM departments
WHERE id = $1 AND is_active = true LIMIT 1;

-- name: ListDepartments :many
SELECT * FROM departments
WHERE is_active = true
ORDER BY name;

-- name: ListDepartmentsByCompany :many
SELECT * FROM departments
WHERE company_id = $1 AND is_active = true
ORDER BY name;

-- name: CreateDepartment :one
INSERT INTO departments (
    name, company_id, manager_id, description
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: UpdateDepartment :one
UPDATE departments
SET name = $2,
    company_id = $3,
    manager_id = $4,
    description = $5,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: DeleteDepartment :exec
UPDATE departments
SET is_active = false, updated_at = NOW()
WHERE id = $1;

-- name: GetDepartmentWithManager :one
SELECT
    d.*,
    e.first_name as manager_first_name,
    e.last_name as manager_last_name
FROM departments d
LEFT JOIN employees e ON d.manager_id = e.id
WHERE d.id = $1 AND d.is_active = true
LIMIT 1;
