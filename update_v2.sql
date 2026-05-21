-- ============================================
-- AOI-Test-System v2: Datenbank-Aktualisierung
-- Ausfuehren im Supabase SQL Editor
-- ============================================

-- 1. Neue Spalte: Erklaerung pro Frage (Pruefer schreibt, warum die Antwort richtig ist)
ALTER TABLE questions ADD COLUMN IF NOT EXISTS explanation TEXT DEFAULT '';

-- 2. Neue Spalte: Ausgewaehlte Fehlerkategorien (als Text, kommagetrennt)
ALTER TABLE answers ADD COLUMN IF NOT EXISTS selected_defects TEXT DEFAULT '';

-- 3. Neue Tabelle: Vordefinierte Fehlerkategorien
CREATE TABLE IF NOT EXISTS defect_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    category TEXT NOT NULL,
    label_de TEXT NOT NULL,
    label_en TEXT DEFAULT '',
    icon TEXT DEFAULT '',
    sort_order INTEGER DEFAULT 0
);

-- 4. Standard-Fehlerkategorien einfuegen
INSERT INTO defect_categories (category, label_de, label_en, icon, sort_order) VALUES
('loetfehler', 'Loetfehler', 'Solder defect', 'L', 1),
('loetfehler', 'Kalte Loetstelle', 'Cold solder joint', 'L', 2),
('loetfehler', 'Zu viel Lot', 'Too much solder', 'L', 3),
('loetfehler', 'Zu wenig Lot', 'Too little solder', 'L', 4),
('loetfehler', 'Lotbruecke', 'Solder bridge', 'L', 5),
('platzierung', 'Bauteil fehlt', 'Missing component', 'P', 6),
('platzierung', 'Bauteil verdreht', 'Rotated component', 'P', 7),
('platzierung', 'Bauteil verschoben', 'Shifted component', 'P', 8),
('platzierung', 'Falsches Bauteil', 'Wrong component', 'P', 9),
('platzierung', 'Bauteil gekippt', 'Tilted component', 'P', 10),
('reinigung', 'Flux-Reste', 'Flux residue', 'R', 11),
('reinigung', 'Kontamination', 'Contamination', 'R', 12),
('mechanisch', 'Leiterplatte beschaedigt', 'Board damaged', 'M', 13),
('mechanisch', 'Leiterbahn unterbrochen', 'Broken trace', 'M', 14),
('polaritaet', 'Pol falsch', 'Wrong polarity', '+/-', 15),
('beschriftung', 'Beschriftung fehlt', 'Missing marking', 'B', 16),
('sonstiges', 'Sonstiger Fehler', 'Other defect', '?', 17)
ON CONFLICT DO NOTHING;

-- 5. Oeffentlicher Zugriff auf Fehlerkategorien
CREATE POLICY "Lesen: Fehlerkategorien" ON defect_categories FOR SELECT TO anon, authenticated USING (true);
ALTER TABLE defect_categories ENABLE ROW LEVEL SECURITY;
