-- name: GetCompany :one
SELECT * FROM companies
WHERE id = $1 AND is_active = true LIMIT 1;

-- name: GetCompanyByName :one
SELECT * FROM companies
WHERE name = $1 AND is_active = true LIMIT 1;

-- name: ListCompanies :many
SELECT * FROM companies
WHERE is_active = true
ORDER BY name;

-- name: CreateCompany :one
INSERT INTO companies (
    name, address, country, state, city, zip_code, phone, email, website, is_hq, icon
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
) RETURNING *;

-- name: UpdateCompany :one
UPDATE companies
SET name = $2,
    address = $3,
    country = $4,
    state = $5,
    city = $6,
    zip_code = $7,
    phone = $8,
    email = $9,
    website = $10,
    is_hq = $11,
    icon = $12,
    updated_at = NOW()
WHERE id = $1 AND is_active = true
RETURNING *;

-- name: DeleteCompany :exec
UPDATE companies
SET is_active = false, updated_at = NOW()
WHERE id = $1;

-- name: GetHQCompany :one
SELECT * FROM companies
WHERE is_hq = true AND is_active = true LIMIT 1;
