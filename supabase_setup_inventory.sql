-- ============================================================================
-- Eurolux Inventory & Stock Management System
-- Supabase (Postgres) schema — adds to your EXISTING Supabase project
-- ============================================================================
-- This does NOT create a new Supabase project. It adds two new tables to the
-- SAME database already used by your Project & Procurement Management System
-- (Euroluxprojects.html) — free-tier Supabase only limits the number of
-- projects, not the number of tables inside one project.
--
-- Run this once in Supabase: Dashboard > SQL Editor > New query > paste > Run.
-- Safe to re-run (uses IF NOT EXISTS).
--
-- Requires: public.projects must already exist (it does, from
-- supabase_setup.sql for the Project & Procurement app) — stock allocations
-- can optionally link to a real project there.
-- ============================================================================

create extension if not exists pgcrypto;

-- ----------------------------------------------------------------------------
-- Stock items — one row per distinct SCHUCO profile/finished-unit variant
-- ----------------------------------------------------------------------------

create table if not exists public.stock_items (
  id uuid primary key default gen_random_uuid(),
  sku text unique,                         -- internal stock code, e.g. STK-001
  system text not null,                    -- SCHUCO system code, e.g. "AS PD 54"
  description text not null,               -- e.g. "2 Panel Sliding Door with One Fixed Panel"
  width_mm numeric(10,1),
  height_mm numeric(10,1),
  configuration text,                      -- e.g. "1 Fixed + 1 Sliding"
  opening_direction text,                  -- e.g. "Left Opening"
  track text,                              -- e.g. "2 Track"
  threshold text,                          -- e.g. "Invisible Threshold with Gutter"
  reorder_level numeric(12,2),             -- optional low-stock threshold (blank = no alert)
  is_active boolean not null default true,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_stock_items_system on public.stock_items(system);

-- ----------------------------------------------------------------------------
-- Stock movements — full audit trail; current balance is derived from this
-- ----------------------------------------------------------------------------

create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.stock_items(id) on delete cascade,
  movement_type text not null
    check (movement_type in ('Stock In','Allocated to Project','Returned to Stock','Adjustment Increase','Adjustment Decrease','Damaged / Written Off')),
  quantity numeric(12,2) not null check (quantity > 0),   -- always positive; direction comes from movement_type
  project_id uuid references public.projects(id) on delete set null,  -- optional link to a real PPMS project
  project_name_freeform text,              -- fallback label when not linked to a real project
  reference text,                          -- PO / work order / reason
  moved_by text,
  moved_at date not null default current_date,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists idx_stock_movements_item on public.stock_movements(item_id);
create index if not exists idx_stock_movements_project on public.stock_movements(project_id);
create index if not exists idx_stock_movements_type on public.stock_movements(movement_type);
create index if not exists idx_stock_movements_moved_at on public.stock_movements(moved_at);

-- ----------------------------------------------------------------------------
-- updated_at trigger (reuses the function already created by the PPMS schema;
-- created here too in case this script is ever run standalone)
-- ----------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_stock_items_updated_at on public.stock_items;
create trigger trg_stock_items_updated_at before update on public.stock_items
  for each row execute function public.set_updated_at();

-- ----------------------------------------------------------------------------
-- Row Level Security — same "no login" policy as the rest of the app
-- ----------------------------------------------------------------------------

alter table public.stock_items enable row level security;
alter table public.stock_movements enable row level security;

do $$
declare
  t text;
begin
  for t in select unnest(array['stock_items','stock_movements'])
  loop
    execute format('drop policy if exists "allow_all_%1$s" on public.%1$s;', t);
    execute format('create policy "allow_all_%1$s" on public.%1$s for all using (true) with check (true);', t);
  end loop;
end $$;

-- ----------------------------------------------------------------------------
-- Convenience view: stock items with live balance + linked project names
-- ----------------------------------------------------------------------------

create or replace view public.v_stock_balance as
select
  i.*,
  coalesce(sum(
    case
      when m.movement_type in ('Stock In','Returned to Stock','Adjustment Increase') then m.quantity
      when m.movement_type in ('Allocated to Project','Adjustment Decrease','Damaged / Written Off') then -m.quantity
      else 0
    end
  ), 0) as balance
from public.stock_items i
left join public.stock_movements m on m.item_id = i.id
group by i.id;

create or replace view public.v_stock_movements as
select
  m.*,
  i.sku,
  i.system,
  i.description as item_description,
  p.site_name as project_site_name,
  p.ref as project_ref
from public.stock_movements m
join public.stock_items i on i.id = m.item_id
left join public.projects p on p.id = m.project_id;
