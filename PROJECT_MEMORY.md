# AOI-Test-System - Projekt-Gedaechtnis

> **Letzte Aktualisierung:** 22.05.2026 (v2.5 — alles aktuell)
> **Dieses Dokument dient als Kontext fuer neue Chat-Sitzungen. Lies alles ab hier.**

---

## >>> WICHTIGE LINKS & ZUGANGSDATEN (fuer neuen Chat kopieren) <<<

### Live-App & Hosting
- **App (Live):** https://momu-m.github.io/aoi-test-system/
- **GitHub Repo:** https://github.com/momu-m/aoi-test-system
- **GitHub Pages deployed from:** Branch `main`, Root `/`

### Supabase (Datenbank + Storage)
- **Supabase Dashboard:** https://supabase.com/dashboard/project/yrephxnnkifrmwkqyzsa
- **Supabase Project URL:** `https://yrephxnnkifrmwkqyzsa.supabase.co`
- **Supabase Anon Key (public):** `sb_publishable_nFZwPKhntA1nzMbcqWJfUg_I9JyM7WD`
- **Supabase Storage Bucket:** `aoi-images`
- **Projekt-Referenz-ID:** `yrephxnnkifrmwkqyzsa`

### Admin-Login (fuer Tests)
- **Name:** `Mohamad Murad`
- **Mitarbeiternummer:** `Mohamad89n`
- **Rolle:** `admin` (einziger Admin im System)

### Projekt-Verzeichnis (lokal)
- **Projekt-Root:** `/Users/momu/html/aoi/KohYoung/aoi-test-system/`
- **Hauptdatei:** `/Users/momu/html/aoi/KohYoung/aoi-test-system/index.html`
- **Diese Datei:** `/Users/momu/html/aoi/KohYoung/aoi-test-system/PROJECT_MEMORY.md`

### SQL-Dateien (muessen in Supabase SQL Editor ausgefuehrt werden)
- **setup.sql:** Initiales DB-Schema (6 Tabellen) — BEREITS AUSGEFUEHRT
- **update_v2.sql:** v2 Updates (explanations, defects) — BEREITS AUSGEFUEHRT
- **fix_v22.sql:** Delete-Policy + Admin-Account — **AUSGEFUEHRT**
- **fix_v23.sql:** FK-Constraints ON DELETE SET NULL — **AUSGEFUEHRT**
- **fix_v24.sql:** DELETE-Policies fuer test_results + answers — **AUSGEFUEHRT**
- **fix_v25.sql:** Zeitlimit-Spalte (time_limit) — **MUSS NOCH AUSGEFUEHRT WERDEN**

### Referenz-Dateien (lokal, nicht im Repo)
- **AOI-Fotos (lokal, 252 Stueck):** `/Users/momu/html/aoi/KohYoung/FotosAOI/`
- **Foto-Workflow:** Bilder werden bei der Testerstellung direkt vom Computer hochgeladen (komprimiert auf max 1200px → Supabase Storage `aoi-images`)
- **Original Offline-Version:** `/Users/momu/html/AOI_Test/AOI-Test_MIT_TIMER_UND_UNTERSCHRIFT.html`
- **KI-Anweisungen:** `/Users/momu/html/ki/Ki/Anweisungen für Claude.md`
- **Projektregeln (IPERKA/SMART):** `/Users/momu/html/ki/Ki/projekten.md`
- **KohYoung Handbuch:** `/Users/momu/html/aoi/KohYoung/KohYoung_AOI_Bedienerhandbuch_dt_Ver1.0_[C-Platform]_M_size.pdf`

---

## >>> WAS IST DIESER PROJEKT? <<<

**AOI (Automated Optical Inspection) Test-/Trainingssystem** fuer **Asetronics AG**, Belp bei Bern.

- Asetronics stellt Leiterplatten (PCBs) her
- AOI-Maschine: KohYoung C-Platform
- Operatoren pruefen Leiterplatten visuell — dieses System testet/trainiert ihre Faehigkeiten
- Operatoren sind **keine deutschen Muttersprachler** → einfache Klick-Buttons statt Freitext
- **Nur EIN Admin** (Mohamad Murad) — alle anderen sind Operatoren
- **100% kostenlos** — kein bezahlter Service

