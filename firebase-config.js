/* ---------------------------------------------------------------------------
   Eurolux Inventory — Firebase configuration
   ---------------------------------------------------------------------------
   Project : EuroluxInventory  (euroluxinventory)
   Web app : registered 23 September 2026

   These values are NOT secrets. Firebase web config is meant to be public;
   your data is protected by Firestore Security Rules (see firestore.rules)
   and by Firebase Authentication, not by hiding this file.

   NEVER put a Service Account private key in this file. That one bypasses
   every security rule and must stay off GitHub entirely.
--------------------------------------------------------------------------- */

export const firebaseConfig = {
  apiKey: "AIzaSyD1pBxTmr2PPbHA9xTU2v6nP-UhPYIyYRU",
  authDomain: "euroluxinventory.firebaseapp.com",
  projectId: "euroluxinventory",
  storageBucket: "euroluxinventory.firebasestorage.app",
  messagingSenderId: "600106244712",
  appId: "1:600106244712:web:230e5a01d5dba3faf779dd",
};

/* Can people register themselves from the sign-in screen?

   false  - accounts are created by you in the Firebase console
            (Authentication -> Users -> Add user). The "Create account" tab is
            hidden, so staff only ever see a sign-in form. This is the setting
            that matches having sign-ups switched off in Firebase.
   true   - shows the "Create account" tab, for enrolling a team quickly.
            Only works while sign-ups are also enabled in the Firebase console. */
export const allowSelfSignup = false;

/* Optional: restrict sign-up to your own company domain.
   Set to null to allow any email address.
   Uncomment the eurolux.ae line only if every member of staff who needs the
   app has a @eurolux.ae address — anyone on gmail would otherwise be locked out. */
export const allowedEmailDomain = null;
// export const allowedEmailDomain = "eurolux.ae";

/* Systems that should always be offered when you type a "System reference"
   on a BOM template or a stock profile, even before any stock carries that
   reference. The app also offers every system reference it finds in your
   stock list; this array just adds the ones you know are coming.
   Add or remove lines here and redeploy.

   CW = curtain wall. "ASE 80 Lift & Slide + CW" is a combined configuration,
   a lift & slide together with a curtain wall, so it is its own system and not
   a spelling of "ASE 80 Lift & Slide". */
export const knownSystems = [
  "ASE 55 Lift & Slide",
  "ASE 80 Lift & Slide",
  "ASE 80 Lift & Slide + CW",
  "AS FD 90 HI",
  "FWS 35 PD CW",
  "FWS 50 CW",
];

/* Default reorder threshold, used for any article that has no
   per-article min_qty of its own. Editable in-app under Settings. */
export const defaultShortageThreshold = 10;

/* Firestore collection names. Change only if you know why. */
export const collections = {
  inventory: "inventory",
  movements: "movements",
  projects: "projects",
  boms: "boms",
  users: "users",
  settings: "settings",
};
