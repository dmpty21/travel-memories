# Handoff — 2026-08-03 session

## App Store submission status

Picking up mid-submission. Where things stand now:

1. **Build archived and uploaded** — Diego archived the app in Xcode
   (Product ▸ Archive on the "Any iOS Device" destination) and uploaded it
   to App Store Connect via Organizer ▸ Distribute App ▸ App Store Connect
   ▸ Upload, with automatic signing. Upload succeeded; build should show up
   under the app's TestFlight/Build section once Apple finishes processing.
2. **App Store screenshots generated** — captured from simulator, populated
   with realistic sample data (Paris, Tokyo, Rome, Mexico City, New York
   trips/places/recommendations) rather than an empty new-install state.
   Two sizes were needed — App Store Connect rejected the first set with
   "dimensions are wrong" for the **"6.5\" Display" slot**, which actually
   wants legacy resolutions, not the newest 6.9" size:
   - `1320×2868` (6.9", iPhone 17 Pro Max simulator) — for the 6.9" slot.
   - `1284×2778` (App Store Connect's "6.5\" Display" slot — this is
     actually the iPhone **13** Pro Max / 12 Pro Max resolution, *not*
     14 Pro Max, which renders at 1290×2796 and does NOT match). Had to
     create an `iPhone 13 Pro Max` simulator specifically
     (`xcrun simctl create "iPhone 13 Pro Max" ...iPhone-13-Pro-Max`) to
     get pixel-exact screenshots — resizing/stretching the 6.9" set was
     considered but avoided to prevent distortion.
   Both sets uploaded successfully. **If more screenshots are needed later,
   check App Store Connect's screenshot page first for every required size
   slot** (there may be more than 6.9"/6.5" depending on how the listing is
   configured) rather than discovering them one rejection at a time.
3. **App Store Connect metadata — all completed**:
   - Age Rating questionnaire (App Information page) — answered "None" to
     everything, landed at 4+.
   - Content Rights Information — "No third-party content."
   - Contact Information — filled in.
   - Copyright — set to `2026 DM` (Diego's choice, to avoid using his full
     name; Apple doesn't require a legal name here).
   - Support URL — didn't exist yet, so a new page was created and pushed:
     [`docs/support.html`](docs/support.html), live at
     `https://dmpty21.github.io/travel-memories/support.html` (same visual
     style as the existing privacy policy page). Committed separately in
     40902bd, already pushed before this session's other changes.
   - App Privacy questionnaire — answered "No, we do not collect data",
     accurate given no servers/analytics/ads and CloudKit-only storage in
     the user's own private database.
   - **Sign-In Required toggle** (App Review Information section) was
     unexpectedly on, causing "User name"/"Password required" errors —
     Atlas has no accounts/login at all, so this was switched **off**.
4. **Result**: all "Unable to Add for Review" blockers cleared. Diego
   confirmed everything is done on the App Store Connect side as of this
   session — next real-world event is Apple's review outcome, which isn't
   something to check from this repo/session.

## Known issue: synthetic taps on custom SwiftUI Buttons don't register

This bit us again this session (previously noted 2026-08-01, see below).
On this environment's iOS 17 Pro Max simulator (iOS 26), **no** synthetic
tap — not the onboarding "Continue" button, not the TabView's own tab
items — reliably triggered a `Button` action closure, even with
press-and-hold `touch_path`. TextField focus and typing worked fine; only
`Button` taps failed. A background research task was flagged to look into
whether this is a known `simctl`/iOS 26 event-injection issue, but no fix
was in hand this session.

**Workaround used**: added small **DEBUG-only** dev hooks so screenshots
could be generated without relying on taps:
- [`Debug/SampleDataSeeder.swift`](TravelMemories/TravelMemories/Debug/SampleDataSeeder.swift)
  — populates realistic sample Places/Trips/Recommendations when launched
  with `-SeedSampleData`. Fully wrapped in `#if DEBUG`; compiled out of
  Release/App Store builds entirely.
- [`TravelMemoriesApp.swift`](TravelMemories/TravelMemories/TravelMemoriesApp.swift)
  — calls the seeder from a `#if DEBUG`-gated `.task`.
- [`RootTabView.swift`](TravelMemories/TravelMemories/Views/RootTabView.swift)
  — added a `selection` binding to the `TabView` so a tab can be selected
  by value; a `#if DEBUG`-gated `.onAppear` reads `-ScreenshotTab <name>`
  from launch arguments to jump straight to a tab. The `selection` state
  and `Tab(value:)` wiring itself is *not* DEBUG-gated (harmless in
  Release — behaves identically to the previous unselected TabView) but
  the jump-to-tab logic only compiles in Debug.

**Kept and committed** at Diego's request, for reuse next time screenshots
are needed. If you'd rather strip this dev-only tooling out later:

```bash
git checkout -- TravelMemories/TravelMemories/TravelMemoriesApp.swift TravelMemories/TravelMemories/Views/RootTabView.swift
rm -rf TravelMemories/TravelMemories/Debug
```

## Build/run reference (unchanged)

```bash
xcodebuild -scheme TravelMemories -configuration Debug -sdk iphonesimulator build
```

---

# Handoff — 2026-08-01 session

## What shipped this session

1. **Fixed Places grid text bug** — `PhotoCard` titles/subtitles were invisible
   over user-added photos. Root cause: gradient + caption were `ZStack`
   siblings with `clipShape` applied *before* they were composited, which
   also squared off the bottom corners once the overlays were added.
   Rewrote as `overlay()` chaining with `clipShape` applied last.
   (`Views/Places/PhotoCard.swift`)

2. **Recommendations: "On the List" vs visited** — On a place's detail
   screen, not-yet-visited recommendations now show in one flat "On the
   List" section; visited ones are grouped back under their category
   headers (Restaurants, Museums, etc.).
   (`Views/PlaceDetail/PlaceDetailView.swift`)

3. **Dashboard changes**:
   - Greeting reads "Hi, `<name>`" when a `Profile` exists, else "Welcome back".
   - New order: greeting → **Upcoming Trips** (if any, tap to open) → stat
     tiles (Countries/Cities/Restaurants) → By Category.
   - Removed the "Recent Recommendations" section entirely.
   (`Views/Dashboard/DashboardView.swift`)

4. **Map pins colored by visited status** — teal = on the list, green =
   visited (previously colored by favorite). Small legend capsule pinned
   to the top of the map. Favorite still shows on the tap-selection card.
   (`Views/PlaceDetail/PlaceMapView.swift`)

5. **Hotel & flight reservations on trips** — new `Reservation` model
   (`ReservationType`: `.hotel` / `.flight`), added to the SwiftData schema
   and to `Trip` as a cascade-delete relationship. Flight fields
   (`airline`, `flightNumber`, `departureAirport`, `arrivalAirport`) are
   kept as discrete fields, not free text, specifically so a future
   flight-status API integration can key off `airline` + `flightNumber`
   directly. Trip detail's "+" is now a menu: Itinerary Item / Hotel
   Reservation / Flight Reservation. Reservations list in their own
   section, sorted by date, tap to edit, swipe to delete.
   (`Models/Reservation.swift`, `Models/ReservationType.swift`,
   `Views/Trips/AddEditReservationView.swift`, `Views/Trips/TripDetailView.swift`)

All 5 items are committed as separate commits on `main` (not pushed yet —
run `git push` when ready, or ask Claude to do it):

```
51cd598 Add hotel and flight reservations to trips
c303f73 Color map pins by visited status instead of favorite
7229ea2 Split place recommendations into "On the List" vs visited-by-category
9705be9 Fix Places grid card title/subtitle not rendering over real photos
```

## Verified

- All changes build clean (`xcodebuild -scheme TravelMemories -sdk
  iphonesimulator`).
- The PhotoCard fix was confirmed against real photos on the user's own
  device/simulator (mine had an unrelated local tooling issue — see below).

## Known non-issue worth knowing about

Debugging the PhotoCard bug took a while because the assistant's own local
iOS Simulator would not deliver synthetic taps to some custom SwiftUI
buttons (the onboarding "Continue" button, the "Add Photo" `PhotosPicker`
label) — tab bar and toolbar buttons worked fine. This is a simulator/
tooling quirk in that environment, not an app bug; the user's own device
was unaffected. If this comes up again, don't sink time into it — trust
device-side testing over that particular simulator for interactive flows.

## Suggested next steps (not built, just flagged)

- **Car Rental** as a third `ReservationType` — trivial given the enum
  structure (pickup/return location & time, confirmation number).
- **Restaurant reservation details** (time, party size) on recommendations,
  separate from the existing visited/favorite flags.
- **Dashboard reservations summary**, e.g. "Next: Flight AA123, Thu 6:40 AM",
  alongside Upcoming Trips.
- The flight fields are ready for a real flight-status lookup (FlightAware/
  AeroDataBox/etc.) whenever that's wanted — `airline` + `flightNumber` are
  already structured for it.

## Build/run reference

```bash
xcodebuild -scheme TravelMemories -configuration Debug -sdk iphonesimulator build
```

Schema lives in `TravelMemoriesApp.swift` — anytime a new `@Model` is
added, it must be added to the `Schema([...])` array there or SwiftData
won't know about it.
