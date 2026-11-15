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

Against a real field-api, create a git-ignored env file from `.env.example` and run:

```bash
flutter run --dart-define-from-file=.env.dev     # APP_ENV=dev, API_BASE_URL=..., API_MODE=live
```

## Check

```bash
make check         # l10n keys, analyzer, unit + flow tests
make screenshots   # re-render test/screenshots/goldens/*.png
make apk-demo      # needs the Android SDK
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

Never in the repo. CI reads `STAFF_KEYSTORE_B64`, `STAFF_KEYSTORE_PASSWORD`, `STAFF_KEY_ALIAS`, `STAFF_KEY_PASSWORD` from repository secrets (see `.github/workflows/ci.yml`). Without them the release APK is debug-signed (fine for testing, not for Play).
