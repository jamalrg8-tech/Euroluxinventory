-- ============================================================================
-- Eurolux Inventory & Stock Management System — seed data
-- Imported from "Orgadata Eurolux stock list for inventory Jun 29.xlsx"
-- Run AFTER supabase_setup_inventory.sql.
-- 
-- stock_items are protected by a unique "sku" so re-running this is safe for
-- the item list. The movement inserts below are NOT re-run-safe (re-running
-- will duplicate the initial stock-in/allocation history) — run this once.
-- 
-- A second sheet in the source file ("54 PD sliding") looked like an older,
-- partial duplicate of the first 4 rows here (lower allocation numbers) so it
-- was NOT imported — Sheet1 (dated Jun 29) is treated as the current source of
-- truth. Flag it if that assumption is wrong.
-- ============================================================================

insert into public.stock_items (sku, system, description, width_mm, height_mm, configuration, opening_direction, track, threshold) values
  ('STK-001', 'AS PD 54', '2 Panel Sliding Door with One Fixed Panel (Type 2A/1)', 3000.0, 3000.0, '1 Fixed + 1 Sliding', 'Left Opening', '2 Track', 'Invisible Threshold with Gutter'),
  ('STK-002', 'AS PD 54', '2 Panel Sliding Door with One Fixed Panel (Type 2A/1)', 3000.0, 3000.0, '1 Sliding + 1 Fixed', 'Right Opening', '2 Track', 'Standard Threshold'),
  ('STK-003', 'AS PD 54', '3 Panel Sliding Door with One Fixed Panel (Type 3E/1)', 2800.0, 2000.0, '1 Fixed + 2 Sliding', 'Left Opening', '3 Track', 'Invisible Threshold with Gutter'),
  ('STK-004', 'AS PD 54', '3 Panel Sliding Door with One Fixed Panel (Type 3E/1)', 2800.0, 2000.0, '2 Sliding + 1 Fixed', 'Right Opening', '3 Track', 'Standard Threshold'),
  ('STK-005', 'ADS 65', 'Double Leaf Hinged Door', 2000.0, 3000.0, 'Double leaf', 'Open in', null, null),
  ('STK-006', 'ADS 65', 'Double Leaf Hinged Door', 2000.0, 3000.0, 'Double leaf', 'Open out', null, null),
  ('STK-007', 'ADS 65/AWS 65', 'Fixed Window', 2500.0, 2500.0, '1 Fixed Panel', 'Fixed', null, null),
  ('STK-008', 'ADS 65/AWS 65', 'Fixed Window', 2500.0, 2500.0, '2 Fixed Panel', 'Fixed', null, null),
  ('STK-009', 'ADS 65', 'Single Leaf Hinged Door', 1000.0, 3000.0, 'Single Leaf', 'Open in', null, null),
  ('STK-010', 'ADS 65', 'Single Leaf Hinged Door', 1000.0, 3000.0, 'Single Leaf', 'Open out', null, null),
  ('STK-011', 'ADS 65', 'Single Leaf Hinged Door', 1500.0, 2588.0, 'Single Leaf + 1fix', 'Open out', null, null),
  ('STK-012', 'ADS 65', 'Single Leaf Hinged Door  (Left Hand)', 1000.0, 3000.0, 'Single Leaf', 'Open in LEFT', null, null),
  ('STK-013', 'ADS 65', 'Single Leaf Hinged Door  (Right Hand)', 1000.0, 3000.0, 'Single Leaf', 'Open in RIGHT', null, null),
  ('STK-014', 'AWS 65', 'Side Hung Window Silver Handle', 1200.0, 1800.0, null, 'Open out', null, null),
  ('STK-015', 'AWS 65', 'Side Hung Window Silver Handle', 1200.0, 1800.0, null, null, null, null),
  ('STK-016', 'AWS 65', 'Side Hung Window', 1000.0, 1950.0, null, null, null, null),
  ('STK-017', 'AWS 65', 'Tilt & Turn Window R Silver Handle', 1200.0, 2000.0, null, 'Open in R', null, null),
  ('STK-018', 'AWS 65', 'Tilt & Turn Window L Black Handle', 1200.0, 2000.0, null, 'Open in L', null, null),
  ('STK-019', 'AWS 65', 'Top Hung Window Silver', 1200.0, 2000.0, null, null, null, null),
  ('STK-020', 'AWS 65', 'Top Hung Window with Fixed window below', 890.0, 2580.0, 'with Fixed window', null, null, null),
  ('STK-021', 'ASE 70 PD.ME', 'Panoramic Sliding Door', 3000.0, 3000.0, '1 Sliding + 1 Fixed', 'Right Opening', '2 Track', null),
  ('STK-022', 'ASE 55', 'Sliding Door', 3000.0, 3000.0, '1 Sliding + 1 Fixed', 'Right Opening', '2 Track', null),
  ('STK-023', 'ASE 55', 'Sliding Door', 3000.0, 3000.0, '1 Fixed + 1 Sliding', 'Left Opening', '2 Track', null),
  ('STK-024', 'ASE 70 PD.ME', 'Panoramic Sliding Door', 3000.0, 3000.0, '1 Fixed + 1 Sliding', 'Left Opening', '2 Track', null),
  ('STK-025', 'ASE 70 PD.ME', 'Panoramic Sliding Door', 5000.0, 3000.0, '2 Sliding + 1 Fixed', 'Right Opening', '3 Track', null),
  ('STK-026', 'ASE 70 PD.ME', 'Panoramic Sliding Door', 5000.0, 3000.0, '1 Fixed + 2 Sliding', 'Left Opening', '3 Track', null),
  ('STK-027', 'ADS 65', 'Single Leaf Hinged Door (Black handle)', 1000.0, 3000.0, 'Single Leaf', 'Open out', null, null),
  ('STK-028', 'ADS 65', 'Single Leaf Hinged Door (Stainless Steel Handle)', 1000.0, 3000.0, 'Single Leaf', 'Open out', null, null),
  ('STK-029', 'ADS 65', 'Single Leaf Hinged Door (Black handle)', 1000.0, 3000.0, 'Single Leaf', 'Open in', null, null),
  ('STK-030', 'ADS 65', 'Single Leaf Hinged Door (Stainless Steel Handle)', 1000.0, 3000.0, 'Single Leaf', 'Open in', null, null),
  ('STK-031', 'AWS 65', 'Top Hung Window (Black)', 1200.0, 2000.0, null, null, null, null),
  ('STK-032', 'AWS 65', 'Top Hung Window (Stainless Steel Look)', 1200.0, 2000.0, null, null, null, null),
  ('STK-033', 'AWS 65', 'Side Hung Window (Black Handle 9005)', 1200.0, 1800.0, null, 'Open out R', null, null),
  ('STK-034', 'AWS 65', 'Side Hung Window (Stainless Steel Handle)', 1200.0, 1800.0, null, 'Open out R', null, null),
  ('STK-035', 'AWS 65', 'Side Hung Window (Black Handle)', 1200.0, 1800.0, null, 'Open out L', null, null),
  ('STK-036', 'AWS 65', 'Side Hung Window (Stainless Steel Handle)', 1200.0, 1800.0, null, 'Open out L', null, null),
  ('STK-037', 'AWS 65', 'Tilt & Turn Window (Silver Handle)', 1200.0, 2000.0, null, 'Open In L', null, null),
  ('STK-038', 'AWS 65', 'Tilt & Turn Window (Stainless Steel)', 1200.0, 2000.0, null, 'Open In L', null, null),
  ('STK-039', 'AWS 65', 'Tilt & Turn Window (Black Handle)', 1200.0, 2000.0, null, 'Open In R', null, null),
  ('STK-040', 'AWS 65', 'Tilt & Turn Window (Stainless Steel)', 1200.0, 2000.0, null, 'Open In R', null, null),
  ('STK-041', 'ASE 70 PD.ME', 'Panoramic Sliding Door', 3000.0, 3000.0, '1 Sliding + 1 Fixed', 'Right Opening', null, null),
  ('STK-042', 'ASE 70 PD.ME', 'Panoramic Sliding Door', 3000.0, 3000.0, '1 Sliding + 1 Fixed', 'Right Opening', null, null),
  ('STK-043', 'ASE 36 PD ME', 'Sliding 2panel slider', null, null, '1 Fixed + 1 Sliding', null, null, null),
  ('STK-044', 'ASE 36 PD ME', 'Sliding 2panel slider', null, null, '1 Sliding + 1 Fixed', null, null, null),
  ('STK-045', 'ASE 36 PD ME', 'Sliding 3panel slider', null, null, '1 Fixed + 1 Sliding + 1 Sliding', null, null, null)
