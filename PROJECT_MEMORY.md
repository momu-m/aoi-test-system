# AOI-Test-System - Projekt-Gedaechtnis

> **Letzte Aktualisierung:** 21.05.2026 (v2.4)
> **Dieses Dokument dient als Kontext fuer neue Chat-Sitzungen.**

---

## 1. Was ist dieses Projekt?

Ein webbasiertes **AOI (Automated Optical Inspection) Test-/Trainingssystem** fuer **Asetronics AG** in Belp bei Bern. Es wird verwendet, um Operatoren (Mitarbeiter an AOI-Maschinen) zu pruefen und zu schulen.

### Situation bei Asetronics
- Asetronics stellt Leiterplatten (PCBs) her
- AOI-Maschine: KohYoung (Modell C-Platform)
- Die Operatoren sind **keine deutschen Muttersprachler** — deshalb muessen Eingaben einfach sein (Klick-Buttons statt Freitext)
- Es gibt **nur EINEN Admin** (Mohamad Murad) — alle anderen sind Operatoren
- Das System muss **100% kostenlos** sein (keine bezahlten Dienste)

### Technologie-Stack
| Komponente | Technologie | Kosten |
|---|---|---|
| Frontend | Single-Page App (eine index.html) | Kostenlos |
| Hosting | GitHub Pages | Kostenlos |
| Datenbank | Supabase (PostgreSQL) | Kostenlos (Free Tier) |
| Bildspeicher | Supabase Storage (`aoi-images`) | Kostenlos (Free Tier) |
| PDF-Export | jsPDF + html2canvas (CDN) | Kostenlos |
| Unterschriften | HTML5 Canvas (Draw-on-Pad) | Kostenlos |

### URLs
- **Live-App:** https://momu-m.github.io/aoi-test-system/
- **GitHub Repo:** https://github.com/momu-m/aoi-test-system (Branch: main)
- **Supabase Dashboard:** https://supabase.com/dashboard/project/yrephxnnkifrmwkqyzsa
- **Supabase Anon Key:** `sb_publishable_nFZwPKhntA1nzMbcqWJfUg_I9JyM7WD`
- **Supabase URL:** `https://yrephxnnkifrmwkqyzsa.supabase.co`

---

## 2. Datenbank-Schema (Supabase)

6 Tabellen:

| Tabelle | Beschreibung |
|---|---|
| `users` | Benutzer mit `role` ('admin' oder 'operator'), `name`, `employee_number` |
| `tests` | Tests mit `title`, `description`, `passing_score`, `is_active`, `created_by` |
| `questions` | Fragen pro Test mit `question_number`, `correct_answer` ('gut'/'nicht_gut'), `explanation` |
| `question_images` | Bilder pro Frage (URL aus Supabase Storage) |
| `test_results` | Testergebnisse mit Score, Passed/Failed, Zeit, Unterschriften (Base64) |
| `answers` | Einzelne Antworten pro Frage mit `selected_defects`, `comment`, `is_correct` |

### Wichtige RLS-Policies
- Alle Tabellen erlauben anon read/write (vereinfacht, da keine Supabase Auth)
- `fix_v22.sql`: DELETE + UPDATE Policies fuer `users`
- `fix_v23.sql`: FK-Constraints ON DELETE SET NULL korrigiert
- `fix_v24.sql`: DELETE Policies fuer `test_results` und `answers` (Admin kann Ergebnisse loeschen)

---

## 3. Funktionen (Features)

### Admin (Mohamad Murad)
- **Login** mit Name + Mitarbeiternummer (Rolle kommt aus DB, kein Waehler)
- **Dashboard** mit Test-Uebersicht (aktiv/inaktiv)
- **Tests erstellen/bearbeiten**: Titel, Beschreibung, Mindestpunktzahl, Fragen mit Bildern
- **Bilder upload**: Komprimierung auf max 1200px, Upload zu Supabase Storage
- **Musterloesung** pro Frage: Gut (IO) oder Nicht gut (NIO)
- **Erklaerung** pro Frage (wird Operator nach dem Test angezeigt)
- **Benutzer verwalten**: Operatoren UND Admins/Pruefer registrieren, Name/Nummer aendern, entfernen
- **Ergebnisse einsehen**: Alle Testergebnisse mit Details
- **Ergebnisse loeschen**: Einzelne Testergebnisse entfernen
- **Operator-Uebersicht**: Alle Operatoren mit Statistiken (Durchschnitt, Bestanden/Fail, letzte Ergebnisse)
- **PDF-Export**: jsPDF + html2canvas

