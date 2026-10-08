# Eurolux Inventory & Stock Control

An installable PWA for aluminium profile inventory, BOM allocation and stock
control. **Data is stored on each device and syncs by itself** — the app works
with no connection at all, and every device catches up automatically whenever
there is a network.

Storage and sync are handled by **Firebase Cloud Firestore**.

---

## How the local-first part works

This is the bit worth understanding, because it shapes everything else.

Firestore keeps a **complete copy of your data in the browser's own database**
on every device. That means:

- The app opens and works with **no internet at all**. Reads come from the
  device; nothing waits on a network.
- Receipts and issues posted offline are **saved on that device immediately**
  and sent by themselves the moment a connection returns — minutes or days
  later, it does not matter.
- When devices *are* online, changes appear on every other device within about
  a second, with no refresh.

The sidebar always tells you where you stand:

| Badge | Meaning |
|---|---|
| **SYNCED** | Everything on this device has reached the server. |
| **SYNCING n…** | n changes are on their way up right now. |
| **n WAITING TO SYNC** | Offline. n changes are safely stored here, waiting. |
| **OFFLINE — SAVED HERE** | Offline, nothing outstanding. |

A banner across the top says the same thing in words while anything is waiting,
and closing the browser with unsent work prompts a warning. Your work is not
lost if you close the app — Firestore keeps it on the device — but clearing the
browser's site data or uninstalling the app before it syncs *would* lose it.

### The one thing to know

Two people working **offline at the same time** cannot see each other. If Rafiq
issues the last 20 bars of 391440 on the workshop tablet while someone else
issues the same 20 from their phone, both succeed locally, and when they
reconnect the balance goes to −20. Nothing is lost or silently wrong — the
ledger shows both movements and the article flags as negative — but you find out
at sync rather than at the moment.

While online this cannot happen: quantities are changed with atomic increments,
so simultaneous postings both count and everyone sees the result immediately.

---

## What's in this repository

| File | Purpose |
|---|---|
| `Euroluxinventory.html` | The whole application — markup, styles and logic. |
| `firebase-config.js` | **Edit this.** Your Firebase project keys. |
| `firestore.rules` | Security rules to paste into the Firebase console. |
| `index.html` | Redirect so the repository root opens the app. |
| `manifest.json` | PWA manifest (name, icons, standalone display). |
| `sw.js` | Service worker — offline app shell, versioned cache. |
| `icons/` | App icons (192, 512, maskable). |
| `import/` | Your master stock list, converted to CSV ready to import. |
| `README.md` | This file. |

---

## Setup — about 10 minutes

### 1. Create the Firebase project

1. Go to <https://console.firebase.google.com> → **Add project**. Name it e.g.
   `eurolux-inventory`. Google Analytics is not needed.
2. Click the **`</>` (Web)** icon to register a web app. Call it `Eurolux PWA`.
   Do not tick "Firebase Hosting" unless you want to host there instead of
   GitHub Pages.
3. Firebase shows you a `firebaseConfig` object. Copy it.

### 2. Paste your keys

Open `firebase-config.js` and replace the placeholders:

```js
export const firebaseConfig = {
  apiKey: "AIza…",
  authDomain: "eurolux-inventory.firebaseapp.com",
  projectId: "eurolux-inventory",
  storageBucket: "eurolux-inventory.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:abcdef…",
};
```

> These values are **not secrets**. Firebase web config is public by design —
> your data is protected by the security rules in step 4, not by hiding the keys.

Optionally lock sign-up to your own domain:

```js
export const allowedEmailDomain = "eurolux.ae";
```

### 3. Turn on Authentication

**Build → Authentication → Get started → Sign-in method** → enable
**Email/Password** → Save.

### 4. Create Firestore and publish the rules

1. **Build → Firestore Database → Create database.**
2. Choose a location close to you — for the UAE, `asia-south1` (Mumbai) or
   `europe-west1` both perform well. **The location cannot be changed later.**
3. Start in **production mode**.
4. Open the **Rules** tab, paste the whole of `firestore.rules`, and **Publish**.

The collections create themselves on first write.

