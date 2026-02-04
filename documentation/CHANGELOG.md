# Changelog

All notable changes to the Stillwalks project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Initial MVP implementation
- Screen lock tracking for passive Esencia generation
- Step counter for Orbe incubation
- 3 starter creatures: Spiristone, Radispirit, Slugrry
- Anti-cheat mechanisms (12h cap, time validation)
- Foreground service for Android 8+ compatibility
- Explorer journal (Pokédex) system
- Shop with upgrades system
- Sanctuary screen for Orbe progress
- Channeling animation screen
- Complete database schema with SQLite
- Seed data for MVP creatures and upgrades

### Security
- Anti-cheat: SystemClock validation to prevent time manipulation
- Anti-cheat: Step counter validation (max 5 steps/second)
- 12-hour maximum Esencia accumulation cap

## [0.1.0-alpha] - 2026-02-02

### Added
- Project initialization
- Flutter + Android (Kotlin) hybrid architecture
- Core game mechanics implementation
- Native Android services
- UI screens (6 total)
- Database with initial seed data

[Unreleased]: https://github.com/yourusername/stillwalks/compare/v0.1.0-alpha...HEAD
[0.1.0-alpha]: https://github.com/yourusername/stillwalks/releases/tag/v0.1.0-alpha
