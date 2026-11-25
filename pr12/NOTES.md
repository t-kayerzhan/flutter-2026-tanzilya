# Practice 12 — Survive a Restart

## Level 1: Package Evaluation

**1. shared_preferences**

Verified publisher: flutter.dev. Last release: October 2026. Platforms: Android, iOS, Linux, macOS, Web, Windows. Pub points: 160. The package has a public issue tracker and recent commits. It depends on Flutter and platform-specific packages. License: BSD-3-Clause. I use it to save dark mode and the selected city.

**2. flutter_secure_storage**

Verified publisher: steenbakker.dev. Last release: September 2026. Platforms: Android, iOS, Linux, macOS, Web, Windows. Pub points: 160. The project has public issues and commits. It depends on Flutter and platform-specific secure storage packages. License: BSD-3-Clause. I use it to save the login token safely.

**3. path_provider**

Verified publisher: flutter.dev. Last release: June 2026. Platforms: Android, iOS, Linux, macOS, Windows. Pub points: 160. The project has a public issue tracker and source commits. It depends on Flutter and platform-specific packages. License: BSD-3-Clause. I use it to find the Documents directory.

**4. image_picker**

Verified publisher: flutter.dev. Last release: October 2026. Platforms: Android, iOS, Linux, macOS, Web, Windows. Pub points: 160. The package has public issues and recent commits. It depends on Flutter and platform-specific image picker packages. License: Apache-2.0 and BSD-3-Clause. I use it to choose or take a profile photo.

**5. permission_handler**

Verified publisher: baseflow.com. Last release: September 2026. Platforms: Android, iOS, Web, Windows. Pub points: 160. The project has public issues and commits. It depends on Flutter and platform-specific permission packages. License: MIT. I use it to request camera permission.

**6. url_launcher**

Verified publisher: flutter.dev. Last release: October 2026. Platforms: Android, iOS, Linux, macOS, Web, Windows. Pub points: 160. The package has public issues and recent commits. It depends on Flutter and platform-specific packages. License: BSD-3-Clause. I use it to open email, phone and website links.

## Package Versions and Dependencies
The exact resolved version of http in pubspec.lock is 1.6.0.

The version constraint ^1.2.0 allows versions from 1.2.0
up to, but not including, 2.0.0.

Therefore, http 1.6.0 is allowed by ^1.2.0.

pubspec.lock records the exact version 1.6.0.
This helps the project use the same dependency version
when it is installed again.
I added the six packages using `flutter pub add`.

The caret symbol `^` allows compatible package updates.

For example, `^1.2.0` accepts versions from 1.2.0 up to, but not including, 2.0.0.

Allowed: 1.2.0, 1.2.5, 1.9.9.

Not allowed: 1.1.9, 2.0.0, 2.1.0.

Without the caret, `http: 1.2.0` allows only version 1.2.0.

The `pubspec.yaml` file defines allowed package versions. The `pubspec.lock` file saves the exact versions selected for the application.

We commit `pubspec.lock` to GitHub because it helps everyone use the same dependency versions.

I also used `flutter pub outdated` to check for newer versions.

The dependency check reported 14 packages with newer versions outside the current dependency constraints. For example, `image_picker_ios` 0.8.13+15 had version 0.8.13+16 available.

Newer versions may not be selected because of dependency or SDK constraints. I did not force updates because the project already resolves its dependencies.

## Level 2: Persistent Settings

I used `SharedPreferencesAsync` to save the dark mode setting and the selected city.

The application reads these values before `runApp()`.

First, `WidgetsFlutterBinding.ensureInitialized()` prepares Flutter plugins.

Then the application loads the saved settings.

This prevents the wrong theme from appearing at startup.

`notifyListeners()` updates the screen immediately, before the data is saved to disk.

If no dark mode value exists, the default is false.

If no city is selected, all users are shown.

When the user changes the settings, they are saved for the next restart.

## Level 3: Secure Token

I added a fake login system.

