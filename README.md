# Eurolux Inventory & Stock Management

A standalone PWA to track SCHUCO aluminium stock items — profiles, doors,
windows and accessories held as ready-made stock — with a full stock-in /
allocation / return / adjustment movement log.

This app runs on the **same Supabase project** as your Project & Procurement
Management System (Euroluxprojects.html). Supabase's free tier only limits
you to 2 free *projects*, not the number of tables inside one project — so
this just adds two new tables to your existing database rather than needing
a third project.

## What's included

```
inventory-system/
├── EuroluxInventory.html         the whole app (UI + logic, single file)
├── manifest.json                  PWA manifest (installable on phone/tablet/PC)
├── service-worker.js              app-shell offline caching
├── icon-192.png / icon-512.png    app icons
├── supabase_setup_inventory.sql   run first — creates stock_items, stock_movements, views, RLS
└── seed_inventory.sql             run second — imports your Orgadata stock sheet (Jun 29)
```

## 1. Add the new tables to your existing Supabase project

1. Open the **same** Supabase project used by Euroluxprojects.html.
2. **SQL Editor** → New query → paste `supabase_setup_inventory.sql` → **Run**.
   This only adds `stock_items` and `stock_movements` (plus two views) — it
   does not touch your existing `projects`/`items`/`suppliers` tables.
3. New query again → paste `seed_inventory.sql` → **Run**. This imports all
   45 stock item rows from "Orgadata Eurolux stock list for inventory Jun
   29.xlsx", with their initial Stock In quantities and any per-project
   allocations already recorded in that sheet (matched to your real
   projects — MEADOWS 1 VILLA 3, Meadows 9 St.6 Villa 15, and RASHA Villa 85
   — by their project ref, e.g. `P-0030`).
   **Run this once** — re-running it will duplicate the movement history
   (the stock item list itself is protected against duplicates by a unique
   SKU, so that part is safe to re-run).

   A second sheet in the source file ("54 PD sliding") looked like an
   older, partial duplicate of the first 4 rows in Sheet1 (lower allocation
   numbers), so it was **not** imported — Sheet1 was treated as the current
   source of truth. Flag it if that's wrong and I'll re-check.

The credentials are already embedded in `EuroluxInventory.html` (same
Supabase URL + anon key as your PPMS app), so there's no setup screen —
it connects automatically.

## 2. Push to GitHub

Same repo as before works fine — just give this app its own folder so it
doesn't collide with `project-procurement-system/`:

```bash
mkdir -p inventory-system
# copy these files into that folder, then:
git add inventory-system
git commit -m "Add Eurolux Inventory & Stock Management app"
git push
```

## 3. Deploy on Vercel

1. [vercel.com](https://vercel.com) → **Add New Project** → import the same
   repo again (Vercel lets one GitHub repo back multiple Vercel projects).
2. Framework preset: **Other** (static files, no build command).
3. Expand **Root Directory** and select `inventory-system`.
4. Deploy. You'll get a separate URL, e.g. `euroluxprojects-inventory.vercel.app`.
5. On your phone: "Add to Home Screen" (iOS Safari) or the app's own
   **⬇ Install** button (Android Chrome / desktop Chrome).

## No login (same decision as the rest of your apps)

No sign-in screen — RLS policies allow full read/write to anyone with the
URL, matching your existing apps. To restrict this later, add Supabase Auth
plus a real sign-in gate across all three apps at once.

## How the data model works

- **Stock Items** — one row per distinct SCHUCO variant (system + size +
  configuration + opening direction + track + threshold), each with an
  auto-numbered SKU (STK-001, STK-002, …).
- **Movements** — every stock in/out event is logged: Stock In, Allocated
  to Project, Returned to Stock, Adjustment Increase, Adjustment Decrease,
  Damaged / Written Off. Current balance is never stored directly — it's
  always derived live from the sum of an item's movements, so the numbers
  can never drift out of sync with the history.
- **Project linkage** — when you log an "Allocated to Project" (or
  "Returned to Stock") movement, you can pick a real project from your PPMS
  project list (same database), so you always know exactly which villa/site
  a batch of stock went to. If it's not tied to a specific project, leave it
  blank.
- **Low stock** — optionally set a Reorder Level on any item; the dashboard
  flags it once the balance falls to or below that level. Leave it blank for
  items you don't want to track this way.

## What's in the app

- **Dashboard** — total item types, total units in stock, low-stock count,
  movements logged, stock-by-system breakdown, low-stock list, recent
  movements — all clickable through to the relevant item or list.
- **Stock Items** — searchable/filterable list (by system), CSV export,
  create/edit/delete, click a row for full details (view-only, with an Edit
  button to make changes) plus that item's complete movement history.
- **Movements** — full audit trail across every item, filterable by item,
  type and date range, CSV export, click a row for full details (view-only,
  with an Edit button) or delete a mistaken entry.

## Notes

- Quantities are in "sets" (matching the source spreadsheet), dates display
  as DD/MM/YYYY.
- No build step — you can open `EuroluxInventory.html` directly in a
  browser to poke around the UI, though it still needs the Supabase tables
  above to actually load/save data.
