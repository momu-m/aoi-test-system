-- ============================================
-- Fix v2.4: Delete-Policies + Admin-Verbesserungen
-- Ausfuehren im Supabase SQL Editor
-- ============================================

-- 1. DELETE Policy fuer test_results (Admin kann Ergebnisse loeschen)
CREATE POLICY "Loeschen: Ergebnisse" ON test_results FOR DELETE TO anon, authenticated USING (true);

-- 2. DELETE Policy fuer answers (beim Loeschen von Ergebnissen)
CREATE POLICY "Loeschen: Antworten" ON answers FOR DELETE TO anon, authenticated USING (true);
