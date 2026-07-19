# FieldCheck

A field check-in app with camera, GPS, and local storage, built with Flutter.

## How to Run

1. Clone this repo
2. Run `flutter pub get`
3. Connect an Android phone / start an emulator
4. Run `flutter run`

## Plugins Used

| Plugin | Purpose |
|---|---|
| `image_picker` | Take photo (camera) / pick from gallery |
| `geolocator` | Get GPS latitude/longitude/accuracy |
| `permission_handler` | Handle camera & location permissions |
| `hive` / `hive_flutter` | Local storage (persist check-ins) |
| `path_provider` | Save photo files to device storage |
| `flutter_map` + `latlong2` | Map display (OpenStreetMap) |
| `intl` | Date/time formatting |

## Requirements Completed

- [x] Three screens (Home, New Check-In, Detail) with navigation
- [x] Home — list of check-ins (thumbnail + note + timestamp) + empty state
- [x] New Check-In — note field with validation
- [x] New Check-In — Take Photo (camera/gallery) + preview
- [x] New Check-In — Get Location (lat/long/accuracy) with loading state
- [x] Detail — displays one record, read-only
- [x] Reusable components (CheckInCard, EmptyState, LocationDisplay, LocationMapView)
- [x] Camera permission — app doesn't crash when denied
- [x] Location permission — app doesn't crash when denied
- [x] Local storage — data persists after app restart

## Requirements Not Completed

None — all requirements have been completed.

## Video/Screenshots

(add link to video or screenshots here)