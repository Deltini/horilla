-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 AND is_active = true LIMIT 1;

-- name: GetUserByEmail :one
SELECT * FROM users
WHERE email = $1 AND is_active = true LIMIT 1;

-- name: CreateUser :one
INSERT INTO users (
    email, password_hash, is_superuser
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: UpdateUser :one
UPDATE users
SET email = $2,
    is_active = $3,
    is_superuser = $4,
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: UpdateUserPassword :exec
UPDATE users
SET password_hash = $2, updated_at = NOW()
WHERE id = $1;

-- name: UpdateUserLastLogin :exec
UPDATE users
SET last_login = NOW(), updated_at = NOW()
WHERE id = $1;

-- name: DeleteUser :exec
UPDATE users
SET is_active = false, updated_at = NOW()
WHERE id = $1;
