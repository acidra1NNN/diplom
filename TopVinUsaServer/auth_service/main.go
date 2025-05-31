package main

import (
	"log"
	"net/http"
	"auth_service/handlers"
	"auth_service/model"
)

func main() {
	model.InitDB()

	http.HandleFunc("/register", handlers.Register)
	http.HandleFunc("/login", handlers.Login)

	log.Println("Auth service running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
