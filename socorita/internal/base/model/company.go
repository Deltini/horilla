package model

import "time"

// Company represents a company in the system
type Company struct {
	ID        int64     `json:"id"`
	Name      string    `json:"name"`
	Address   *string   `json:"address,omitempty"`
	Country   *string   `json:"country,omitempty"`
	State     *string   `json:"state,omitempty"`
	City      *string   `json:"city,omitempty"`
	ZipCode   *string   `json:"zip_code,omitempty"`
	Phone     *string   `json:"phone,omitempty"`
	Email     *string   `json:"email,omitempty"`
	Website   *string   `json:"website,omitempty"`
	IsHQ      bool      `json:"is_hq"`
	Icon      *string   `json:"icon,omitempty"`
	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// CreateCompanyRequest represents the request to create a company
type CreateCompanyRequest struct {
	Name    string  `json:"name"`
	Address *string `json:"address"`
	Country *string `json:"country"`
	State   *string `json:"state"`
	City    *string `json:"city"`
	ZipCode *string `json:"zip_code"`
	Phone   *string `json:"phone"`
	Email   *string `json:"email"`
	Website *string `json:"website"`
	IsHQ    bool    `json:"is_hq"`
	Icon    *string `json:"icon"`
}

// UpdateCompanyRequest represents the request to update a company
type UpdateCompanyRequest struct {
	Name    string  `json:"name"`
	Address *string `json:"address"`
	Country *string `json:"country"`
	State   *string `json:"state"`
	City    *string `json:"city"`
	ZipCode *string `json:"zip_code"`
	Phone   *string `json:"phone"`
	Email   *string `json:"email"`
	Website *string `json:"website"`
	IsHQ    bool    `json:"is_hq"`
	Icon    *string `json:"icon"`
}