The user enters an email and a password with at least eight characters.

After one second, the application creates a fake token.

The token is saved using `flutter_secure_storage`.

The `SecureStore` class has three main methods:

- `saveToken()` saves the token.
- `readToken()` reads the saved token.
- `clear()` deletes the token.

The application reads the token at startup, so the user can stay signed in.

The `ApiClient` adds the token to HTTP requests using the Authorization header.

Example: `Authorization: Bearer tok_12345`

The repository does not need to manage the token.

I do not save tokens in `shared_preferences` because it is not secure storage.

On Android, normal preferences may be stored in app data such as XML files or DataStore. On iOS, they may be stored using NSUserDefaults. Backups or a compromised device may expose this data.

Secure storage uses Android Keystore and iOS Keychain.

On iOS, Keychain data can sometimes remain after uninstalling the application.

On Android, removing or changing the device lock screen may affect access to protected keys, depending on their configuration.

When the user signs out, the application deletes the token.

## Level 4: Offline List

I used `path_provider` and `File` to save the users list.

After a successful API request, the application converts the users into JSON using `jsonEncode()`.

The data is saved in a file named `users.json`.

I use `getApplicationDocumentsDirectory()` because the data should remain available after restarting the application.

I do not use `getTemporaryDirectory()` for permanent data because the operating system may delete temporary files.

If the internet is unavailable, the repository catches `NoConnectionException`.

Then it tries to read the saved users from `users.json`.

If saved users exist, the application shows them with the message:

**Saved data · no connection · Retry**

The `fromCache` value is true when the data comes from the saved file.

When the internet works again, the Retry button loads fresh data and removes the banner.

If there is no internet and no saved file, the application shows an Offline error instead of an empty list.

## Level 5: Profile Photo and Permissions

I used `image_picker` to choose a photo from the gallery or take a photo with the camera.

I added camera permission to `AndroidManifest.xml`.

For iOS, I added `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` to `Info.plist`.

The application asks for camera permission only when the user taps Take photo.

I handle different permission results:

- `granted`: Open the camera.
- `denied`: Show a message explaining the denial.
- `permanentlyDenied`: Show a custom AlertDialog.
- `restricted`: Explain that access is restricted.
- `limited`: Handle limited access when supported.

The custom dialog has an Open settings button.

This button uses `openAppSettings()`.

If the user cancels photo selection, `pickImage()` returns null. The application handles this without crashing.

The selected photo is copied into the Documents directory as `avatar.jpg`.

The photo path is saved using `shared_preferences` so the application can restore the photo after a restart.

### Permission Differences

On Android, the system may stop showing the camera permission request after repeated denials. The user must then allow access in the application settings.

On iOS, the camera permission is normally requested once. After the user denies it, permission must be changed in Settings.

For iOS Photos, there is also a state called `limited`. This means the user allows access to only selected photos.

## Opening External Applications

I used `url_launcher` to open different applications.

- `mailto:` opens an email application.
- `tel:` opens the phone dialer.
- `https:` opens a website in a browser.

The application checks the result of `launchUrl()`.

If no application can open the link, it shows the message: **No app can open this.**

A website needs a correct URL scheme.

For example, `kbtu.edu.kz` does not contain a scheme, but `https://kbtu.edu.kz` is a valid web URL.

## Conclusion

In Practice 12, I learned how to save application settings, store login tokens securely, use offline data and work with device permissions.

I also learned that applications must handle errors, missing files, cancelled actions and denied permissions.

These features help the application continue working after a restart, without the internet, or when the user denies access to the camera.

## Evidence

- `screenshots/screenshot_offline_banner.png`
- `screenshots/screenshot_permission_dialog.png`

## Package Sources

- https://pub.dev/packages/shared_preferences
- https://pub.dev/packages/flutter_secure_storage
- https://pub.dev/packages/path_provider
- https://pub.dev/packages/image_picker
- https://pub.dev/packages/permission_handler
- https://pub.dev/packages/url_launcher
