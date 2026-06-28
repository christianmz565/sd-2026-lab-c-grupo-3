package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"runtime"
	"strconv"
	"time"
)

type Product struct {
	ID    int     `json:"id"`
	Name  string  `json:"name"`
	Price float64 `json:"price"`
	Stock int     `json:"stock"`
}

type User struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
	Role string `json:"role"`
}

type EchoRequest struct {
	Message string `json:"message"`
}

var (
	products = []Product{
		{1, "Laptop", 3500.0, 12},
		{2, "Mouse", 85.5, 120},
		{3, "Teclado", 150.0, 60},
		{4, "Monitor", 980.0, 25},
	}
	users = []User{
		{1, "Yenaro", "admin"},
		{2, "Daniel", "user"},
		{3, "Mariel", "user"},
	}
)

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]any{"error": msg, "status_code": status})
}

func index(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"app":  "SD-Lab11 Demo",
		"lang": "Go " + runtime.Version(),
		"tls":  "self-signed via Traefik",
		"endpoints": []string{
			"/health", "/api/info", "/api/products",
			"/api/products/{id}", "/api/users", "POST /api/echo",
		},
	})
}

func health(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func info(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"service": "sd-lab11-app",
		"go":      runtime.Version(),
		"now_utc": time.Now().UTC().Format(time.RFC3339),
	})
}

func listProducts(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, products)
}

func getProduct(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		writeError(w, http.StatusBadRequest, "id inválido")
		return
	}
	for _, p := range products {
		if p.ID == id {
			writeJSON(w, http.StatusOK, p)
			return
		}
	}
	writeError(w, http.StatusNotFound, fmt.Sprintf("Producto %d no encontrado", id))
}

func listUsers(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, users)
}

func echo(w http.ResponseWriter, r *http.Request) {
	var req EchoRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "JSON inválido")
		return
	}
	if req.Message == "" {
		writeError(w, http.StatusBadRequest, "el mensaje no puede estar vacío")
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"received": req.Message,
		"length":   len(req.Message),
	})
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /", index)
	mux.HandleFunc("GET /health", health)
	mux.HandleFunc("GET /api/info", info)
	mux.HandleFunc("GET /api/products", listProducts)
	mux.HandleFunc("GET /api/products/{id}", getProduct)
	mux.HandleFunc("GET /api/users", listUsers)
	mux.HandleFunc("POST /api/echo", echo)

	addr := ":8000"
	log.Printf("SD-Lab11 app listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}
