# Practice 9 — Put It High, Subscribe Low

## Level 1: Lifted State
The cart was stored in Shell using StatefulWidget and setState. Data and callbacks were passed to BooksScreen and CartScreen.

To show the total price in CartBadge, I changed 2 constructors: BooksScreen and CartBadge.

Rebuild test: 1 BooksScreen build and 6 row builds are expected for a full screen rebuild.

## Level 2: ChangeNotifier
I created Book and Cart models. Cart extends ChangeNotifier and uses notifyListeners() to update the UI.

The cart prevents duplicate books and protects its items using List.unmodifiable().

Model test expected output: `1 items, 3100 ₸`.

## Level 3: Provider
I used ChangeNotifierProvider above MaterialApp.

- `watch` listens for changes.
- `read` calls methods without subscribing.
- `Consumer` updates the cart list.

Using watch inside onPressed can cause a provider error. Using read instead of watch in the badge causes a silent update problem.

## Level 4: Scope
I used Map<Book, int> to store book quantities.

The badge uses context.select() to listen only to the number of different books.

Expected badge rebuilds after 3 quantity changes:
- With watch: 3
- With select: 0

Consumer with a constant child is used for the total label.

## Level 5: UI Logic
The Added SnackBar is controlled by BooksScreen.

The Clear Cart confirmation dialog is controlled by CartScreen.

The Cart model contains only data and business logic.

## Where Does It Live?
- Cart — Provided, because multiple screens use it.
- Search text — Ephemeral, used only in BooksScreen.
- Total expanded/collapsed — Ephemeral, used only in CartScreen.
- Theme mode — Lifted, because it affects the whole application.

## Testing
- `flutter analyze` — No issues found!
- `flutter test` — All tests passed!
- `dart format .` — Completed.
- `flutter run` — Successfully launched on Android emulator.

## Conclusion
I learned how to manage state using setState, ChangeNotifier, and Provider. Provider makes sharing data easier, while select helps reduce unnecessary widget rebuilds.