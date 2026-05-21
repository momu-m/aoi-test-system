-- ============================================
-- AOI-Test-System: Datenbank-Schema
-- Supabase Projekt: yrephxnnkifrmwkqyzsa
-- Erstellt: 2026-05-21
-- ============================================

-- 1. Benutzer-Tabelle (Pruefer + Operatoren)
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    employee_number TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('pruefer', 'operator')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(name, employee_number)
);

-- 2. Tests-Tabelle
CREATE TABLE IF NOT EXISTS tests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL DEFAULT 'AOI-Beurteilungstest',
    description TEXT DEFAULT '',
    section_title TEXT DEFAULT 'Beurteilung nach IPC-A-610',
    passing_score INTEGER DEFAULT 24,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Fragen-Tabelle
CREATE TABLE IF NOT EXISTS questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
    question_number INTEGER NOT NULL,
    correct_answer TEXT NOT NULL CHECK (correct_answer IN ('gut', 'nicht_gut')),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Bilder-Tabelle (Verweise auf Supabase Storage)
CREATE TABLE IF NOT EXISTS question_images (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_order INTEGER DEFAULT 0,
    uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Testergebnisse-Tabelle
CREATE TABLE IF NOT EXISTS test_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
    operator_id UUID REFERENCES users(id) ON DELETE SET NULL,
    operator_name TEXT,
    operator_number TEXT,
    score INTEGER DEFAULT 0,
    max_score INTEGER DEFAULT 0,
    passed BOOLEAN DEFAULT false,
    time_seconds INTEGER DEFAULT 0,
    operator_signature TEXT,
    examiner_signature TEXT,
    examiner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    finalized BOOLEAN DEFAULT false,
    completed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Einzelne Antworten-Tabelle
CREATE TABLE IF NOT EXISTS answers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    result_id UUID REFERENCES test_results(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id) ON DELETE SET NULL,
    answer TEXT,
    is_correct BOOLEAN,
    comment TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Storage Bucket fuer AOI-Bilder erstellen
INSERT INTO storage.buckets (id, name, public) 
VALUES ('aoi-images', 'aoi-images', true)
ON CONFLICT (id) DO NOTHING;

-- 8. RLS (Row Level Security) aktivieren
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;

-- 9. Oeffentliche Lese-Richtlinien (anon kann lesen)
CREATE POLICY "Oeffentliches Lesen: Benutzer" ON users FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Oeffentliches Lesen: Tests" ON tests FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Oeffentliches Lesen: Fragen" ON questions FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Oeffentliches Lesen: Bilder" ON question_images FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Oeffentliches Lesen: Ergebnisse" ON test_results FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Oeffentliches Lesen: Antworten" ON answers FOR SELECT TO anon, authenticated USING (true);

-- 10. Schreib-Richtlinien (anon kann alles - fuer einfache Nutzung ohne Auth)
CREATE POLICY "Schreiben: Benutzer" ON users FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Schreiben: Tests" ON tests FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Schreiben: Tests Update" ON tests FOR UPDATE TO anon, authenticated USING (true);
CREATE POLICY "Schreiben: Tests Delete" ON tests FOR DELETE TO anon, authenticated USING (true);

CREATE POLICY "Schreiben: Fragen" ON questions FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Schreiben: Fragen Update" ON questions FOR UPDATE TO anon, authenticated USING (true);
CREATE POLICY "Schreiben: Fragen Delete" ON questions FOR DELETE TO anon, authenticated USING (true);

CREATE POLICY "Schreiben: Bilder" ON question_images FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Schreiben: Bilder Delete" ON question_images FOR DELETE TO anon, authenticated USING (true);

CREATE POLICY "Schreiben: Ergebnisse" ON test_results FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Schreiben: Ergebnisse Update" ON test_results FOR UPDATE TO anon, authenticated USING (true);

CREATE POLICY "Schreiben: Antworten" ON answers FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Schreiben: Antworten Update" ON answers FOR UPDATE TO anon, authenticated USING (true);

-- 11. Storage-Richtlinien
CREATE POLICY "Bilder oeffentlich lesbar" ON storage.objects FOR SELECT USING (bucket_id = 'aoi-images');
CREATE POLICY "Bilder hochladen" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'aoi-images');
CREATE POLICY "Bilder loeschen" ON storage.objects FOR DELETE USING (bucket_id = 'aoi-images');

-- 12. Index fuer bessere Performance
CREATE INDEX IF NOT EXISTS idx_questions_test_id ON questions(test_id);
CREATE INDEX IF NOT EXISTS idx_images_question_id ON question_images(question_id);
CREATE INDEX IF NOT EXISTS idx_results_test_id ON test_results(test_id);
CREATE INDEX IF NOT EXISTS idx_results_operator_id ON test_results(operator_id);
CREATE INDEX IF NOT EXISTS idx_answers_result_id ON answers(result_id);
