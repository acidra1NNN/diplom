package main

import (
	"auth_service/handlers"
	"auth_service/model"
	"log"
	"net/http"
)

func main() {
	model.InitDB()

	http.HandleFunc("/register", handlers.RegisterHandler)
	http.HandleFunc("/login", handlers.LoginHandler)

	log.Println("Auth service running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
