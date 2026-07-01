# Focus Todo

A local-first Flutter todo app with distraction-blocking focus sessions.

## Architecture

- **State management:** Provider (simple, sufficient for this scope — no Bloc/Riverpod overhead needed for a single-user local app)
- **Persistence:** `SharedPreferences` storing JSON-encoded tasks. No backend, no auth, fully offline. Swap to `sqflite`/Hive only if task volume grows beyond what JSON blobs handle comfortably (~1000+ tasks).
- **Folder structure (feature-based, not full Clean Architecture — unnecessary ceremony for this scope):**
  ```
  lib/
    models/         # Task, enums
    services/        # TaskRepository (storage), TaskProvider (state), FocusSessionProvider, DistractionBlockerService
    screens/         # HomeScreen, FocusScreen
  ```
- **Blocking is abstracted** behind `DistractionBlockerService` — currently a stub (`StubDistractionBlockerService`). This is intentional: blocking is the highest-risk, most platform-specific part of this app and needs native code (Kotlin/Swift via MethodChannel), which isn't something to bolt on without testing the rest of the app first.

## Setup

```bash
flutter pub get
flutter run
```

Requires Flutter SDK 3.x+. No environment variables, no API keys, no backend setup — it just runs.

## What's implemented (MVP)

- Full task CRUD: add, complete, delete (swipe), priority, due date
- Local persistence — tasks survive app restart
- Focus session timer (15/25/45/60 min presets), pause/resume/cancel
- Clean separation so `FocusSessionProvider` doesn't know or care how blocking is implemented underneath

## What's NOT implemented yet (Day 2 / next milestones)

1. **Real app blocking (Android):** Requires a native Kotlin `MethodChannel` implementation using `UsageStatsManager` + `AccessibilityService` (or a `VpnService`-based blocker) to detect and intercept the foreground app. This needs the user to grant Accessibility permission manually in system settings — Android does not allow this to be requested via a normal in-app permission dialog.
2. **Real app blocking (iOS):** Only possible via Apple's `FamilyControls` + `ManagedSettings` frameworks (Screen Time API). Requires a special entitlement from Apple, and the blocking granularity is by app *category*, not arbitrary custom rules — expect a more limited iOS experience than Android.
3. **App selection screen:** A UI to pick which installed apps get blocked during a session (needs platform code to list installed apps — `device_apps` package on Android, much more restricted on iOS).
4. **Notifications:** Session-complete notification when app is backgrounded.
5. **Unit tests:** `TaskProvider` and `FocusSessionProvider` are both fully decoupled from UI and from concrete service implementations specifically so they're trivially testable with mocked repositories/services — worth writing these before adding more features.

## Build order recommendation

1. Ship and use the todo list + timer as-is (already useful without blocking)
2. Add Android blocking only (skip iOS blocking initially — ship iOS without it, or Android-only for v1)
3. Add the app-selection picker UI
4. Revisit iOS blocking via Screen Time API once Android is proven and used daily by you
