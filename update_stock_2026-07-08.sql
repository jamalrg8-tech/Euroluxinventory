-- ============================================================================
-- Eurolux Inventory & Stock Management System
-- Stock sync — updated Orgadata sheet (uploaded 8 Jul 2026)
-- ============================================================================
-- Run this once in Supabase: Dashboard > SQL Editor > New query > paste > Run.
--
-- I compared the newly uploaded "Orgadata Eurolux stock list for inventory
-- Jun 29.xlsx" against the version already imported. All 45 stock item types
-- are unchanged (same systems/sizes/configurations, same original Qty (Set)
-- totals) — only 3 items have different allocation numbers than before.
-- Rather than re-importing from scratch (which would duplicate your existing
-- movement history), this adds just the DELTA as new movements, so the
-- balances end up matching the new sheet exactly:
--
--   STK-001 (AS PD 54, 2 Panel Sliding Door, Left Opening):
--     Meadows 9 allocation went from 1 -> 7 sets. +6 newly allocated.
--
--   STK-002 (AS PD 54, 2 Panel Sliding Door, Right Opening):
--     Meadows 9 allocation went from 6 -> 5 sets. -1, recorded as returned.
--     Rasha 85 allocation went from 0 -> 4 sets. +4 newly allocated.
--
--   STK-033 (AWS 65, Side Hung Window, Black Handle 9005):
--     Rasha 85 allocation went from 0 -> 6 sets. +6 newly allocated.
--
-- This is NOT re-run-safe — running it twice will double the deltas. Run it
-- once, then the balances in the app will match the new sheet.
-- ============================================================================

-- STK-001: +6 allocated to Meadows 9, Villa 15 (P-0026)
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 6, (select id from public.projects where ref = 'P-0026' limit 1), '2026-07-08', 'Sync from revised Orgadata stock sheet (uploaded 8 Jul 2026)'
from public.stock_items where sku = 'STK-001';

-- STK-002: -1 Meadows 9 allocation (returned to stock)
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Returned to Stock', 1, (select id from public.projects where ref = 'P-0026' limit 1), '2026-07-08', 'Sync from revised Orgadata stock sheet (uploaded 8 Jul 2026)'
from public.stock_items where sku = 'STK-002';

-- STK-002: +4 allocated to Rasha Villa 85 (P-0029)
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 4, (select id from public.projects where ref = 'P-0029' limit 1), '2026-07-08', 'Sync from revised Orgadata stock sheet (uploaded 8 Jul 2026)'
from public.stock_items where sku = 'STK-002';

-- STK-033: +6 allocated to Rasha Villa 85 (P-0029)
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 6, (select id from public.projects where ref = 'P-0029' limit 1), '2026-07-08', 'Sync from revised Orgadata stock sheet (uploaded 8 Jul 2026)'
from public.stock_items where sku = 'STK-033';
