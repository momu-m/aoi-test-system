-- ============================================
-- Fix v2.5: Neue Features (Zeitlimit, i18n, etc.)
-- Ausfuehren im Supabase SQL Editor
-- ============================================

-- 1. Zeitlimit-Spalte zur Tests-Tabelle hinzufuegen
ALTER TABLE tests ADD COLUMN IF NOT EXISTS time_limit INTEGER DEFAULT 0;

-- 2. Kontrolle: Zeige Tests mit neuer Spalte
SELECT id, title, passing_score, time_limit, is_active FROM tests ORDER BY created_at DESC;
