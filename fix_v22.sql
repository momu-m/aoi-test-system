-- ============================================
-- Fix v2.2: Admin-System + Loesch-Berechtigung
-- Ausfuehren im Supabase SQL Editor
-- ============================================

-- 1. Loesch-Berechtigung fuer Benutzer-Tabelle
CREATE POLICY "Loeschen: Benutzer" ON users FOR DELETE TO anon, authenticated USING (true);

-- 2. Update-Berechtigung fuer Benutzer-Tabelle
CREATE POLICY "Update: Benutzer" ON users FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

-- 3. Admin-Account erstellen (BITTE NAME UND NUMMER ANPASSEN!)
-- Ersetzen Sie 'Admin' und '00000' durch Ihren echten Namen und Ihre Nummer
INSERT INTO users (name, employee_number, role)
VALUES ('Admin', '00000', 'admin')
ON CONFLICT DO NOTHING;
