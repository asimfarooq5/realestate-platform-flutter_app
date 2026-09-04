.PHONY: help setup get upgrade clean build-runner watch analyze format test run run-android run-linux run-web apk bundle

DEVICE ?=

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Setup"
	@echo "  setup          install system deps + pub get + code generation"
	@echo "  get            flutter pub get"
	@echo "  upgrade        flutter pub upgrade"
	@echo ""
	@echo "Code generation"
	@echo "  build-runner   run build_runner once"
	@echo "  watch          run build_runner in watch mode"
	@echo ""
	@echo "Development"
	@echo "  run            run on connected device (set DEVICE=<id> to target one)"
	@echo "  run-android    run on Android"
	@echo "  run-linux      run on Linux desktop"
	@echo "  run-web        run in Chrome"
	@echo ""
	@echo "Quality"
	@echo "  analyze        dart analyze"
	@echo "  format         dart format lib test"
	@echo "  test           flutter test"
	@echo ""
	@echo "Build"
	@echo "  apk            build release APK"
	@echo "  bundle         build release AAB (Play Store)"
	@echo "  clean          flutter clean + remove generated files"

setup:
	sudo apt-get install -y libsecret-1-dev pkg-config
	flutter pub get
	dart run build_runner build

get:
	flutter pub get

upgrade:
	flutter pub upgrade

build-runner:
	dart run build_runner build

watch:
	dart run build_runner watch

analyze:
	dart analyze

format:
	dart format lib test

test:
	flutter test

run:
ifdef DEVICE
	flutter run -d $(DEVICE)
else
	flutter run
endif

run-android:
	flutter run -d android

run-linux:
	flutter run -d linux

run-web:
	flutter run -d chrome

apk:
	flutter build apk --release

bundle:
	flutter build appbundle --release

clean:
	flutter clean
	find lib -name "*.freezed.dart" -o -name "*.g.dart" -o -name "*.gr.dart" | xargs rm -f
