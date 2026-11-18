# Practice 11 — A Real Server

## Level 1: Postman First

In this practice, I worked with the JSONPlaceholder REST API to understand how real HTTP requests and JSON responses work.

### HTTP Requests

| Request | HTTP Status | Response |
|---|---|---|
| GET /users | 200 OK | Array of 10 users |
| GET /users/1 | 200 OK | One user object |
| GET /users/999 | 404 Not Found | Empty JSON object {} |
| GET /users?id=3 | 200 OK | Array containing one user |
| POST /users | 201 Created | Created user object with an assigned ID |

The Content-Type of the JSON responses is application/json.

The GET /users endpoint returns a list, while GET /users/1 returns a single object. The filtered request GET /users?id=3 returns an array containing one user, not a single object.

The POST request returns status 201 and adds an ID to the submitted data. JSONPlaceholder simulates creation, so the data is not permanently stored on the server.

### User Fields

| Field | JSON Type | Dart Type | Nullable? |
|---|---|---|---|
| id | number | int | No |
| name | string | String | No |
| username | string | String | No |
| email | string | String | No |
| address | object | Address | No |
| phone | string | String | No |
| website | string | String? | Yes |
| company | object | ({String name, String catchPhrase}) | No |

### Address Fields

| Field | JSON Type | Dart Type | Nullable? |
|---|---|---|---|
| street | string | String | No |
| suite | string | String | No |
| city | string | String | No |
| zipcode | string | String | No |
| geo | object | Geo | No |

### Geo Fields

| Field | JSON Type | Dart Type | Nullable? |
|---|---|---|---|
| lat | string | double | No |
| lng | string | double | No |

### Company Fields

| Field | JSON Type | Dart Type | Nullable? |
|---|---|---|---|
| name | string | String | No |
| catchPhrase | string | String | No |
| bs | string | Not included in the model | — |

The address and company fields are nested JSON objects. The geo object is nested inside address, making it a second level of nesting.

The website field is treated as optional in the Dart model.

## Level 2: JSON Models

I created three Dart classes: User, Address, and Geo.

Each class has final fields, a const constructor, and fromJson and toJson methods.

The fromJson method converts JSON into Dart objects, while toJson converts the objects back into JSON-compatible maps.

The API sends latitude and longitude as strings, so I used double.parse() to convert them into double values.

For example:

```dart
lat: double.parse(json['lat'] as String)
```

I also added the phoneDigits getter to remove spaces, brackets, and other unnecessary symbols from phone numbers while keeping digits and the plus sign.

The models support JSON round-trip conversion, where an object can be converted to JSON and reconstructed using fromJson.

### Incorrect JSON Types

I examined two possible type errors:

1. If latitude is cast directly as double instead of being parsed from String, Dart throws a type error.
2. If the ID is changed from an integer to a string, the `as int` cast fails.

These cases show why it is important to check the actual JSON types before implementing fromJson.

## Level 3: API Client and Repository

I separated HTTP communication from the user interface.

The ApiClient sends requests, checks HTTP status codes, decodes JSON, and handles network errors.

The UserRepository provides three methods:

- getAll() retrieves all users.
- getById(int id) retrieves one user.
- create(User draft) sends a POST request.

I used Uri.https to construct request URLs instead of manually combining URL strings.

The HTTP client has a timeout of 10 seconds.

### Exception Handling

| Condition | Exception |
|---|---|
| SocketException | NoConnectionException |
| TimeoutException | NoConnectionException |
| HTTP 401 | UnauthorizedException |
| HTTP 404 | NotFoundException |
| HTTP 5xx | ServerException |
| Invalid JSON or incorrect model data | BadResponseException |

Status codes are checked before decoding the response body.

For example, GET /users/999 returns 404. This should produce NotFoundException instead of trying to parse an empty object as a user.

The repository returns Dart models rather than raw JSON maps or HTTP responses.

## Level 4: Repository → Model → Screen

I created UsersModel using ChangeNotifier and connected it to the UI through Provider.

The model stores three main values:

```dart
List<User> items = const [];
ApiException? error;
bool loading = false;
```

The load() method requests data from UserRepository.

Before loading, the model sets loading to true and clears the previous error.

When the request finishes, it stores the users or the exception and notifies the UI through notifyListeners().

The screen uses Consumer to respond to state changes.

The application supports loading, data, offline, server error, and other error states.

It also provides Retry and pull-to-refresh functionality.

The user list displays names, emails, and cities. Selecting a user opens the detail screen with additional information.

The screen handles the different ApiException types using a switch expression.

## Level 5: Network Tests and POST

### Test 1: Airplane Mode

The purpose of this test is to simulate a complete loss of network connectivity.

Expected result: the application should display the Offline screen instead of crashing.

Exact duration: Not measured.

### Test 2: Network Failure

I examined a failed network request in Flutter DevTools.

The Network panel displayed the following information:

| Property | Result |
|---|---|
| Method | GET |
| URL | https://jsonplaceholder.typicode.com/users |
| Status | Error |
| Type | http |
| Duration | 8 seconds |

The request failed without receiving a successful HTTP response.

The observed duration was 8 seconds. This confirms a network failure, but does not prove that the configured 10-second timeout was reached.

Evidence: screenshot_timeout.png.

### Successful HTTP Request

Flutter DevTools also showed a successful API request.

| Property | Result |
|---|---|
| Method | GET |
| URL | https://jsonplaceholder.typicode.com/users |
| Status | 200 |
| Type | json |
| Duration | 1 second |

This confirms that the application successfully connected to JSONPlaceholder and received a response.

Evidence: screenshot_200.png.

### POST: Create New User

I implemented a New User form with three fields: name, username, and email.

The form validates the input before submitting the request.

When Save is pressed, the application sends a POST request through UsersModel and UserRepository.

The Save button is disabled while the request is in progress to prevent duplicate submissions.

When the request succeeds, the returned user is inserted at the top of the local list and the form closes.

If the request fails, the application displays a SnackBar and keeps the form open.

JSONPlaceholder simulates the POST operation and does not permanently store the created user.

## Final Verification

- Flutter project created with http and provider dependencies.
- User, Address, and Geo models implemented.
- fromJson and toJson methods implemented.
- ApiClient and UserRepository implemented.
- HTTP requests use a 10-second timeout.
- Custom API exceptions implemented.
- ChangeNotifier and Provider connected to the UI.
- User list and detail screen implemented.
- Pull-to-refresh and Retry implemented.
- New User form with validation implemented.
- Successful GET request observed: status 200.
- Failed GET request observed: Error, 8 seconds.
- Network screenshots prepared for submission.

## Conclusion

In Practice 11, I learned how to connect a Flutter application to a real REST API using the http package.

I explored JSON responses, created Dart models with fromJson and toJson, and separated networking logic into ApiClient and UserRepository.

I also used ChangeNotifier and Provider to manage loading, data, and error states in the user interface.

The application includes user details, pull-to-refresh, Retry, a POST form, custom exceptions, and a 10-second network timeout.

The main lesson is that HTTP communication, data models, and UI logic should be separated. This makes the application easier to maintain and more reliable when network requests fail.