### Operator — Test-Ablauf (v2.4)
1. **Fragen beantworten**: IO/NIO + Fehlergruende, Timer laeuft
2. **"Test abschliessen"** klicken → Timer stoppt, Fragen werden read-only
3. **Resultat sehen**: Richtig/Falsch pro Frage, Erklaerung, Musterloesung (kann NICHT korrigiert werden)
4. **Unterschreiben**: Unterschrift Mitarbeiter (Pflicht) + Pruefer (optional)
5. **"Unterschreiben & Speichern"** → Ergebnis wird in DB gespeichert
6. **Ergebnis-Ansicht**: TEST ABGESCHLOSSEN Banner, Score, PDF drucken, Test schliessen

### PDF-Export
- Generiert PDF mit html2canvas (Screenshot der Ergebnis-Seite)
- A4-Format, mehrseitig bei langen Tests
- Enthaelt: Logo, Score, Fragen, Antworten, Bilder, Unterschriften
- Buttons "PDF drucken" und "Test schliessen" erscheinen NICHT im PDF
- Dateiname: `AOI-Test_YYYY-MM-DD.pdf`

---

## 4. Was ist ERLEDIGT?

- [x] Komplette SPA (index.html) mit allen Funktionen
- [x] Supabase-Datenbank mit 6 Tabellen (setup.sql)
- [x] v2.1: Fehlerkategorien als Klick-Chips, Validierung, Erklaerungen, Registrierung
- [x] v2.2: Admin-only System (keine Selbstregistrierung als Admin)
- [x] v2.2: Zurueck-Buttons auf allen Seiten
- [x] v2.2: Benutzer-Loeschung (mit fix_v22.sql)
- [x] v2.2.1: Asetronics-Logo integriert
- [x] v2.2.1: fix_v22.sql ausgefuehrt (Admin-Account + Delete-Policy)
- [x] v2.3: FK-Constraints korrigiert (fix_v23.sql) — User-Loeschung trotz Testergebnissen
- [x] v2.3: Logo im PDF-Export sichtbar
- [x] v2.3: Benutzer-Daten editierbar (Name + Mitarbeiternummer aenderbar)
- [x] v2.4: Test-Ablauf umgestellt: Antworten → Pruefen → Unterschreiben → Speichern
- [x] v2.4: Richtig/Falsch pro Frage VOR der Unterschrift sichtbar (read-only)
- [x] v2.4: Admin kann Testergebnisse loeschen
- [x] v2.4: Operator-Uebersicht (Statistiken pro Operator)
- [x] v2.4: Benutzerverwaltung mit Rollen-Waehler (Operator oder Admin/Pruefer)
- [x] v2.4: PDF-Export ohne Buttons (no-print korrigiert)
- [x] Alles committed und auf GitHub Pages deployed

---

## 5. Was ist OFFEN / TODO?

### Blockiert — User muss etwas tun
- [ ] **fix_v23.sql in Supabase SQL Editor ausfuehren!** (falls noch nicht gemacht)
  - Korrigiert FK-Constraints damit Benutzer geloescht werden koennen
- [ ] **fix_v24.sql in Supabase SQL Editor ausfuehren!**
  - Fuegt DELETE-Policies fuer `test_results` und `answers` hinzu
  - Ohne dieses SQL: Loeschen-Button bei Ergebnissen funktioniert nicht

### Naechste Schritte
- [ ] **267 AOI-Fotos importieren** von `/Users/momu/html/aoi/KohYoung/FotosAOI/` in Supabase Storage
  - Dateien: p002-p025 Serie (Bilder von KohYoung AOI-Maschine)
  - Import per Script moeglich (Supabase JS SDK + Batch-Upload)
  - Danach koennen die Fotos in Test-Fragen verwendet werden
- [ ] **Erste echte Tests erstellen** mit den importierten Fotos
- [ ] **Operatoren registrieren** (in der App: Benutzer verwalten)

### Spaetere Verbesserungen (nice-to-have)
- [ ] Test-Ergebnisse als CSV exportieren (fuer Excel/Auswertung)
- [ ] Test-Vorlagen (z.B. "Standard AOI Test" mit 30 Fragen)
- [ ] Mehrere Sprachen (z.Zt. nur Deutsch, aber Operatoren sind international)
- [ ] Bessere PDF-Formatierung (direkte jsPDF-Generierung statt Screenshot)
- [ ] Echte Authentifizierung (Supabase Auth statt Name+Nummer)

---

## 6. Dateien im Projekt

