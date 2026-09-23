/* ---------------------------------------------------------------------------
   Eurolux Inventory — Service Worker
   ---------------------------------------------------------------------------
   Strategy
     App shell (HTML/CSS/JS/icons)  : stale-while-revalidate, precached on install
     Firebase SDK from gstatic      : stale-while-revalidate (so the app boots offline)
     Firestore / Auth API traffic   : NEVER cached — Firestore keeps its own
                                      IndexedDB copy of your data and manages
                                      the sync itself; caching its API calls
                                      would corrupt that.

   Bump CACHE_VERSION on every deploy so clients pick up new code.
--------------------------------------------------------------------------- */

const CACHE_VERSION = "eurolux-v3.3.0";
const SHELL_CACHE = `${CACHE_VERSION}-shell`;
const VENDOR_CACHE = `${CACHE_VERSION}-vendor`;

const SHELL_ASSETS = [
  "./",
  "./index.html",
  "./Euroluxinventory.html",
  "./firebase-config.js",
  "./manifest.json",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/icon-maskable-512.png",
];

/* Hosts whose responses must always go straight to the network. */
const NETWORK_ONLY_HOSTS = [
  "firestore.googleapis.com",
  "identitytoolkit.googleapis.com",
  "securetoken.googleapis.com",
  "firebaseinstallations.googleapis.com",
  "firebase.googleapis.com",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(SHELL_CACHE)
      .then((cache) =>
        // addAll fails the whole install if one file 404s, so add individually.
        Promise.all(
          SHELL_ASSETS.map((url) =>
            cache.add(new Request(url, { cache: "reload" })).catch(() => null)
          )
        )
      )
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((key) => !key.startsWith(CACHE_VERSION))
            .map((key) => caches.delete(key))
        )
      )
      .then(() => self.clients.claim())
  );
});

self.addEventListener("message", (event) => {
  if (event.data === "SKIP_WAITING") self.skipWaiting();
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;

  let url;
  try {
    url = new URL(request.url);
  } catch {
    return;
  }

  if (NETWORK_ONLY_HOSTS.some((host) => url.hostname.endsWith(host))) return;

  // Firebase SDK + other CDN vendor code.
  if (url.origin !== self.location.origin) {
    event.respondWith(staleWhileRevalidate(request, VENDOR_CACHE));
    return;
  }

  // Navigation requests: serve the app shell so deep links work offline.
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request).catch(
        async () =>
          (await caches.match(request)) ||
          (await caches.match("./Euroluxinventory.html")) ||
          new Response("Offline", { status: 503, statusText: "Offline" })
      )
    );
    return;
  }

  event.respondWith(staleWhileRevalidate(request, SHELL_CACHE));
});

async function staleWhileRevalidate(request, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(request);

  const network = fetch(request)
    .then((response) => {
      if (response && (response.ok || response.type === "opaque")) {
        cache.put(request, response.clone()).catch(() => {});
      }
      return response;
    })
    .catch(() => null);

  const response = cached || (await network);
  return (
    response ||
    new Response("Offline and not cached", {
      status: 503,
      statusText: "Offline",
    })
  );
}
