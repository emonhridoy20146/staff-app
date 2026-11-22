# Howlader Field — staff app

Offline-first Flutter app for field collection staff (Android first). Part of the Howlader Field Operations System; talks only to **field-api** `/api/v1`. The Laravel ERP stays the money truth and is never touched from here.

Read `CLAUDE.md` before changing anything, then `docs/`.

## Run it

```bash
flutter pub get
make gen                     # drift code + l10n
flutter run                  # demo mode (default): no server needed
```

Demo login: `01712345678` / `demo1234` (it asks for a new password the first time). Demo mode keeps everything in memory, uses 36 sample customers around Barishal and a fixed GPS point, and shows a "ডেমো" ribbon.

### Against the live test server (Android Studio)

`config/live.env` is committed and points at the live field-api test deployment (`https://howlader-apps-api.vercel.app/api/v1`). It holds public values only: no token, key or password (ADR-M16). The app talks only to field-api; it never calls the ERP.

1. `git pull`, open the `staff-app` folder in Android Studio, run **Pub get** (or `flutter pub get` and `make gen` once after a pull that changed the database or strings).
2. In the run configuration list next to the ▶ button pick **Live API** (debug, hot reload) or **Live API (release)** (fast, like the real APK). **Demo (no server)** is the in-memory demo. The plain `main.dart` configuration Android Studio may add itself is also the demo.
3. Press ▶ with the phone connected (USB debugging on).

APK file for a phone without Android Studio (Android Studio → Terminal):

```bash
flutter build apk --release --dart-define-from-file=config/live.env
# → build/app/outputs/flutter-apk/app-release.apk
```

The menu item *Build → Flutter → Build APK* passes no config, so it builds the **demo** APK. CI also uploads a ready live APK as the artifact `staff-app-live-apk` (next to `staff-app-demo-apk`) on every run.

Before the first login on the live server, in the admin panel: create the staff user (field staff role, branch, linked ERP employee), and while the app is below 1.0.0 set *Settings → Staff app → Minimum app version* to `0.10.0` (the server default `1.0.0` makes the app show "update required"). The first phone that signs in to a field staff account is bound to it; another phone needs approval under *Devices*.

### Against another field-api

Create a git-ignored env file from `.env.example` (secrets, if any, go only there) and run:

```bash
flutter run --dart-define-from-file=.env.dev     # APP_ENV=dev, API_BASE_URL=..., API_MODE=live
```

## Check

```bash
make check         # l10n keys, analyzer, unit + flow tests
make screenshots   # re-render test/screenshots/goldens/*.png
make apk-demo      # needs the Android SDK
make apk-live      # same, against config/live.env
```

## Layout

```
lib/
  app/        features list, bootstrap, router (stage-driven gates), shell, app
  core/       api (models, fake field-api), db (drift, encrypted), sync engine,
              format, time (Dhaka clock), theme, ui kit, media, notifications
  features/   auth, onboarding, today, customers, map, collections, cash,
              visits, notes, promises, tags, attendance, handovers, sync, settings
  l10n/       app_bn.arb (default), app_en.arb
test/         unit, offline sync flows, screenshots
docs/         spec (01–09), CHANGELOG
```

## Release signing

Never in the repo. CI reads `STAFF_KEYSTORE_B64`, `STAFF_KEYSTORE_PASSWORD`, `STAFF_KEY_ALIAS`, `STAFF_KEY_PASSWORD` from repository secrets (see `.github/workflows/ci.yml`).

**Every APK must be signed with the same key**, otherwise a phone answers "App not installed" when you install a new build over the old one (a debug key is new on every CI run). So a build on `main` without the secrets **fails** instead of publishing a debug-signed APK; other branches build with a warning.

One-time setup, on your own machine:

```bash
tool/make_release_keystore.sh        # asks for a password; prints the four secrets to add on GitHub
```

Keep `staff-release.jks` and its password safe (a lost key means no phone can ever be updated, only reinstalled). A phone that has a build signed with another key needs one uninstall (sync first, so nothing unsent is lost); after that every update installs over it. Android's `ANDROID_ID`, which the device id is derived from (ADR-M25), depends on the signing key, so the key must never change.