### 5. Deploy to GitHub Pages

1. Push every file in this folder to your repository, keeping the folder
   structure (`icons/` must stay a subfolder).
2. Repository → **Settings → Pages** → Source: **Deploy from a branch** →
   Branch `main`, folder `/ (root)` → Save.
3. After a minute the app is live at
   `https://<your-username>.github.io/<repo-name>/`

### 6. Authorise the domain in Firebase

**Authentication → Settings → Authorised domains → Add domain** → enter
`<your-username>.github.io`. Sign-in fails with `auth/unauthorized-domain`
until you do this.

### 7. Enrol your team

Each person opens the URL, chooses **Create account**, and signs in. Once
everyone is enrolled you can stop new sign-ups: **Authentication → Settings →
User actions →** untick **Enable create (sign-up)**.

---

## Installing it as an app

- **Android / Chrome:** open the URL → menu **⋮** → *Install app*.
- **iPhone / iPad:** open in **Safari** (not Chrome) → Share → *Add to Home Screen*.
- **Desktop Chrome or Edge:** install icon in the address bar.

Install it properly rather than using a browser tab — an installed PWA is much
less likely to have its storage cleared, which matters for offline work.

The **first** launch on a device needs a connection, to download the app and
sign in. Everything after that works offline.

---

## Using it

### Packing units

Stock is counted in **base units**: pieces, metres, bars. A pack is how the
material arrives — a packet of 100 screws, a 200 m box of gasket — so each
article carries a **PU Qty** (how many base units are in one pack) and a pack
name (PKT, BOX, ROLL...). PU Qty of 1 means the article is not packed.

PU Qty does two things and nothing else:

- **Receiving.** A packed article opens the Receive dialog in packs. Enter 3
  and it posts 3 x 100 = 300 pieces, showing the arithmetic first. Switch to
  the other tab to type base units instead.
- **Reading a balance back.** A balance of 2,905 shows "29 PKT of 100 + 5"
  underneath, so a storekeeper can tie it to what is on the shelf.

Issuing and the MTO import always work in base units, because that is what
production consumes: 20 m off a 200 m box, or 16 screws out of a packet of 100.

### Bar lengths

Profiles are counted in bars, and a bar is not always the same length. Each
article supplied in bars carries `bar_length` in millimetres — 6000 for a 6 m
bar, 4000 for a 4 m one — and the app turns a bar count into running metres
with it: 63 bars of 6 m reads as 378 m under the balance. The field accepts 6,
600 or 6000 and normalises all three, because the workbook writes it all three
ways.

### Millimetres, bars and packs

A profile is bought by the pack, stocked by the bar and consumed by the
millimetre, and all three have to line up. An article carries `pu_qty` (bars to
a pack), `bar_length` (mm per bar) and a base unit of `BAR`, which reads back as
`1 PKT = 8 bars of 5,000 mm = 40,000 mm`.

The movement dialog therefore offers three ways in, and picks the one that fits
what you are doing: **packs** to receive (a delivery arrives as packets),
**mm** to issue (the cutting list is in millimetres), and the base unit at any
time. Millimetres convert with `barsForMm`, which rounds **up** — you cannot
take 1.17 of a bar off the rack — and the dialog states the offcut, which
matches Logikal's own wastage figure:

```
5,832 mm ÷ 5,000 mm = 2 bar(s), leaving 4,168 mm offcut
```

A movement entered that way stores `length_mm` beside `qty`, so the ledger shows
why two bars went out for 5,832 mm.

The same distinction governs the BOM import. For a profile, `parseMto` normally
takes the bar count straight off the Quantity column, which is what the cutting
optimiser settled on. When the profile is sold by the pack (`PU` > 1) that
column counts **packets** instead, so the bars consumed are derived from
`Required ÷ Bar`, rounded up, and the preview says so.

### On order, and part deliveries

Each article carries `on_order`: what has been ordered from the supplier and is
still to come. It is an outstanding quantity rather than a list of purchase
orders, because deliveries land short and the remainder simply stays
outstanding.

- **Receive › Order** puts a quantity on the order book. Nothing moves; a
  ledger entry of type `order` records who placed it and against which PO.
