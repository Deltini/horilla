package utils

import (
	"encoding/json"
	"net/http"
)

// Response represents a standard API response
type Response struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// WriteJSON writes a JSON response to the http.ResponseWriter
func WriteJSON(w http.ResponseWriter, status int, data interface{}) error {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	return json.NewEncoder(w).Encode(data)
}

// WriteSuccess writes a successful JSON response
func WriteSuccess(w http.ResponseWriter, message string, data interface{}) error {
	return WriteJSON(w, http.StatusOK, Response{
		Success: true,
		Message: message,
		Data:    data,
	})
}

// WriteError writes an error JSON response
func WriteError(w http.ResponseWriter, status int, message string) error {
	return WriteJSON(w, status, Response{
		Success: false,
		Error:   message,
	})
}

// WriteCreated writes a 201 Created JSON response
func WriteCreated(w http.ResponseWriter, message string, data interface{}) error {
	return WriteJSON(w, http.StatusCreated, Response{
		Success: true,
		Message: message,
		Data:    data,
	})
}

// WriteBadRequest writes a 400 Bad Request JSON response
func WriteBadRequest(w http.ResponseWriter, message string) error {
	return WriteError(w, http.StatusBadRequest, message)
}

// WriteUnauthorized writes a 401 Unauthorized JSON response
func WriteUnauthorized(w http.ResponseWriter, message string) error {
	return WriteError(w, http.StatusUnauthorized, message)
}

// WriteForbidden writes a 403 Forbidden JSON response
func WriteForbidden(w http.ResponseWriter, message string) error {
	return WriteError(w, http.StatusForbidden, message)
}

// WriteNotFound writes a 404 Not Found JSON response
func WriteNotFound(w http.ResponseWriter, message string) error {
	return WriteError(w, http.StatusNotFound, message)
}

// WriteInternalError writes a 500 Internal Server Error JSON response
func WriteInternalError(w http.ResponseWriter, message string) error {
	return WriteError(w, http.StatusInternalServerError, message)
}
