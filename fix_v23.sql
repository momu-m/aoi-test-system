-- ============================================
-- Fix v2.3: FK-Constraints korrigieren
-- Loescht Benutzer auch wenn Testergebnisse existieren
-- Ausfuehren im Supabase SQL Editor
-- ============================================

-- 1. test_results: operator_id FK mit ON DELETE SET NULL
ALTER TABLE test_results DROP CONSTRAINT IF EXISTS test_results_operator_id_fkey;
ALTER TABLE test_results ADD CONSTRAINT test_results_operator_id_fkey
    FOREIGN KEY (operator_id) REFERENCES users(id) ON DELETE SET NULL;

-- 2. test_results: examiner_id FK mit ON DELETE SET NULL
ALTER TABLE test_results DROP CONSTRAINT IF EXISTS test_results_examiner_id_fkey;
ALTER TABLE test_results ADD CONSTRAINT test_results_examiner_id_fkey
    FOREIGN KEY (examiner_id) REFERENCES users(id) ON DELETE SET NULL;

-- 3. tests: created_by FK mit ON DELETE SET NULL
ALTER TABLE tests DROP CONSTRAINT IF EXISTS tests_created_by_fkey;
ALTER TABLE tests ADD CONSTRAINT tests_created_by_fkey
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

-- 4. Kontrolle: Zeige alle FK-Constraints auf users-Tabelle
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    rc.delete_rule
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.referential_constraints rc
    ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND kcu.table_name IN ('test_results', 'tests')
ORDER BY tc.table_name, kcu.column_name;
