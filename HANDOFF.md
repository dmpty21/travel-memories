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