### Technologie-Stack
| Was | Technologie |
|---|---|
| Frontend | Single HTML-Datei (index.html, ~1912 Zeilen) |
| Hosting | GitHub Pages (kostenlos) |
| Datenbank | Supabase PostgreSQL (Free Tier) |
| Bildspeicher | Supabase Storage Bucket `aoi-images` |
| PDF-Export | jsPDF + html2canvas (CDN) |
| Unterschriften | HTML5 Canvas (Zeichnen, High-DPI Support) |
| Auth | Keine echte Auth — Login mit Name+Nummer, Rolle aus DB |
| i18n | Eigenes System (DE/EN), Sprache in localStorage |

---

## >>> DATENBANK-SCHEMA <<<

6 Tabellen in Supabase + 1 Lookup-Tabelle:

```
users
├── id (uuid, PK)
├── name (text)
├── employee_number (text, unique)
├── role (text: 'admin' | 'operator')
└── created_at

tests
├── id (uuid, PK)
├── title, description, passing_score, is_active
├── time_limit (integer, Minuten, 0=kein Limit) — NEU in v2.5
├── created_by → users.id
└── created_at, updated_at

questions
├── id (uuid, PK)
├── test_id → tests.id
├── question_number, correct_answer ('gut'|'nicht_gut'), explanation
└── sort_order

question_images
├── id (uuid, PK)
├── question_id → questions.id
├── image_url (text, public URL aus Storage)
└── image_order

test_results
├── id (uuid, PK)
├── test_id → tests.id
├── operator_id → users.id (ON DELETE SET NULL)
├── operator_name, operator_number
├── score, max_score, passed, time_seconds
├── operator_signature, examiner_signature (Base64 text)
├── finalized (boolean)
└── completed_at

answers
├── id (uuid, PK)
├── result_id → test_results.id
├── question_id → questions.id
├── answer, is_correct, selected_defects, comment

defect_categories (Lookup-Tabelle, in update_v2.sql erstellt)
├── id, category, label_de, label_en, icon, sort_order
└── (Wird aktuell nicht im Code verwendet — Defects sind hardcoded mit i18n)
```

### RLS-Policies (Row Level Security)
- Alle Tabellen: anon SELECT, INSERT, UPDATE erlaubt
- `users`: DELETE erlaubt (fix_v22.sql)
- `test_results` + `answers`: DELETE erlaubt (fix_v24.sql)
- Kein Supabase Auth — anon Key wird verwendet

---

## >>> FEATURES <<<

