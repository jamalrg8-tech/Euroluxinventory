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
("1369-Esmeralda") are not the same strings.

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

### Loading the master stock list

The `import/` folder holds your 23-09 master stock list already converted.
Import them **in this order**, from Master Stock › Import CSV:

1. `import-1-stock.csv` — 729 articles across 14 systems.
2. `import-2-projects.csv` — the 12 villa projects.
3. `import-3-movements.csv` — 2,229 ledger entries (870 receipts tagged with
   their delivery note, 1,359 issues tagged with their project). This one takes
   about half a minute and asks you to confirm first.

`check-negative-balances.csv` is not imported. It lists the 122 articles that
finish below zero because the sheet records material issued to a job that was
never booked in against a delivery note. Book those deliveries and the balances
right themselves.

**Load sample data** (Settings, or the empty-state button) inserts the eight
Schüco articles and three villa projects from your prototype.

**BOM Wizard** — a template per system (ASE 36 pocket sliding door, AWS 65
window, …) listing the profiles consumed **per unit**. "Seed from a system
group" pulls in every article carrying a system reference at 1 per unit so you
correct numbers rather than typing the bundle. Pick the template, the number of
units and a villa project, and it shows required vs. on-hand vs. shortfall per
line before **Batch book package bundle** posts the lot.

**MTO Import** reads the *Material analysis* spreadsheet Logikal exports for a
job and books the whole thing off stock in one posting. It finds the Profiles,
Hardware, Accessories and Gaskets sections wherever they sit, matches every
article against your stock list, and shows you what it will deduct before
anything moves.

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

**Reports** has two.

*Stock by system* groups every article under its system, with received, issued,
balance, minimum and status per line. Click a system heading to open it.

*Below minimum* is the replenishment report: everything at or below its minimum,
worst first, with how much to order and a Receive button on each row. **Set
minimum levels** applies a minimum to a whole system at once — doing it one
article at a time is unusable across a list this size. Tick "only articles that
have no minimum set yet" to fill the gaps without overwriting minimums you have
already tuned.

Both reports export to CSV.

**Villa Project Summaries** aggregates every issue booked to a job into one row
per article. Every movement is loaded for these totals to be complete; the
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
| `inventory` | `system_ref`, `article_ref`, `description`, `unit`, `location`, `min_qty`, `received_qty`, `issued_qty`, `balance_stock_qty` |
| `movements` | `item_id`, `article_ref`, `description`, `system_ref`, `type`, `qty`, `project_id`, `project_code`, `note`, `at`, `by`, `by_name` |
| `projects` | `project_code`, `client`, `status`, `notes` |
| `boms` | `name`, `system_ref`, `lines[{article_ref, description, qty_per}]` |
| `settings/app` | `shortageThreshold` |
| `users/{uid}` | `email`, `name`, `lastSeen` |

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
| Offline work disappeared | Site data was cleared, or the app was used in a private window. Install the PWA properly and avoid clearing site data. |
