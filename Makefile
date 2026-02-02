# Write a simple test to verify the app builds
flutter:
	@echo "Building Flutter app..."
	@cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks && flutter pub get
	@cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks && flutter build apk --debug

clean:
	@echo "Cleaning Flutter build..."
	@cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks && flutter clean

test:
	@echo "Running Flutter tests..."
	@cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks && flutter test

run:
	@echo "Running Flutter app..."
	@cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks && flutter run

analyze:
	@echo "Analyzing Dart code..."
	@cd c:\Users\adria\.gemini\antigravity\scratch\stillwalks && flutter analyze

.PHONY: flutter clean test run analyze