- **Any receipt pays it down** by what actually arrived, never past zero. Order
  4 bars, receive 2, and 2 stay outstanding. Importing a delivery note does the
  same to every line on it.
- **Reports › On order** lists everything outstanding, worst first, with what
  the line will hold once it lands. **Export CSV** gives it as a spreadsheet.

### Building a BOM template from a spreadsheet

**New BOM template › Choose spreadsheet** reads an .xlsx and fills the line
editor from it. Two shapes are accepted, and the dialog names the one it found:

- A **plain BOM sheet** — `parseBomSheet` locates the header row by its labels
  rather than its position, so any number of title or note rows may sit above
  it. It requires an article column (`Article ref.`, `Article Number`, `Code`…)
  **and** a quantity column (`Qty per unit`, `Quantity`, `Required`…); an
  article column alone is a stock list, not a bill of materials, and is
  refused rather than guessed at. `Description` and `System ref.` are used if
  present.
- A **Logikal material analysis** — read by the existing `parseMto`, which is
  tried **first**. Its headers would also satisfy the plain reader, but it
  needs the section-aware rule (bars off `Quantity` for profiles, pieces and
  metres off `Required` for everything else); the plain reader would take
  `Quantity` throughout and turn 136 screws into 2 packets.

`bomImportUnits` divides every quantity, because a material analysis covers a
whole job and only the person knows how many units that was. It is held as its
own state field rather than inside `bomImport` so `x-model` always has a
writable target while the preview is being torn down. Nothing reaches the line
editor until **Use these lines** is pressed.

On the way in, repeated articles are summed (and the fold count reported), the
system is inferred from a column, then from the articles' own `system_ref`,
then from the file name, and articles missing from the stock list are flagged
but still imported.

### Moving stock between systems

**Move**, on any stock row, shifts a quantity to another system or another
holding — the same article, a different line. It is neither consumption nor a
delivery, so it comes off one line's receipts and goes on to the other's, and
the yard's overall received, issued and balance totals are unchanged.

The ledger gets a matched pair of `transfer` entries sharing a `transfer_id`,
one marked `direction: "out"` and one `"in"`, each naming the other side. Like
every ledger entry they cannot be edited or deleted; move the difference back
to correct a mistake.

If the article has never been held against the destination system, the line is
created, carrying the unit, pack size and bar length across.

### Importing a delivery note

**Delivery Note** reads the supplier's PDF — a Schuco "Store issue voucher" —
and books the whole delivery in at once. Each line states the article, the
quantity and, where the material is packed, the pack size:

```
13.00   218779   Connector nail 5x9
                 1 PKT = 100 PCE      1 PKT
```

so one packet books in 100 pieces. Articles that appear on two lines of the
same note are added together. Anything not in your stock list is created, and
the pack sizes on the note are saved to each article unless you untick that
box, so PU Qty fills itself in as deliveries arrive.

It must be the original PDF. A scan or a photo of a printed note has no text in
it to read; use Receive on each article for those.

### Two holdings

Stock lives in two kinds of place, exactly as your master workbook keeps it:

- **Main stock** — the warehouse. Free to use on any job.
- **Allocated to a villa** — material bought against one named job. It is *not*
  available to another job.

The same article can sit in both at once, so a stock record is keyed by article
**and** holding. The selector at the top of Master Stock and Reports chooses
which you are looking at; it opens on main stock. "Held for" appears as a column
when you switch to **All holdings**, and on every ledger row as **From**.

Booking and the MTO import both ask which holding to draw from, rather than
guessing, because holding names ("Villa 80 - ST3, Esmeralda") and job codes
("1369-Esmeralda") are not the same strings. The BOM Wizard always draws from
main stock.

### Returning villa leftovers to main stock

Material bought for a villa is often not all used. Whatever is left on a villa
line — received minus issued, above zero — stays reserved for that villa until
you return it. **Villa Leftovers**, in the sidebar, lists it all and moves it
back.

**The report**

