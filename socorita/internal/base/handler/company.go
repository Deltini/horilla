package handler

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/Deltini/socorita/internal/base/model"
	"github.com/Deltini/socorita/internal/base/service"
	"github.com/Deltini/socorita/internal/shared/utils"
)

// CompanyHandler handles HTTP requests for companies
type CompanyHandler struct {
	service *service.CompanyService
}

// NewCompanyHandler creates a new company handler
func NewCompanyHandler(service *service.CompanyService) *CompanyHandler {
	return &CompanyHandler{
		service: service,
	}
}

// ServeHTTP implements the http.Handler interface
func (h *CompanyHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Extract ID from path if present
	path := strings.TrimPrefix(r.URL.Path, "/api/companies")
	path = strings.TrimPrefix(path, "/")

	switch r.Method {
	case http.MethodGet:
		if path == "" {
			h.ListCompanies(w, r)
		} else {
			h.GetCompany(w, r, path)
		}
	case http.MethodPost:
		h.CreateCompany(w, r)
	case http.MethodPut:
		if path != "" {
			h.UpdateCompany(w, r, path)
		} else {
			utils.WriteBadRequest(w, "Company ID is required")
		}
	case http.MethodDelete:
		if path != "" {
			h.DeleteCompany(w, r, path)
		} else {
			utils.WriteBadRequest(w, "Company ID is required")
		}
	default:
		utils.WriteError(w, http.StatusMethodNotAllowed, "Method not allowed")
	}
}

// GetCompany handles GET /api/companies/:id
func (h *CompanyHandler) GetCompany(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		utils.WriteBadRequest(w, "Invalid company ID")
		return
	}

	company, err := h.service.GetCompany(r.Context(), id)
	if err != nil {
		utils.WriteInternalError(w, err.Error())
		return
	}

	utils.WriteSuccess(w, "Company retrieved successfully", company)
}

// ListCompanies handles GET /api/companies
func (h *CompanyHandler) ListCompanies(w http.ResponseWriter, r *http.Request) {
	companies, err := h.service.ListCompanies(r.Context())
	if err != nil {
		utils.WriteInternalError(w, err.Error())
		return
	}

	utils.WriteSuccess(w, "Companies retrieved successfully", companies)
}

// CreateCompany handles POST /api/companies
func (h *CompanyHandler) CreateCompany(w http.ResponseWriter, r *http.Request) {
	var req model.CreateCompanyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.WriteBadRequest(w, "Invalid request body")
		return
	}

	company, err := h.service.CreateCompany(r.Context(), &req)
	if err != nil {
		utils.WriteInternalError(w, err.Error())
		return
	}

	utils.WriteCreated(w, "Company created successfully", company)
}

// UpdateCompany handles PUT /api/companies/:id
func (h *CompanyHandler) UpdateCompany(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		utils.WriteBadRequest(w, "Invalid company ID")
		return
	}

	var req model.UpdateCompanyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.WriteBadRequest(w, "Invalid request body")
		return
	}

	company, err := h.service.UpdateCompany(r.Context(), id, &req)
	if err != nil {
		utils.WriteInternalError(w, err.Error())
		return
	}

	utils.WriteSuccess(w, "Company updated successfully", company)
}

// DeleteCompany handles DELETE /api/companies/:id
func (h *CompanyHandler) DeleteCompany(w http.ResponseWriter, r *http.Request, idStr string) {
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		utils.WriteBadRequest(w, "Invalid company ID")
		return
	}

	if err := h.service.DeleteCompany(r.Context(), id); err != nil {
		utils.WriteInternalError(w, err.Error())
		return
	}

	utils.WriteSuccess(w, "Company deleted successfully", nil)
}
