# Mobile pack Makefile: Xcode + Gradle. Copy over the core placeholder Makefile and set the variables.
IOS_PROJECT ?= ios/App.xcodeproj
IOS_SCHEME  ?= App
IOS_SIM     ?= iPhone 16
IOS_DEST    := platform=iOS Simulator,name=$(IOS_SIM)
XCB         := xcodebuild -project $(IOS_PROJECT) -scheme $(IOS_SCHEME) -destination '$(IOS_DEST)' -quiet
GRADLE      := cd android && ./gradlew

.PHONY: build test lint screens verify evals

build:
	$(XCB) build
	$(GRADLE) assembleDebug

test:
	$(XCB) test
	$(GRADLE) testDebugUnitTest

lint:
	swiftlint --strict
	$(GRADLE) ktlintCheck

screens:
	@mkdir -p artifacts/screens
	$(XCB) test -only-testing:$(IOS_SCHEME)UITests -resultBundlePath artifacts/screens/ios.xcresult
	xcrun xcresulttool export attachments --path artifacts/screens/ios.xcresult --output-path artifacts/screens/ios
	$(GRADLE) recordPaparazziDebug && cp -r app/src/test/snapshots/images ../artifacts/screens/android

verify: build lint test
	@echo "verify: all checks passed"

evals:
	./evals/run.sh