### Admin (Mohamad Murad)
- Login mit Name + Mitarbeiternummer → Rolle aus DB
- Dashboard: Test-Uebersicht mit Statistik-Karten (Tests, Aktiv, Ergebnisse, Bestehensquote)
- Tests erstellen/bearbeiten: Fragen, Bilder upload, Musterloesung, Erklaerung, Zeitlimit
- Tests duplizieren (neu in v2.5)
- Benutzer verwalten: Operatoren + Admins registrieren, Name/Nummer/**Rolle** aendern, entfernen
- Ergebnisse einsehen + loeschen
- CSV-Export fuer Excel (neu in v2.5)
- Operator-Uebersicht: Statistiken pro Operator
- PDF-Export
- Admin-Anleitung (Help View, DE + EN, neu in v2.5)

### Operator — Test-Ablauf (v2.5)
1. Fragen beantworten: IO/NIO + Fehlergruende als Klick-Chips, Timer laeuft
2. **Zeitlimit** (wenn gesetzt): Test wird automatisch abgeschlossen bei Ablauf (neu in v2.5)
3. "Test abschliessen" → Timer stoppt, Fragen werden read-only
4. Resultat sehen: Richtig/Falsch pro Frage, Erklaerung, Musterloesung
5. Unterschreiben: Unterschrift Mitarbeiter (Pflicht) + Pruefer (optional)
6. "Unterschreiben & Speichern" → Ergebnis in DB gespeichert
7. Ergebnis-Ansicht: TEST ABGESCHLOSSEN Banner, Score, PDF drucken

### Mehrsprachigkeit (neu in v2.5)
- **Deutsch** und **Englisch** — Umschalter in der Navbar (DE/EN)
- Sprache wird in localStorage gespeichert
- Alle UI-Texte uebersetzt (Buttons, Labels, Meldungen, Fehlerkategorien)
- Admin-Anleitung komplett auf DE und EN verfuegbar

### Vordefinierte Fehlerkategorien (Klick-Chips bei NIO, mit i18n)
- **Loetfehler:** Kalte Loetstelle, Zu viel Lot, Zu wenig Lot, Lotbruecke
- **Platzierung:** Bauteil fehlt, verdreht, verschoben, falsches, gekippt
- **Reinigung:** Flux-Reste, Kontamination
- **Mechanisch:** LP beschaedigt, Leiterbahn defekt
- **Polaritaet:** Pol falsch
- **Sonstiges:** Beschriftung fehlt, Sonstiger Fehler

---

## >>> WAS IST ERLEDIGT? <<<

- [x] Komplette SPA mit Supabase-Backend
- [x] v2.0: Basis-System (Tests, Fragen, Bilder, PDF, Unterschriften)
- [x] v2.1: Fehlerkategorien, Validierung, Erklaerungen, Registrierung
- [x] v2.2: Admin-only System, Zurueck-Buttons, Delete-Fix
- [x] v2.2.1: Asetronics-Logo, fix_v22.sql
- [x] v2.3: FK-Constraints Fix, Logo im PDF, Benutzer-Editierung
- [x] v2.4: Neuer Test-Ablauf (pruefen vor unterschreiben), Ergebnisse loeschen, Operator-Uebersicht, Rollen-Waehler
- [x] v2.5: Mehrsprachigkeit DE/EN, Admin-Anleitung (Help View), XSS-Schutz, Timer-Fix (Date.now), High-DPI Signature, CSV-Export, Statistik-Dashboard, Test-Duplikation, Zeitlimit, Rollenaenderung, Fehlerbehandlung verbessert

---

## >>> WAS IST OFFEN / TODO? <<<

### Sofort — User muss SQL ausfuehren
- [ ] **fix_v25.sql** — Zeitlimit-Spalte `time_limit` zur tests-Tabelle hinzufuegen

### Naechste Schritte
- [ ] **Erste echte Tests erstellen** — in der App als Admin: Bilder direkt vom Computer pro Frage hochladen
- [ ] **Operatoren registrieren** — in der App: Benutzer verwalten

### Spaeter (nice-to-have)
- [ ] Bessere PDF (Vektor statt Screenshot)
- [ ] Echte Authentifizierung (Supabase Auth)
- [ ] Defect-Kategorien aus DB laden statt hardcoded
- [ ] Offline-Modus (Service Worker)
- [ ] Mobile-Optimierung fuer Tablets

---

## >>> KONTEXT: USER <<<

- **Name:** Mohamad Murad
- **Firma:** Asetronics AG, Belp bei Bern
- **Rolle:** Betriebstechniker (Operating Technician)
- **Ausbildung:** TEKO Bern (Schweiz)
- **Maschine:** KohYoung AOI, C-Platform
- **Muttersprache:** Nicht Deutsch → einfaches Deutsch, Schritt-fuer-Schritt
- **Arbeitsweise:** IPERKA-Methodik, SMART-Ziele, pragmatisch
- **Chat-Präferenz:** Keine langen Gespraeche — direkt zur Sache

---

## >>> GIT-HISTORIE <<<

```
(NEU) v2.5: Mehrsprachigkeit DE/EN, Admin-Anleitung, Sicherheitsfixes, CSV, Stats, Duplikation, Zeitlimit
a89b8ff  v2.4.2: Storage aufgeraeumt, Foto-Workflow geklaert
e146c2e  v2.4.1: 252 AOI-Fotos importiert (spaeter wieder geloescht)
84acaa3  v2.4: Test-Ablauf umgestellt, Ergebnisse loeschen, Operator-Uebersicht
e1145b7  v2.3: FK-Constraints Fix, Logo im PDF, Benutzer-Editierung
7ad734b  v2.2.1: Asetronics-Logo, SQL-Fix Admin-Rolle
60b0a1d  v2.2: Admin-System, Benutzer-Loeschung, Zurueck-Buttons
6c553ec  v2.1: Fehlerkategorien, Validierung, Erklaerungen
d81fd3f  README mit Einrichtungsanleitung
3bb3c3d  v2.0: Komplette SPA mit Supabase
```

---

## >>> BEKANNTE EINSCHRAENKUNGEN <<<

1. Keine echte Auth — Name+Nummer reicht zum Login
2. Anon Key im Frontend-Code sichtbar (RLS schuetzt Daten)
3. PDF ist Screenshot-basiert (keine Vektor-PDF)
4. Unterschriften als Base64 in DB (wird gross bei vielen Tests)
5. Supabase Free Tier: 500MB Storage, 50MB DB, 5GB Bandbreite/Monat
6. Defect-Kategorien hardcoded (nicht aus DB geladen)

---

## >>> QUICK-START FUER NEUEN CHAT <<<

**Schritt 1:** Sag dem neuen Chat:
> "Lies die Datei `/Users/momu/html/aoi/KohYoung/aoi-test-system/PROJECT_MEMORY.md` und arbeite damit weiter."

**Schritt 2:** Der Chat liest alles und weiss:
- Alle Links, Keys, URLs
- Was das Projekt ist
- Was erledigt ist
- Was noch offen ist
- Wo die Dateien liegen

**Schritt 3:** Direkt am offenen Punkt weiterarbeiten (meistens: fix_v25.sql ausfuehren, erste Tests erstellen, Operatoren registrieren)

---

## >>> v2.5 AENDERUNGEN IM DETAIL <<<

### Neue CSS-Klassen
- `.lang-switch`, `.lang-btn` — Sprach-Umschalter
- `.help-nav`, `.help-nav-btn` — Help-Navigation
- `.help-step`, `.help-step-num` — Schritt-fuer-Schritt
- `.help-tip`, `.help-warn` — Hinweis/Warnung
- `.stats-grid`, `.stats-card`, `.stats-big` — Statistik-Karten
- `.toast` — Toast-Benachrichtigungen

### Neue JavaScript-Funktionen
- `t(key)` — Uebersetzungsfunktion (i18n)
- `escHtml(s)` — XSS-Schutz (HTML escaping)
- `setLang(lang)` — Sprache wechseln
- `applyLang()` — Alle statischen Elemente aktualisieren
- `getDefects()` — Fehlerkategorien mit i18n
- `showToast(msg, type)` — Toast statt alert()
- `loadAdminStats()` — Statistik-Karten laden
- `duplicateTest(id)` — Test kopieren
- `exportCSV()` — CSV-Export
- `showHelp()` — Admin-Anleitung anzeigen
- `showHelpSection(id)` — Help-Sektion wechseln
- `goBackFromHelp()` — Zurueck von Help

### Geaenderte Funktionen (alle mit i18n + XSS-Fix)
- `doLogin()`, `loadTests()`, `loadUsers()`, `registerOperator()`, `deleteUser()`
- `saveUserEdit()` — jetzt auch Rollenaenderung
- `showCreateTest()`, `editTest()`, `saveTest()` — jetzt mit Zeitlimit
- `renderEditQ()`, `loadOpTests()`, `loadOpHistory()`
- `startTest()` — genauer Timer (Date.now), Zeitlimit-Pruefung
- `renderTakeQ()` — i18n-Fehlerkategorien
- `checkComplete()`, `cancelTest()`
- `reviewTest()`, `backToTest()` — genauer Timer
- `finalizeTest()`, `viewResult()`
- `showOperatorOverview()`, `showPrueferResults()`, `deleteResult()`
- `initSig()` — High-DPI Support
- `rmImg()` — kein silent catch mehr

### Neue HTML-Views
- `viewHelp` — Admin-Anleitung (6 Sektionen, DE + EN)
- Toast-Element
- Sprach-Umschalter in Navbar
- Statistik-Bereich im Dashboard
- CSV-Export-Button bei Ergebnisse
- Zeitlimit-Feld bei Testerstellung