- One card per villa, with every article that still has a balance: system,
  article, description, unit, received, issued, **Left over**, and what main
  stock holds for the same article and system now (**new line** if it holds
  none).
- Each card shows the villa's job status from **Villa Projects** — *active*,
  *on hold* or *complete* — or *no matching job* if no job matches.
  The job is found by name: the job number is dropped and the rest is looked
  for inside the villa's holding name, ignoring capitals, spaces and
  punctuation — so "Villa 24, Street 4, Savannah A" matches "1393 - SAVANNAH"
  and "Marsa Al Arab" matches "1392 - MARSA AL ARAB". Job names shorter than
  four letters ("C35") only match exactly, and the longest match wins.
- Pick one villa or **All villas**, tick **Completed villas only** to see just
  the finished jobs, and use the search box at the top to find an article.
- **Export CSV** downloads the report as shown.
- Villa lines that are negative (issued more than received) have nothing to
  return and are not listed; a note at the bottom counts them. Find them under
  **Reports › Negative**.

**Moving leftovers back**

1. When the villa is finished, mark its job **complete** in Villa Projects.
2. In Villa Leftovers, tick the lines to return, or the box beside the villa's
   name to tick all of them.
3. Press **Move *n* selected to main stock**, or **Move all to main stock** on
   the villa's card.
4. Confirm. If any villa in the selection is not marked complete, the question
   warns you — only continue if you are sure that material will not be needed.

Each line's whole leftover goes to main stock under **the same article and
system**. If main stock has never held that article under that system, the line
is created, carrying the unit, pack size and bar length across.

It is booked exactly like **Move**: a `transfer`, not a delivery or an issue.
The quantity comes off the villa line's received total and goes on to the main
stock line's, so the yard's overall received, issued and balance totals do not
change. The ledger gets a matched pair of entries — *"Villa leftover returned to
main stock"* on the villa side and *"Villa leftover returned from Villa …"* on
the main-stock side. To undo a return, use **Move** on the main-stock line to
send the quantity back to the villa.

To return only part of a leftover, use **Move** on that villa line in Master
Stock instead.

---

**Master Stock Control** — the article register. Each profile has a received
total, an issued total, and a balance that is always `received − issued`. You
never type the balance; it follows from the movements, which is what makes the
numbers auditable.

- **Receive** books stock in (a delivery).
- **Issue** books stock out to a cutter or a villa project.
- **Adjust** corrects the received total after a recount or damage write-back.

Every one of those writes a row to the **Movement Ledger**, stamped with the
user and time. Ledger rows cannot be edited or deleted — the rules forbid it for
everyone. Corrections are made by posting an opposing movement, which is the
only defensible behaviour for stock control.

**Import CSV** loads three different kinds of file. It works out which from the
header row, so there is one button, not three. Spacing and camelCase are
tolerated everywhere.

*Stock list* — the article register. Matching is on `article_ref`: existing
codes are updated, new ones created, duplicates within one file skipped.

```
article_ref,description,system_ref,unit,location,min_qty,received_qty,issued_qty
391440,INNER PROFILE 69 (319760) ( I ),ADS / AWS 65,BAR,Rack A3,20,273,17
```

*Projects* — recognised by having `project_code` and no `article_ref`.

```
project_code,client,status,notes
1361 - C35,,active,
```

*Movements* — recognised by having `type` and `qty`. Every row becomes a
permanent ledger entry **and** moves that article's running totals, so the
balances stay derived from real movements rather than typed in. Projects named
in the file are created if they do not exist. Articles that are not already in
the stock list are skipped and reported, so import the stock list first.

```
type,article_ref,qty,project_code,note,import_tag
receive,391440,273,,DN PSL076805,master-stock-list-23-09
issue,391440,22,1361 - C35,Allocated to 1361 - C35,master-stock-list-23-09
```

The optional `import_tag` makes a movements file self-identifying. The app
records the tags it has posted, so pasting the same file a second time warns you
before it doubles every quantity in it.

### Starting from a clean database

Settings has a **Start over** panel that deletes every article, job and BOM
template. Use it before importing a stock list if the database already has
something in it (the 8 demo articles, or an earlier import) — otherwise the
movements import adds its quantities on top of what is already there and every
balance doubles.

