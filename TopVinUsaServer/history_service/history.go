package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/lib/pq"
)

// Структура для одной записи истории
type HistoryItem struct {
	UserID     int    `json:"user_id"`
	VIN        string `json:"vin"`
	Make       string `json:"make"`
	Model      string `json:"model"`
	Year       string `json:"year"`
	SearchedAt string `json:"searched_at,omitempty"`
}

// Глобальная переменная для подключения к БД
var db *sql.DB

// Инициализация БД
func initDB() {
	connStr := os.Getenv("DB_CONN")
	if connStr == "" {
		connStr = "host=db port=5432 user=postgres password=postgres dbname=topvinusa sslmode=disable"
	}
	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Database connection error:", err)
	}
	if err = db.Ping(); err != nil {
		log.Fatal("Database ping error:", err)
	}
	log.Println("History DB connected successfully")
}

// Эндпоинт для добавления истории поиска
func addHistoryHandler(w http.ResponseWriter, r *http.Request) {
	var item HistoryItem
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}
	// UPSERT: если такой VIN уже есть у пользователя, обновляем дату и данные
	_, err := db.Exec(`
        INSERT INTO search_history (user_id, vin, make, model, year, searched_at)
        VALUES ($1, $2, $3, $4, $5, $6)
        ON CONFLICT (user_id, vin) DO UPDATE
        SET searched_at = EXCLUDED.searched_at, make = EXCLUDED.make, model = EXCLUDED.model, year = EXCLUDED.year
    `, item.UserID, item.VIN, item.Make, item.Model, item.Year, time.Now())
	if err != nil {
		http.Error(w, "DB error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

// Эндпоинт для получения истории пользователя
func getUserHistoryHandler(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		http.Error(w, "user_id required", http.StatusBadRequest)
		return
	}
	rows, err := db.Query(`
        SELECT vin, make, model, year, searched_at
        FROM search_history
        WHERE user_id=$1
        ORDER BY searched_at DESC
        LIMIT 50
    `, userID)
	if err != nil {
		http.Error(w, "DB error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var history []HistoryItem
	for rows.Next() {
		var item HistoryItem
		if err := rows.Scan(&item.VIN, &item.Make, &item.Model, &item.Year, &item.SearchedAt); err == nil {
			history = append(history, item)
		}
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(history)
}

func main() {
	initDB()
	http.HandleFunc("/add", addHistoryHandler)      // POST: добавить запись
	http.HandleFunc("/user", getUserHistoryHandler) // GET: получить историю по user_id
	log.Println("History service running on :8082")
	log.Fatal(http.ListenAndServe(":8082", nil))
}
