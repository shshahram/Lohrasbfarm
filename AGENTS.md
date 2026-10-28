# Base44 sandbox notes

## What this repo is
`farm_app/` is a **Flutter (Dart) web client** — Persian/RTL UI for a farming
marketplace. There is **no backend in this repository**: every screen posts to a
remote PHP API hardcoded in `lib/` (`https://nikravaan.ir/api/*.php`). That host
does not resolve from the sandbox, so login/register/product flows end in the
app's "communication error" dialog. No external credentials are needed to run
the client.

## Running it
```sh
docker compose -f docker-compose.base44.yml up -d --build
```
- `web` service: `Dockerfile.base44` (debian + Flutter SDK 3.47.8) with
  `farm_app/` bind-mounted at `/app/farm_app`, serving on host port **3000**.
- Flutter 3.47.8 is downloaded in the image because `pubspec.yaml` requires
  Dart `^3.12.2` and no public Flutter image ships a new enough SDK
  (`ghcr.io/cirruslabs/flutter:stable` is Flutter 3.44.0 / Dart 3.12.0 and
  fails version solving).
- No external secret is required; the platform secret file is not mounted.

## Dev loop
`tools/base44/web_dev.sh` runs `flutter pub get`, `flutter build web`, then serves
`build/web` with `python3 -m http.server`. It fingerprints `lib/`, `web/` and
`pubspec.yaml` every 3s and rebuilds on change (~30-60s). Flutter has no static
watch server, so after an edit wait for `[base44] build complete` in
`docker compose logs -f web` and then `reload_preview`.
The first `flutter pub get` bumped four transitive packages in `pubspec.lock` and
let the tool add analyzer excludes to `analysis_options.yaml`; those changes are
committed so subsequent boots are a no-op.

## Checks
No lint/test dependency is installed in the image beyond the Flutter SDK:
```sh
docker compose -f docker-compose.base44.yml exec -T web flutter analyze
docker compose -f docker-compose.base44.yml exec -T web flutter test
```
`test/widget_test.dart` is the untouched Flutter counter template and fails
against this app (it expects a counter that does not exist).