on conflict (sku) do nothing;

-- Initial stock-in + allocation movements (run once)
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 35.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-001';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 1.0, (select id from public.projects where ref = 'P-0026' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-001';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 15.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-002';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 6.0, (select id from public.projects where ref = 'P-0026' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-002';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 4.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-003';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 1.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-004';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 2.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-005';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 2.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-006';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 90.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-007';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 3.0, (select id from public.projects where ref = 'P-0026' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-007';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-008';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-009';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-010';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-011';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-012';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-013';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-014';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-015';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 50.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-016';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-017';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-018';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-019';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-020';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 15.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-021';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 3.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-022';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 3.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-023';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 15.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-024';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 3.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-025';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 2.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-026';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-027';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-028';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 2.0, (select id from public.projects where ref = 'P-0026' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-028';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-029';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-030';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 1.0, (select id from public.projects where ref = 'P-0026' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-030';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-031';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-032';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 6.0, (select id from public.projects where ref = 'P-0026' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-032';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-033';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-034';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-035';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-036';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-037';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 5.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-038';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 10.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-039';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 5.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-040';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 1.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-041';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 1.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-042';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 20.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-043';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 9.0, (select id from public.projects where ref = 'P-0030' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-043';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 2.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-044';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Stock In', 2.0, null, '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-045';
insert into public.stock_movements (item_id, movement_type, quantity, project_id, moved_at, reference)
select id, 'Allocated to Project', 2.0, (select id from public.projects where ref = 'P-0030' limit 1), '2026-06-29', 'Initial import from Orgadata stock sheet (Jun 29)' from public.stock_items where sku = 'STK-045';
