# AOI-Test-System - Projekt-Gedaechtnis

> **Letzte Aktualisierung:** 21.05.2026 (v2.4.2 — alles aktuell)
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
| Frontend | Single HTML-Datei (index.html, ~1294 Zeilen) |
| Hosting | GitHub Pages (kostenlos) |
| Datenbank | Supabase PostgreSQL (Free Tier) |
| Bildspeicher | Supabase Storage Bucket `aoi-images` |
| PDF-Export | jsPDF + html2canvas (CDN) |
| Unterschriften | HTML5 Canvas (Zeichnen) |
| Auth | Keine echte Auth — Login mit Name+Nummer, Rolle aus DB |

---

## >>> DATENBANK-SCHEMA <<<

6 Tabellen in Supabase:

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
- Dashboard: Test-Uebersicht, aktiv/inaktiv umschalten
- Tests erstellen/bearbeiten: Fragen, Bilder upload, Musterloesung, Erklaerung
- Benutzer verwalten: Operatoren + Admins registrieren, Name/Nummer aendern, entfernen
- Ergebnisse einsehen + loeschen
- Operator-Uebersicht: Statistiken pro Operator
- PDF-Export

### Operator — Test-Ablauf (v2.4)
1. Fragen beantworten: IO/NIO + Fehlergruende als Klick-Chips, Timer laeuft
2. "Test abschliessen" → Timer stoppt, Fragen werden read-only
3. Resultat sehen: Richtig/Falsch pro Frage, Erklaerung, Musterloesung
4. Unterschreiben: Unterschrift Mitarbeiter (Pflicht) + Pruefer (optional)
5. "Unterschreiben & Speichern" → Ergebnis in DB gespeichert
6. Ergebnis-Ansicht: TEST ABGESCHLOSSEN Banner, Score, PDF drucken

### Vordefinierte Fehlerkategorien (Klick-Chips bei NIO)
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
- [x] Alles committed und auf GitHub Pages deployed

---

## >>> WAS IST OFFEN / TODO? <<<

### ~~Sofort — User muss SQL ausfuehren~~ → ALLES AUSGEFUEHRT
- [x] **fix_v23.sql** — AUSGEFUEHRT
- [x] **fix_v24.sql** — AUSGEFUEHRT

### Naechste Schritte
- [ ] **Erste echte Tests erstellen** — in der App als Admin: Bilder direkt vom Computer pro Frage hochladen
- [ ] **Operatoren registrieren** — in der App: Benutzer verwalten

### Spaeter (nice-to-have)
- [ ] CSV-Export fuer Excel-Auswertung
- [ ] Test-Vorlagen
- [ ] Mehrsprachigkeit (Operatoren sind international)
- [ ] Bessere PDF (Vektor statt Screenshot)
- [ ] Echte Authentifizierung (Supabase Auth)

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

**Schritt 3:** Direkt am offenen Punkt weiterarbeiten (meistens: erste Tests erstellen, Operatoren registrieren)
