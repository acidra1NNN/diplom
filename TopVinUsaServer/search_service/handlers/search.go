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
	if len(vin) < 17 {
		http.Error(w, "VIN too short", http.StatusBadRequest)
		return
	}

	// 1. Get basic info from NHTSA
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

	results := nhtsaResp["Results"].([]interface{})
	var make, model, year string
	for _, item := range results {
		entry := item.(map[string]interface{})
		if entry["Variable"] == "Make" {
			if v, ok := entry["Value"].(string); ok && v != "" && v != "null" {
				make = v
			}
		}
		if entry["Variable"] == "Model" {
			if v, ok := entry["Value"].(string); ok && v != "" && v != "null" {
				model = v
			}
		}
		if entry["Variable"] == "Model Year" {
			if v, ok := entry["Value"].(string); ok && v != "" && v != "null" {
				year = v
			}
		}
	}

	// 2. Try search Copart (via PLC)
	found := false
	damage := "Нет данных"
	runsDrives := "Нет данных"

	searchURL := fmt.Sprintf("https://plc.auction/ru/auction/archive/copart?query=%s", vin)
	resp2, err := http.Get(searchURL)
	if err == nil {
		defer resp2.Body.Close()
		htmlData, _ := io.ReadAll(resp2.Body)
		htmlStr := string(htmlData)

		if strings.Contains(htmlStr, vin) {
			found = true
			if strings.Contains(htmlStr, "Runs & Drives") {
				runsDrives = "Заводится и едет"
			}
			if strings.Contains(htmlStr, "Enhanced Vehicles") {
				runsDrives = "Неизвестно (Enhanced)"
			}
			if strings.Contains(htmlStr, "Primary Damage") {
				// Упрощённый парсинг
				start := strings.Index(htmlStr, "Primary Damage")
				sub := htmlStr[start : start+100]
				damage = extractAfter(sub, "Primary Damage")
			}
		}
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
