# CI Workflow Resolution Plan

This plan addresses the ongoing CI failures in the GitHub Actions pipeline for both the Go backend and the Flutter app.

## Proposed Changes

### Backend (Go)

- **[MODIFY] [report_service.go](file:///C:/Users/admin/Desktop/habittracker/backend/internal/services/report_service.go)**
    - Add error checking for all `json.Marshal` calls in `RegenerateReport`.
    - Fix `SA9003`: Add logging to the empty error branch in `GenerateReport`'s `CreateRevisionHabitsFromReport` call.
- **[MODIFY] [log_service.go](file:///C:/Users/admin/Desktop/habittracker/backend/internal/services/log_service.go)**
    - Fix `SA9003`: Add logging to empty error branches in `CreateOrUpdateLog`.
- **[MODIFY] [notification_service.go](file:///C:/Users/admin/Desktop/habittracker/backend/internal/services/notification_service.go)**
    - Remove `fmt.Printf` in `sendFCMNotification` (replaced with a no-op as it's a mock) to satisfy linter rules against console output.
- **[MODIFY] [gemini_service.go](file:///C:/Users/admin/Desktop/habittracker/backend/internal/services/gemini_service.go)**
    - Add error checking for `json.MarshalIndent` in `buildReportPrompt`.

### Flutter (Dart)

- **[MODIFY] [widget_test.dart](file:///C:/Users/admin/Desktop/habittracker/app/test/widget_test.dart)**
    - Replace the outdated boilerplate counter test with a valid sanity test for `HabitTrackerApp`.
- **[MODIFY] [notification_service.dart](file:///C:/Users/admin/Desktop/habittracker/app/lib/core/services/notification_service.dart)**
    - Replace `print` calls with `debugPrint` for linter compliance.
- **[MODIFY] [api_client.dart](file:///C:/Users/admin/Desktop/habittracker/app/lib/data/remote/api_client.dart)**
    - Replace `print` calls with `debugPrint` in interceptors and error handlers.

## Verification Plan

### Automated Tests
- Run `go build ./...` and `go vet ./...` in the backend directory.
- (Recommended) User should run `flutter test` and `flutter analyze` locally after my changes to confirm resolution before pushing if possible.

### Manual Verification
- After pushing, monitor GitHub Actions to ensure both `Backend Tests` and `Flutter Tests` jobs turn green.
