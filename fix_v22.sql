-- ============================================
-- Fix v2.2: Admin-System + Loesch-Berechtigung
-- Ausfuehren im Supabase SQL Editor
-- ============================================

-- 1. Rolle-Pruefung aendern: 'admin' erlauben
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('admin', 'pruefer', 'operator'));

-- 2. Loesch-Berechtigung fuer Benutzer-Tabelle
CREATE POLICY "Loeschen: Benutzer" ON users FOR DELETE TO anon, authenticated USING (true);

-- 3. Update-Berechtigung fuer Benutzer-Tabelle
CREATE POLICY "Update: Benutzer" ON users FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

-- 4. Admin-Account erstellen
-- HIER IHREN ECHTEN NAMEN UND IHRE MITARBEITERNUMMER EINTRAGEN!
INSERT INTO users (name, employee_number, role)
VALUES ('Mohamad Murad', 'Mohamad89n', 'admin')
ON CONFLICT DO NOTHING;