The movement ledger is deliberately left alone: no one can delete a movement
from inside the app, which is what makes the ledger worth trusting. If you need
to clear the ledger too, delete the `movements` collection from the Firebase
console, which runs with admin rights and is not bound by the rules.

### Loading the master stock list

The `import/` folder holds your master stock list already converted
(`master_stock_list_1.xlsx`, 5 October 2026). Import them **in this order**,
from Master Stock › Import CSV:

1. `import-1-stock.csv` — 1,270 stock records: 485 in main stock and 785
   allocated to villas, covering 729 distinct articles. Carries pack sizes,
   bar lengths and what is still on order.
2. `import-2-projects.csv` — the 13 villa projects.
3. `import-3-movements.csv` — 2,441 ledger entries, each tagged with its
   delivery note or its project, and with the system and holding it belongs to.
   This one takes about half a minute and asks you to confirm first.

A stock line is identified by **article + system + holding**, which is how the
master workbook keeps it. The same code stocked against two systems is two
lines with two balances, and the movements file carries a `system_ref` column
so every entry lands on the right one.

Two files are not imported:

- `import-4-conflicts.csv` — 359 concerns found while reading the workbook,
  each with the sheet rows it came from, what the sheet says and what the
  import did. The accompanying **Import Report** explains them.
- `check-negative-balances.csv` — the 182 lines that finish below zero. 170 of
  them are explained by material issued against an order whose delivery was
  never booked in; the `still_on_order` column shows how much. Book those
  deliveries and the balances right themselves.

### A note on your sheet's Balance column

`Balance Stock Qty.` in the workbook is `Total Order Qty. − Total Issue Qty.`,
not received minus issued, so it counts ordered material as though it were on
the rack. The app counts what has been booked in. The two reconcile exactly, on
every one of the 1,270 lines:

```
sheet balance  =  app balance  +  on order
```

**Load sample data** (Settings, or the empty-state button) inserts the eight
Schüco articles and three villa projects from your prototype.

**BOM Wizard** — a template per system (ASE 36 pocket sliding door, AWS 65
window, …) listing the profiles consumed **per unit**. "Seed from a system
group" pulls in every article carrying a system reference at 1 per unit so you
correct numbers rather than typing the bundle. Pick the template, the number of
units and a villa project, and it shows required vs. on-hand vs. shortfall per
line before **Batch book package bundle** posts the lot.

Where the bundle is drawn from:

1. **Main stock only.** The wizard looks at the *Stock* holding and nothing
   else. Material held for another villa is never touched, because it is
   reserved for that job.
2. **The template's own system first.** For each article it uses main stock
   filed under the template's system (for example *ADS / AWS 65*). This is the
   **On hand (this system)** column.
3. **Then main stock under another system.** If that is not enough, it uses
   the same article from main stock filed under a different system. Those lines
   are marked **other system**, the **Other systems** column shows how much is
   taken, and a blue notice above the table lists them.
4. **Then the shortfall.** Anything still not covered is shown in **Short by**.
   Booking anyway posts the shortfall against the template-system line in main
   stock, which goes negative until the material is bought and received.

When you press **Batch book package bundle** and any line uses another system's
stock, you are asked first — *"⚠ Different system … Issue them from that
stock?"* — with each article, the quantity and the system it would come from.
**Cancel** stops the booking and posts nothing; **OK** goes on to the usual
summary. In the Movement Ledger, an issue taken from another system's stock
says so in its note, e.g. *"BOM: AWS 65 Window × 10 (from ASE 55 Lift & Slide
stock, BOM system ADS / AWS 65)"*.

| Status | Meaning |
|---|---|
| available | Covered by main stock under the template's system. |
| other system | Covered, but partly or wholly from main stock under another system — you will be asked to confirm. |
| short | Main stock, all systems included, cannot cover it. |
| only held for other jobs | The article exists only in villa holdings, so it is skipped. Move stock into main stock first. |
| not in stock list | The article is not in the stock list at all, so it is skipped. |

