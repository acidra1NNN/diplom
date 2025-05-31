package main

import (
	"log"
	"net/http"
	"search_service/handlers" // добавили импорт handlers
)

func main() {
	mux := http.NewServeMux()

	// Используем handlers.SearchCarInfo вместо просто SearchCarInfo
	mux.HandleFunc("/api/search", handlers.SearchCarInfo)

	log.Println("Search service running on :8081")
	err := http.ListenAndServe(":8081", mux)
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
