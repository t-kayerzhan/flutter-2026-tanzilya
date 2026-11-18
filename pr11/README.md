# Practice 11 — How to use these files

## 1. Create project in Android Studio terminal

```bash
flutter create pr11
cd pr11
flutter pub add http provider
flutter pub get
```

## 2. Copy source files

Copy the folders `lib`, `test` and the files `analysis_options.yaml`, `NOTES.md` from this package **into** the generated `pr11` project. Merge folders and replace the template `main.dart`, `test/widget_test.dart`, `analysis_options.yaml`.

If your project is called something OTHER THAN `pr11`, change imports starting with `package:pr11/` in `test/widget_test.dart` to the `name:` in your `pubspec.yaml`.

If release APK networking is needed, check `android/app/src/main/AndroidManifest.xml` includes `<uses-permission android:name="android.permission.INTERNET" />` directly inside `<manifest>`; debug builds generally already allow internet.

## 3. First test in Postman or terminal (Level 1)

```bash
curl -i 'https://jsonplaceholder.typicode.com/users'
curl -i 'https://jsonplaceholder.typicode.com/users/1'
curl -i 'https://jsonplaceholder.typicode.com/users/999'
curl -i 'https://jsonplaceholder.typicode.com/users?id=3'
curl -i -X POST 'https://jsonplaceholder.typicode.com/users' \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test User","username":"testuser","email":"test@example.com"}'
```

Write real HTTP status and returned data in NOTES.md; do not present expected results as measured outcomes.

## 4. Run

```bash
dart format .
flutter analyze
flutter test
flutter run
```

Then verify: users list -> tap user -> details -> Back -> New user -> enter name, username, email -> Save. POST is simulated by JSONPlaceholder (it does not persist to their database); the returned user is prepended in local UsersModel, so refreshing will replace the list with server data and remove this fake-created user.

## 5. Required manual experiments

- **Level 2:** Temporarily paste the real user 1 JSON into a test function or main() using `jsonDecode`, verify round-trip, then intentionally change geo lat cast to `as double`, and separately change JSON id to a string. Restore code.
- **Level 3:** Run `grep -rn 'package:http' lib/` (two files). Temporarily remove the `404` line in `_check`, observe parsing error, restore. Temporarily call `getById(999)` from a test/main and catch NotFoundException, then restore.
- **Level 4:** Temporarily change ApiClient.create to `ApiClient.create(host: 'jsonplaceholder.typicode.co')`, run and tap Retry. Restore the correct host. Temporarily remove one pattern from exhaustive `switch`, observe analyzer error, restore.
- **Level 5:** Test airplane mode and a connected network with no internet. Time from Refresh to Offline. Record real timings and take screenshots in Flutter DevTools Network. Some transport failures may not show a 10-second pending row in DevTools; don't fabricate the screenshot. A `Future.timeout` does not necessarily abort the underlying socket, so inspect what DevTools actually reports.

## 6. Screenshots for submission

- `screenshot_200.png`: DevTools -> Network -> select a successful GET `/users` (status 200) -> show response body in detail pane -> save screenshot in project root.
- `screenshot_timeout.png`: DevTools -> Network -> a timed-out GET `/users`, ideally about 10 seconds with no HTTP status. Some environments won't show the exact row described by the lab; report what you actually saw in NOTES.md instead of editing or falsifying a screenshot.

## 7. GitHub

For a new separate repo create an empty GitHub repository named `pr11`:

```bash
git status
# only if not yet a Git repository:
git init
git branch -M main
git add .
git commit -m 'Complete Practice 11 - A Real Server'
git remote add origin https://github.com/YOUR_USERNAME/pr11.git
git push -u origin main
```

If `origin` already exists, do not call `git remote add` again. Use `git push origin main` after commit.

## Key design note

`ApiClient.create()` encapsulates `http.Client()` so `main.dart` does not import the http package. This keeps `grep -rn 'package:http' lib/` limited to exactly two files, as requested, while main.dart still wires the dependencies. ApiClient holds the actual HTTP client; UserRepository works with response objects internally but never exposes them to UI/models.

This source package was prepared without a Flutter SDK in the creation environment. Run `flutter analyze` and `flutter test` locally and resolve any toolchain-specific diagnostics before submitting.
