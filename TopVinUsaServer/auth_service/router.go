package main

import (
    "encoding/json"
    "net/http"
    "your_project/model"
    "your_project/auth"
)

type Credentials struct {
    Username string `json:"username"`
    Email    string `json:"email,omitempty"`
    Password string `json:"password"`
}

func RegisterHandler(w http.ResponseWriter, r *http.Request) {
    var creds Credentials
    err := json.NewDecoder(r.Body).Decode(&creds)
    if err != nil {
        http.Error(w, "Invalid request", http.StatusBadRequest)
        return
    }

    err = model.RegisterUser(creds.Username, creds.Email, creds.Password)
    if err != nil {
        http.Error(w, "Error registering user: "+err.Error(), http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusCreated)
}

func LoginHandler(w http.ResponseWriter, r *http.Request) {
    var creds Credentials
    err := json.NewDecoder(r.Body).Decode(&creds)
    if err != nil {
        http.Error(w, "Invalid request", http.StatusBadRequest)
        return
    }

    ok, err := model.AuthenticateUser(creds.Username, creds.Password)
    if !ok || err != nil {
        http.Error(w, "Invalid username or password", http.StatusUnauthorized)
        return
    }

    token, err := auth.GenerateJWT(creds.Username)
    if err != nil {
        http.Error(w, "Error generating token", http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{"token": token})
}
