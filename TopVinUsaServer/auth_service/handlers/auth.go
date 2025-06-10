package handlers

import (
	"auth_service/model"
	"encoding/json"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

var jwtKey = []byte("your_secret_key")

type Credentials struct {
	Username string `json:"username,omitempty"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type Claims struct {
	Email  string `json:"email"`
	UserID int    `json:"user_id"`
	jwt.RegisteredClaims
}

// RegisterHandler handles user registration
func RegisterHandler(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		http.Error(w, "Неверный формат данных", http.StatusBadRequest)
		return
	}

	// Проверка email
	if creds.Email == "" {
		http.Error(w, "Email не может быть пустым", http.StatusBadRequest)
		return
	}

	// Проверка пароля
	if len(creds.Password) < 6 {
		http.Error(w, "Пароль должен содержать минимум 6 символов", http.StatusBadRequest)
		return
	}

	// Проверка существующего email
	var exists bool
	err := model.DB.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)", creds.Email).Scan(&exists)
	if err != nil {
		http.Error(w, "Ошибка при проверке email", http.StatusInternalServerError)
		return
	}
	if exists {
		http.Error(w, "Пользователь с таким email уже существует", http.StatusConflict)
		return
	}

	// Хеширование пароля
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(creds.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Ошибка при хешировании пароля", http.StatusInternalServerError)
		return
	}

	// Сохранение в базу
	_, err = model.DB.Exec(`
        INSERT INTO users (username, email, password_hash) 
        VALUES ($1, $2, $3)`,
		creds.Username, creds.Email, string(hashedPassword))
	if err != nil {
		http.Error(w, "Ошибка при регистрации пользователя", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
}

// LoginHandler handles user authentication
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	if err := json.NewDecoder(r.Body).Decode(&creds); err != nil {
		http.Error(w, "Неверный формат данных", http.StatusBadRequest)
		return
	}

	if creds.Email == "" {
		http.Error(w, "Email не может быть пустым", http.StatusBadRequest)
		return
	}

	if creds.Password == "" {
		http.Error(w, "Пароль не может быть пустым", http.StatusBadRequest)
		return
	}

	var storedHash string
	var userID int
	err := model.DB.QueryRow(`
        SELECT id, password_hash 
        FROM users 
        WHERE email = $1`,
		creds.Email).Scan(&userID, &storedHash)
	if err != nil {
		http.Error(w, "Пользователь не найден", http.StatusUnauthorized)
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(storedHash), []byte(creds.Password)); err != nil {
		http.Error(w, "Неверный пароль", http.StatusUnauthorized)
		return
	}

	// Генерация JWT
	expiration := time.Now().Add(24 * time.Hour)
	claims := &Claims{
		Email:  creds.Email,
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiration),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signedToken, err := token.SignedString(jwtKey)
	if err != nil {
		http.Error(w, "Ошибка при генерации токена", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Authorization", "Bearer "+signedToken)
	w.WriteHeader(http.StatusOK)
}

// Helper functions
func HashPassword(password string) (string, error) {
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(bytes), err
}

func CheckPasswordHash(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func GenerateJWTWithUserID(email string, userID int) (string, error) {
	expiration := time.Now().Add(24 * time.Hour)
	claims := &Claims{
		Email:  email,
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiration),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtKey)
}
