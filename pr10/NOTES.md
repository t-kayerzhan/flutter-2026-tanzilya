# Practice 10 — The Data Arrives Later

## Level 1 — Event order
Expected: `A`, `C`, first app frame, then `B` and `6 students` after about two seconds.
Actual: A, C, fetchStudents #1, B, 6 students.

`fetchStudents()` takes two seconds and fails every third request. `save()` takes one second and rejects every second save.

## Level 2 — Four states
Loading shows a spinner. Error shows Retry. Empty shows `No students yet`. Data shows the list.
The screen checks `mounted` after `await`, before calling `setState()`.

Without the mounted check, the first error line was:
[Copy the actual `setState() called after dispose()` diagnostic.]

## Level 3 — FutureBuilder
The Future is stored in a field in `initState`, not recreated in `build`.
Changing Compact should not trigger a new fetch; Retry creates a new Future.

## Level 4 — Countdown
Version A uses `StreamBuilder`, which manages its subscription.
Version B uses `listen` and cancels the subscription in `dispose`.

With `cancel()`: [Record actual tick messages after leaving the screen.]
Without `cancel()`: [Record actual tick messages and any `setState() called after dispose()` error.]

## Level 5 — Save and errors
Save is awaited and wrapped in `try / on StateError`.
A spinner is shown and the Save button is disabled while saving.
The screen closes only after success; on error a SnackBar displays the message.

Unawaited version first exception line:
[Copy the real `Unhandled Exception: Bad state: server rejected 6` line.]

## Checks
- [ ] `dart format .`
- [ ] `flutter analyze` — No issues found!
- [ ] `flutter test`
- [ ] `flutter run`
- [ ] `screenshot_error.png` committed
- [ ] `screenshot_countdown.png` committed
