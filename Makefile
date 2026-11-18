.PHONY: gen check test screenshots apk-demo apk-live

gen:
	dart run build_runner build --delete-conflicting-outputs
	flutter gen-l10n

check: gen
	dart run tool/check_l10n.dart
	flutter analyze
	flutter test --exclude-tags screenshots

screenshots:
	flutter test --tags screenshots --update-goldens

apk-demo:
	flutter build apk --release --dart-define=APP_ENV=demo

apk-live:
	flutter build apk --release --dart-define-from-file=config/live.env
