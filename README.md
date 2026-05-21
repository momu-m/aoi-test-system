# AOI-Test-System - Asetronics AG

Webbasiertes Test- und Schulungssystem fuer AOI-Operatoren (Automated Optical Inspection).

## Funktionen

- **Pruefer-Modus**: Tests mit Fragen und Bildern erstellen, Musterloesungen festlegen, Ergebnisse auswerten
- **Operator-Modus**: Tests durchfuehren, Bilder mit Zoom beurteilen, Timer laeuft automatisch
- **PDF-Export**: Ergebnisse mit Unterschriften als PDF exportieren
- **Datenbank**: Alle Daten (Tests, Fragen, Bilder, Ergebnisse) zentral in Supabase gespeichert
- **Bilder**: AOI-Fotos werden in Supabase Storage gespeichert und sind zoombar

## Einrichtung

### 1. Supabase Projekt einrichten

1. Auf [supabase.com](https://supabase.com) einloggen
2. Das Projekt `aoi-test-system` oeffnen
3. SQL Editor oeffnen
4. Den Inhalt von `setup.sql` einfuegen und ausfuehren

### 2. Anwendung oeffnen

Die Anwendung ist verfuegbar unter:
**https://momu-m.github.io/aoi-test-system/**

### 3. Datenbank-Schema

Die Datei `setup.sql` erstellt folgende Tabellen:
- `users` - Benutzer (Pruefer und Operatoren)
- `tests` - Test-Vorlagen
- `questions` - Fragen mit Musterloesung
- `question_images` - Bilder pro Frage
- `test_results` - Testergebnisse
- `answers` - Einzelne Antworten

## Rollen

| Rolle | Funktion |
|-------|----------|
| **Pruefer** | Tests erstellen, bearbeiten, aktivieren/deaktivieren, Ergebnisse einsehen |
| **Operator** | Verfuegbare Tests durchfuehren, Ergebnisse einsehen |

## Technologie

- Frontend: HTML + CSS + JavaScript (Single Page Application)
- Backend: Supabase (PostgreSQL + Storage)
- Hosting: GitHub Pages
- PDF: jsPDF + html2canvas
- Kosten: 0 CHF/Monat