| Datei | Pfad | Beschreibung |
|---|---|---|
| `index.html` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/index.html` | Die komplette SPA (~1294 Zeilen) |
| `setup.sql` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/setup.sql` | Initiale DB-Schema-Erstellung |
| `update_v2.sql` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/update_v2.sql` | v2 Schema-Updates (explanations, defects) |
| `fix_v22.sql` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/fix_v22.sql` | Fix: Delete-Policy + Admin-Account |
| `fix_v23.sql` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/fix_v23.sql` | Fix: FK-Constraints ON DELETE SET NULL |
| `fix_v24.sql` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/fix_v24.sql` | Fix: DELETE-Policies fuer Ergebnisse + Antworten |
| `README.md` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/README.md` | Projektdokumentation |
| `PROJECT_MEMORY.md` | `/Users/momu/html/aoi/KohYoung/aoi-test-system/PROJECT_MEMORY.md` | **DIESE DATEI** — Kontext fuer neue Chats |

### Wichtige Referenz-Dateien (ausserhalb des Repos)
| Datei | Pfad | Beschreibung |
|---|---|---|
| AOI-Fotos | `/Users/momu/html/aoi/KohYoung/FotosAOI/` | 267 Bilder zum Importieren |
| Original HTML | `/Users/momu/html/AOI_Test/AOI-Test_MIT_TIMER_UND_UNTERSCHRIFT.html` | Offline-Version (Validierungs-Referenz) |
| Anweisungen | `/Users/momu/html/ki/Ki/Anweisungen für Claude.md` | Regeln fuer KI-Assistenz |
| Projektregeln | `/Users/momu/html/ki/Ki/projekten.md` | IPERKA/SMART-Methodik |
| AOI-Handbuch | `/Users/momu/html/aoi/KohYoung/KohYoung_AOI_Bedienerhandbuch_dt_Ver1.0_[C-Platform]_M_size.pdf` | KohYoung Bedienungsanleitung |

---

## 7. Kontext: Wer ist der User?

- **Name:** Mohamad Murad
- **Rolle bei Asetronics AG:** Betriebstechniker (Operating Technician)
- **Ausbildung:** Studiert an der TEKO Bern (Schweiz)
- **Projekt-Kontext:** Dieses AOI-Test-System ist wahrscheinlich ein Schulungs-/IPERKA-Projekt im Rahmen der TEKO-Ausbildung
- **Arbeitet mit:** KohYoung AOI-Maschine (C-Platform) in Belp bei Bern
- **Muttersprache:** Nicht Deutsch — bevorzugt einfache, klare Anweisungen
- **Praeferenzen:**
  - IPERKA-Methodik (Informat, Planen, Entscheiden, Realisieren, Kontrollieren, Auswerten)
  - SMART-Ziele
  - Pragmatischer Ansatz je nach Situation
  - Einfaches Deutsch, Schritt-fuer-Schritt-Erklaerungen
  - Keine langen Hin-und-Her-Gespraeche — direkt zur Sache

---

## 8. Git-Historie (letzte Commits)

```
(TBD) v2.4: Test-Ablauf umgestellt, Ergebnisse loeschen, Operator-Uebersicht, Rollen-Waehler
e1145b7 v2.3: FK-Constraints Fix, Logo im PDF, Benutzer-Editierung, Test-Abschluss-Flow verbessert
7ad734b v2.2.1: Asetronics-Logo integriert, SQL-Fix fuer Admin-Rolle
60b0a1d v2.2: Admin-System (keine Selbstregistrierung), Benutzer-Loeschung repariert, Zurueck-Buttons
6c553ec v2.1: Registrierungssystem, vordefinierte Fehlerkategorien, erweiterte Validierung, Erklaerungen
d81fd3f README mit Einrichtungsanleitung und Dokumentation
3bb3c3d AOI-Test-System v2.0: Komplette SPA mit Supabase-Datenbank
```

---

## 9. Bekannte Probleme / Einschraenkungen

1. **Keine echte Authentifizierung** — Jeder mit Name+Nummer kann sich einloggen. Reicht fuer internes Training.
2. **Anon Key sichtbar** — Supabase Anon Key ist im Frontend-Code. RLS-Policies schuetzen die Daten.
3. **PDF ist Screenshot-basiert** — html2canvas macht einen Screenshot, keine echte Vektor-PDF. Kann bei langen Tests ungenau sein.
4. **Unterschriften als Base64** — Werden in der Datenbank gespeichert (kann gross werden).
5. **Supabase Free Tier Limits** — 500MB Storage, 50MB Datenbank, 5GB Bandbreite/Monat.

---

## 10. Quick-Start fuer neuen Chat

Wenn du diesen Chat fortsetzen willst:
1. Lies diese Datei: `/Users/momu/html/aoi/KohYoung/aoi-test-system/PROJECT_MEMORY.md`
2. Pruefe welche SQL-Fixes ausgefuehrt wurden (fix_v22, fix_v23, fix_v24) — User fragen
3. Pruefe aktuellen Stand: `git log --oneline -5` im Projektverzeichnis
4. Weiter mit dem naechsten offenen Punkt aus Abschnitt 5
