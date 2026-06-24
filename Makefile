# Kingdom Heir — Makefile

run-dev:
	flutter run --dart-define-from-file=dart_defines/dev.json -t lib/main_dev.dart

run-staging:
	flutter run --dart-define-from-file=dart_defines/staging.json -t lib/main_staging.dart

run-prod:
	flutter run --dart-define-from-file=dart_defines/prod.json -t lib/main.dart

build-android-dev:
	flutter build apk --dart-define-from-file=dart_defines/dev.json -t lib/main_dev.dart --debug

build-android-prod:
	flutter build appbundle --dart-define-from-file=dart_defines/prod.json \
		-t lib/main.dart --obfuscate --split-debug-info=build/debug_symbols

build-ios-prod:
	flutter build ipa --dart-define-from-file=dart_defines/prod.json \
		-t lib/main.dart --obfuscate --split-debug-info=build/debug_symbols

generate:
	flutter pub run build_runner build --delete-conflicting-outputs

watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

test:
	flutter test --coverage

test-unit:
	flutter test test/unit/

test-widget:
	flutter test test/widget/

analyze:
	flutter analyze

format:
	dart format lib/ test/

clean:
	flutter clean && flutter pub get

get:
	flutter pub get
