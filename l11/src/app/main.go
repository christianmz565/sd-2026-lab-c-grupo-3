package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"runtime"
	"strconv"
	"sync"
	"sync/atomic"
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

	requestCount  atomic.Int64
	errorCount   atomic.Int64
	uptimeStart  = time.Now()

	httpRequestsTotal = make(map[string]int64)
	httpReqDurBuckets = []float64{0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10}
	httpReqDurCounts  = make(map[string][]int64)
	mu               sync.Mutex
)

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	writeJSON(w, status, map[string]any{"error": msg, "status_code": status})
}

type metricsResponse struct {
	http.ResponseWriter
	status int
}

func (m *metricsResponse) WriteHeader(code int) {
	m.status = code
	m.ResponseWriter.WriteHeader(code)
}

func labelsKey(method, path, status string) string {
	return method + "|" + path + "|" + status
}

func recordMetrics(method, path string, status int, duration float64) {
	key := labelsKey(method, path, strconv.Itoa(status))
	requestCount.Add(1)
	httpRequestsTotal[key]++

	if status >= 500 {
		errorCount.Add(1)
	}

	mu.Lock()
	if httpReqDurCounts[key] == nil {
		httpReqDurCounts[key] = make([]int64, len(httpReqDurBuckets)+1)
	}
	bucketIdx := -1
	for i, b := range httpReqDurBuckets {
		if duration <= b {
			bucketIdx = i
			break
		}
	}
	if bucketIdx >= 0 {
		for i := 0; i <= bucketIdx; i++ {
			httpReqDurCounts[key][i]++
		}
		httpReqDurCounts[key][len(httpReqDurBuckets)]++
	} else {
		for i := range httpReqDurCounts[key] {
			httpReqDurCounts[key][i]++
		}
	}
	mu.Unlock()
}

// START-SNIPPET,metrics-middleware
func metricsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		mr := &metricsResponse{ResponseWriter: w, status: http.StatusOK}
		next(mr, r)
		duration := time.Since(start).Seconds()
		level := "info"
		if mr.status >= 500 {
			level = "error"
		} else if mr.status >= 400 {
			level = "warn"
		}
		log.Printf(`{"level":"%s","msg":"%s %s %d %.3f","method":"%s","path":"%s","status":%d,"duration":%.3f}`, level, r.Method, r.URL.Path, mr.status, duration, r.Method, r.URL.Path, mr.status, duration)
		recordMetrics(r.Method, r.URL.Path, mr.status, duration)
	}
}
// END-SNIPPET

func metricsHandler(w http.ResponseWriter, r *http.Request) {
	mu.Lock()
	defer mu.Unlock()

	uptime := time.Since(uptimeStart).Seconds()
	w.Header().Set("Content-Type", "text/plain; version=0.0.4; charset=utf-8")

	fmt.Fprintf(w, "# HELP http_requests_total Total HTTP requests\n")
	fmt.Fprintf(w, "# TYPE http_requests_total counter\n")
	for key, count := range httpRequestsTotal {
		parts := splitKey(key)
		if len(parts) == 3 {
			fmt.Fprintf(w, "http_requests_total{method=%q,path=%q,status=%q,service=%q} %d\n", parts[0], parts[1], parts[2], "go-api", count)
		}
	}

	fmt.Fprintf(w, "# HELP http_request_errors_total Total 5xx errors\n")
	fmt.Fprintf(w, "# TYPE http_request_errors_total counter\n")
	fmt.Fprintf(w, "http_request_errors_total{service=%q} %d\n", "go-api", errorCount.Load())

	fmt.Fprintf(w, "# HELP http_request_duration_seconds HTTP request duration histogram\n")
	fmt.Fprintf(w, "# TYPE http_request_duration_seconds histogram\n")
	for key, counts := range httpReqDurCounts {
		parts := splitKey(key)
		if len(parts) == 3 {
			for i, b := range httpReqDurBuckets {
				fmt.Fprintf(w, "http_request_duration_seconds_bucket{method=%q,path=%q,status=%q,service=%q,le=%q} %d\n", parts[0], parts[1], parts[2], "go-api", fmt.Sprintf("%.3f", b), counts[i])
			}
			fmt.Fprintf(w, "http_request_duration_seconds_bucket{method=%q,path=%q,status=%q,service=%q,le=%q} %d\n", parts[0], parts[1], parts[2], "go-api", "+Inf", counts[len(counts)-1])
		}
	}

	fmt.Fprintf(w, "# HELP process_uptime_seconds Process uptime\n")
	fmt.Fprintf(w, "# TYPE process_uptime_seconds gauge\n")
	fmt.Fprintf(w, "process_uptime_seconds{service=%q} %.2f\n", "go-api", uptime)

	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	fmt.Fprintf(w, "# HELP go_memstats_alloc_bytes Go memory allocation\n")
	fmt.Fprintf(w, "# TYPE go_memstats_alloc_bytes gauge\n")
	fmt.Fprintf(w, "go_memstats_alloc_bytes{service=%q} %d\n", "go-api", m.Alloc)
}

func splitKey(key string) []string {
	var parts []string
	current := ""
	for _, c := range key {
		if c == '|' {
			parts = append(parts, current)
			current = ""
		} else {
			current += string(c)
		}
	}
	parts = append(parts, current)
	return parts
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

func errorTest(w http.ResponseWriter, r *http.Request) {
	writeError(w, http.StatusInternalServerError, "test error 500")
}

// START-SNIPPET,endpoints
func main() {
	log.SetFlags(0)
	mux := http.NewServeMux()
	mux.HandleFunc("GET /", metricsMiddleware(index))
	mux.HandleFunc("GET /health", metricsMiddleware(health))
	mux.HandleFunc("GET /api/info", metricsMiddleware(info))
	mux.HandleFunc("GET /api/products", metricsMiddleware(listProducts))
	mux.HandleFunc("GET /api/products/{id}", metricsMiddleware(getProduct))
	mux.HandleFunc("GET /api/users", metricsMiddleware(listUsers))
	mux.HandleFunc("POST /api/echo", metricsMiddleware(echo))
	mux.HandleFunc("GET /api/500", metricsMiddleware(errorTest))
	mux.HandleFunc("GET /metrics", metricsHandler)

	addr := ":8000"
	log.Printf("SD-Lab11 app listening on %s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}
// END-SNIPPET
