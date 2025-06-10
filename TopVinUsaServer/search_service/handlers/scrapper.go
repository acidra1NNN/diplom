package handlers

import (
	"context"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/chromedp/cdproto/network"
	"github.com/chromedp/chromedp"
)

// ScrapeResult содержит результат парсинга
type ScrapeResult struct {
	Damage    string `json:"damage"`
	RunsDrive string `json:"runs_drives"`
}

// FetchCopartHTML теперь обрабатывает cookies правильно
func FetchCopartHTML(vin string) (string, error) {
	// Изменяем URL для лучшего поиска
	archiveURL := fmt.Sprintf("https://plc.auction/ru/auction/copart/lot-search?query=%s", vin)
	log.Printf("Starting to fetch URL: %s", archiveURL)

	opts := append(chromedp.DefaultExecAllocatorOptions[:],
		chromedp.Flag("headless", true),
		chromedp.Flag("disable-gpu", true),
		chromedp.Flag("no-sandbox", true),
		chromedp.Flag("disable-web-security", true),
	)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	allocCtx, cancel := chromedp.NewExecAllocator(ctx, opts...)
	defer cancel()

	chromeCtx, cancel := chromedp.NewContext(
		allocCtx,
		chromedp.WithLogf(log.Printf),
	)
	defer cancel()

	var html string
	err := chromedp.Run(chromeCtx,
		network.Enable(),
		chromedp.Navigate(archiveURL),
		chromedp.Sleep(5*time.Second),
		chromedp.OuterHTML("html", &html),
	)

	if err != nil {
		return "", fmt.Errorf("navigation error: %w", err)
	}

	return html, nil
}

// ParseCopartHTML парсит HTML и возвращает damage и runs&drives
func ParseCopartHTML(html string) ScrapeResult {
	log.Printf("Starting to parse HTML")
	log.Printf("HTML length: %d chars", len(html))

	result := ScrapeResult{
		Damage:    "Нет данных",
		RunsDrive: "Нет данных",
	}

	// Простая проверка на наличие ключевых слов
	html = strings.ToLower(html)
	hasDamage := strings.Contains(html, "damage")
	hasRunsDrives := strings.Contains(html, "runs & drives")

	log.Printf("Contains 'damage': %v, Contains 'runs & drives': %v",
		hasDamage, hasRunsDrives)

	if hasDamage {
		result.Damage = extractDamageInfo(html)
	}
	if hasRunsDrives {
		result.RunsDrive = "Заводится и едет"
	}

	log.Printf("Parsing completed. Results: Damage='%s', RunsDrive='%s'",
		result.Damage, result.RunsDrive)
	return result
}

// Вспомогательные функции для извлечения информации
func extractDamageInfo(html string) string {
	if idx := strings.Index(html, "damage"); idx != -1 {
		// Простое извлечение текста после "damage"
		text := html[idx+6:]
		if end := strings.IndexAny(text, "<\n"); end != -1 {
			return strings.TrimSpace(text[:end])
		}
	}
	return "Нет данных"
}