**Villa Leftovers** — material still held for a villa after its issues, ready
to go back to main stock once the job is finished. See
[Returning villa leftovers to main stock](#returning-villa-leftovers-to-main-stock).

**MTO Import** reads the *Material analysis* spreadsheet Logikal exports for a
job and books the whole thing off stock in one posting. It finds the Profiles,
Hardware, Accessories and Gaskets sections wherever they sit, matches every
article against your stock list, and shows you what it will deduct before
anything moves.

An MTO has to be booked to a job that already exists, so if the file names a job
you do not have, the app asks you to create it before anything can be deducted,
and selects it for you once saved.

Two quantities sit on every MTO line, and they are in different units:

| MTO column | What it means | Used for |
|---|---|---|
| Quantity | purchase units — whole bars for profiles, packs for the rest | **profiles** |
| Required | net consumption — metres, pieces or pairs | **everything else** |

Profiles are stocked as bars, so a profile line deducts the bar count the
optimiser worked out. Hardware, accessories and gaskets are counted in pieces,
metres and pairs, so those lines deduct the Required figure. Every line stays
editable, and setting one to zero leaves it out. Articles the MTO names that you
have never stocked are created at zero and go negative, so the job's real
consumption is still recorded. Each file is tagged, so loading the same MTO
twice warns you before it doubles anything.

The **cutting list** and **assembly list** PDFs are per-cut and per-position
detail of the same job — useful on the saw and the bench, but the material
analysis is the one that carries project totals, so that is what the app reads.

**Position by system** on the dashboard is clickable: a row opens Master Stock
filtered to that system.

**Reorder level** — Settings holds one default threshold shared by all users,
and any article can override it with its own `min_qty`. That override matters: a
roller-set line at 1,760 pieces and a corner cleat at 18 cannot share a trigger
point.

**Book stock to a job** (Villa Projects, or the dashboard) is the everyday
posting screen: choose the job — or type a new one, which is created as part of
the same posting — choose the system the material is for, then type quantities
against that system's articles with the balance and the minimum shown beside
each. Everything goes in one batch, so the ledger and the balances move
together. If a line would take an article below zero the app says so before you
post, and still lets you post it, because the ledger records what really
happened.

The search box in the top bar searches whichever page you are on — the stock
list, the ledger, a report, or jobs and their booked items. From a page that
cannot show results it takes you to the stock list rather than doing nothing.

**Reports** has three.

*Stock by system* groups every article under its system, with received, issued,
balance, minimum and status per line. Click a system heading to open it.

*Negative* lists articles issued beyond what was ever received — nearly always
a delivery note that was never booked in.

*Below minimum* is the replenishment report: everything at or below its minimum,
worst first, with how much to order and a Receive button on each row. **Set
minimum levels** applies a minimum to a whole system at once — doing it one
article at a time is unusable across a list this size. Tick "only articles that
have no minimum set yet" to fill the gaps without overwriting minimums you have
already tuned.

**Printing.** Set a page up on screen — holding, report, groups open, search
applied — then press Ctrl+P (Cmd+P on a Mac). The app has a print stylesheet:
the menu, buttons and action columns drop out, the dark theme becomes plain
black on white, table headings repeat on every page, and a heading is added
showing the page, the holding, the date and who printed it.

All three export to CSV, and the four tiles at the top are clickable: Systems
expands or collapses every group, On Hand opens the stock list, and Below
Minimum and Negative switch to those reports.

**Villa Project Summaries** lists every job collapsed, with its total and article
count; the **+** beside a job opens its booked items. Create a job from the
**New job** button in the top bar, on the dashboard, or on this page, and book
material to it whenever you are ready. Every movement is loaded for these totals to be complete; the
ledger table itself draws 300 rows at a time so a long history does not slow the
page down.

**System names.** The master stock list spelled three systems differently from
the way you name them, so the import CSV was normalised: `ASE 55` is imported as
`ASE 55 Lift & Slide`, and `AS FD 90 HI BI-FOLDING` as `AS FD 90 HI`. CW stands
for curtain wall, and `ASE 80 L & S + CW` is imported as
`ASE 80 Lift & Slide + CW` — a combined lift & slide plus curtain wall, kept as
a system of its own rather than folded into `ASE 80 Lift & Slide`.

**System references** are picked from a dropdown on both the BOM template form
and the stock profile form, with "+ Add a new system..." at the bottom for one
that is not on the list yet. The dropdown shows every system that carries
stock, plus the list in `knownSystems` in `firebase-config.js`. That is how a
BOM template can name a system before any stock carries it — edit the array and
redeploy to add more. The "Seed from a system group" picker and the stock filter
deliberately show only systems that have stock, since seeding from an empty one
would produce nothing.

---

## Data model

| Collection | Fields |
|---|---|
| `inventory` | `system_ref`, `article_ref`, `holding`, `description`, `unit`, `pu_qty`, `pack_unit`, `bar_length`, `on_order`, `location`, `min_qty`, `received_qty`, `issued_qty`, `balance_stock_qty` |
| `movements` | `item_id`, `article_ref`, `description`, `system_ref`, `holding`, `type`, `qty`, `project_id`, `project_code`, `note`, `at`, `by`, `by_name`, and for a transfer `transfer_id` + `direction` |
| `projects` | `project_code`, `client`, `status`, `notes` |
| `boms` | `name`, `system_ref`, `lines[{article_ref, description, qty_per}]` |
| `settings/app` | `shortageThreshold` |
| `users/{uid}` | `email`, `name`, `lastSeen` |

A document is identified by `article_ref` + `system_ref` + `holding`; nothing
enforces that in Firestore, so the import, the article form and the transfer
all check it in the app. `type` is one of `receive`, `issue`, `adjust`, `order`
or `transfer`; an `order` entry moves no stock and only touches `on_order`.

`balance_stock_qty` is maintained atomically alongside `received_qty` and
`issued_qty` so it can be read straight out of Firestore by another tool. The
app never trusts it: every figure on screen is recomputed as
`received − issued`, so a value that drifted through a manual console edit shows
up as a discrepancy rather than quietly becoming the truth.

---

## Updating the app

After you push changes, bump `CACHE_VERSION` in `sw.js`
(e.g. `eurolux-v3.0.0` → `eurolux-v3.0.1`). Without that, installed clients keep
serving the old cached shell.

---

## Cost

For a handful of users and thousands of documents, Firestore's free Spark tier
(50,000 reads and 20,000 writes per day) is very unlikely to be exceeded. No card
is required to start, and projects are never paused for inactivity.

---

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| "Firebase is not configured yet" | `firebase-config.js` still has `PASTE_…` placeholders. |
| `auth/unauthorized-domain` | Add `<user>.github.io` under Authentication → Settings → Authorised domains. |
| `auth/operation-not-allowed` | Email/Password sign-in is not enabled in the console. |
| "No permission to read inventory" | The rules from `firestore.rules` were not published. |
| Badge stuck on "n WAITING TO SYNC" while online | The device thinks it is online but cannot reach Firestore — check a firewall or captive portal. The data is safe meanwhile. |
| Changes don't appear after a deploy | Bump `CACHE_VERSION` in `sw.js`, then hard-reload. |
| Stuck on "Starting…" | `cdn.jsdelivr.net` or `gstatic.com` is blocked by the network. |
| Install prompt missing | PWA install requires HTTPS — GitHub Pages provides it; `file://` does not. |
| BOM Wizard says "short" but Master Stock shows plenty | Master Stock is filtered to one system. Switch it to **ALL SYSTEMS**: the stock may be under another system (the wizard will use it after asking you) or held for a villa (return it with **Villa Leftovers** or **Move**). |
| A villa line in BOM bookings went negative before this version | Older versions issued from the first line with a matching article, which could be a villa line. Fix it with **Move** from main stock, and cancel any matching **On order** quantity. |
| Villa Leftovers shows "no matching job" | The villa's holding name does not contain the job's name (after its number). Rename the job to include the villa's name, or leave it — the report and moves still work. |
| Offline work disappeared | Site data was cleared, or the app was used in a private window. Install the PWA properly and avoid clearing site data. |
