package handlers // изменили с package main на package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

type SearchRequest struct {
	VIN string `json:"vin"`
}

type SearchResult struct {
	VIN           string `json:"vin"`
	Make          string `json:"make"`
	Model         string `json:"model"`
	Year          string `json:"year"`
	FoundOnCopart bool   `json:"found_on_copart"`
	Damage        string `json:"damage"`
	RunsDrives    string `json:"runs_drives"`
}

func SearchCarInfo(w http.ResponseWriter, r *http.Request) {
	var req SearchRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid input", http.StatusBadRequest)
		return
	}

	vin := strings.TrimSpace(req.VIN)

	// Получаем базовую информацию от NHTSA
	nhtsaURL := fmt.Sprintf("https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/%s?format=json", vin)
	resp, err := http.Get(nhtsaURL)
	if err != nil {
		http.Error(w, "NHTSA API error", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	var nhtsaResp map[string]interface{}
	json.Unmarshal(body, &nhtsaResp)

	// Извлекаем данные из ответа NHTSA
	results := nhtsaResp["Results"].([]interface{})
	make := "Неизвестно"
	model := "Неизвестно"
	year := "Неизвестно"

	for _, item := range results {
		entry := item.(map[string]interface{})
		switch entry["Variable"] {
		case "Make":
			if value, ok := entry["Value"].(string); ok && value != "" {
				make = value
			}
		case "Model":
			if value, ok := entry["Value"].(string); ok && value != "" {
				model = value
			}
		case "Model Year":
			if value, ok := entry["Value"].(string); ok && value != "" {
				year = value
			}
		}
	}

	// Поиск на Copart
	found := false
	damage := "Нет данных"
	runsDrives := "Нет данных"

	// Проверяем наличие на Copart
	htmlStr, err := FetchCopartHTML(vin)
	if err == nil {
		// Проверяем наличие VIN на странице
		if strings.Contains(strings.ToUpper(htmlStr), strings.ToUpper(vin)) {
			found = true
			scrapeResult := ParseCopartHTML(htmlStr)
			damage = scrapeResult.Damage
			runsDrives = scrapeResult.RunsDrive

			fmt.Printf("Found car: VIN=%s, Damage=%s, RunsDrive=%s\n",
				vin, damage, runsDrives)
		} else {
			fmt.Printf("VIN %s not found in Copart results\n", vin)
		}
	} else {
		fmt.Printf("Error fetching Copart data: %v\n", err)
	}

	result := SearchResult{
		VIN:           vin,
		Make:          make,
		Model:         model,
		Year:          year,
		FoundOnCopart: found,
		Damage:        damage,
		RunsDrives:    runsDrives,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

// extractAfter — простая утилита (можно позже заменить парсером)
func extractAfter(src, label string) string {
	idx := strings.Index(src, label)
	if idx == -1 {
		return "Неизвестно"
	}
	rest := src[idx+len(label):]
	rest = strings.TrimSpace(rest)
	return strings.Split(rest, "<")[0]
}
