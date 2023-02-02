import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_page/search_page.dart';

const List<String> _mockList = ['a', 'b', 'c', 'dd', 'ee', 'ff'];

class TestPage extends StatelessWidget {
  final SearchDelegate<String?> delegate;

  const TestPage(this.delegate, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('AppBar'),
            actions: [
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () => showSearch(
                  context: context,
                  delegate: delegate,
                ),
              ),
            ],
          ),
          body: const Text('Body'),
        ),
      ),
    );
  }
}

void main() {
  group('General SearchPage functionality', () {
    testWidgets('Can open and close search page', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // We are on the homepage
      expect(find.text('AppBar'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      expect(find.text('AppBar'), findsNothing);
      expect(find.text('Body'), findsNothing);

      // Check whether the text field has focus
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode!.hasFocus, isTrue);

      // Close search
      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();

      // We're once again inside the Home page
      expect(find.text('AppBar'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });
  });

  group('Shows custom information widgets', () {
    testWidgets('Shows custom suggestion widget', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      expect(find.text('Suggestion text'), findsOneWidget);

      // If we type on the text box, this widget will dissapear
      await tester.enterText(find.byType(TextField), 'Foo');
      await tester.pumpAndSettle();

      expect(find.text('Suggestion text'), findsNothing);

      // If we clean the query once again, it will reappear
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text('Suggestion text'), findsOneWidget);
    });

    testWidgets('Shows custom failure widget', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // At first, this widget will be hidden
      expect(find.text('Failure text'), findsNothing);

      // Types a query with no results
      await tester.enterText(find.byType(TextField), 'Foo');
      await tester.pumpAndSettle();

      // As the query doesnt fit any result, this widget will be shown
      expect(find.text('Failure text'), findsOneWidget);

      // Clears the query
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // This widget is hidden once again
      expect(find.text('Failure text'), findsNothing);
    });

    testWidgets('Shows item list at init when "showItemsOnEmpty"',
        (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        showItemsOnEmpty: true,
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Item list is visible
      expect(find.text('Suggestion text'), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(find.text('dd'), findsOneWidget);
      expect(find.text('ee'), findsOneWidget);
      expect(find.text('ff'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Foo');
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Item list is once again shown
      expect(find.text('Suggestion text'), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(find.text('dd'), findsOneWidget);
      expect(find.text('ee'), findsOneWidget);
      expect(find.text('ff'), findsOneWidget);
    });
  });

  group('Shows correct AppBar functionality', () {
    testWidgets(
      'Renders back button correctly',
      (tester) async {
        final searchPage = SearchPage<String>(
          items: _mockList,
          suggestion: const Text('Suggestion text'),
          failure: const Text('Failure text'),
          filter: (string) => [string],
          builder: Text.new,
        );

        await tester.pumpWidget(
          TestPage(searchPage),
        );

        // Entering search page
        await tester.tap(find.byTooltip('Search'));
        await tester.pumpAndSettle();

        // Finds back button icon
        expect(find.byType(BackButtonIcon), findsOneWidget);
      },
    );

    testWidgets('Fresh search allways starts with empty query', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Search query is empty when entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      expect(searchPage.query, '');

      // Search query has 'Foo'
      await tester.enterText(find.byType(TextField), 'Foo');
      await tester.pumpAndSettle();

      expect(searchPage.query, 'Foo');

      // Search query is empty even if we go back
      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      expect(searchPage.query, '');
    });

    testWidgets('Changing query shows up in search field', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Foo');
      await tester.pumpAndSettle();

      expect(find.text('Foo'), findsOneWidget);
      expect(find.text('Bar'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Bar');
      await tester.pumpAndSettle();

      expect(find.text('Foo'), findsNothing);
      expect(find.text('Bar'), findsOneWidget);
    });

    testWidgets('Custom searchFieldLabel value', (tester) async {
      const searchHint = 'custom search hint';
      final defaultSearchHint =
          const DefaultMaterialLocalizations().searchFieldLabel;

      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
        searchLabel: searchHint,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      expect(find.text(searchHint), findsOneWidget);
      expect(find.text(defaultSearchHint), findsNothing);
    });

    testWidgets(
      'Default searchFieldLabel is used when it is set to null',
      (tester) async {
        final searchHint =
            const DefaultMaterialLocalizations().searchFieldLabel;

        final searchPage = SearchPage<String>(
          items: _mockList,
          suggestion: const Text('Suggestion text'),
          failure: const Text('Failure text'),
          filter: (string) => [string],
          builder: Text.new,
        );

        await tester.pumpWidget(
          TestPage(searchPage),
        );

        // Entering search page
        await tester.tap(find.byTooltip('Search'));
        await tester.pumpAndSettle();

        expect(find.text(searchHint), findsOneWidget);
      },
    );
  });

  group('Shows correct filtered search functionality', () {
    testWidgets('Filter parameter is being used', (tester) async {
      // Added a new fiter which uses the length of the string
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [
          string,
          string.length.toString(),
        ],
        builder: (string) => ListTile(title: Text(string)),
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Typing query '1'
      await tester.enterText(find.byType(TextField), '1');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(3));

      // Typing query '2'
      await tester.enterText(find.byType(TextField), '2');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(3));

      // Typing query '3'
      await tester.enterText(find.byType(TextField), '3');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets("Null strings aren't an issue", (tester) async {
      // Added a new fiter which uses the length of the string
      final searchPage = SearchPage<String?>(
        items: [..._mockList, null],
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [
          string,
          string?.length.toString(),
        ],
        builder: (string) => ListTile(title: Text(string!)),
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Typing query '1'
      await tester.enterText(find.byType(TextField), '1');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(3));

      // Typing query '2'
      await tester.enterText(find.byType(TextField), '2');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(3));

      // Typing query '3'
      await tester.enterText(find.byType(TextField), '3');
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Shows results when query is correct', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Typing query 'a'
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // Search has been successfull
      expect(searchPage.query, 'a');
      expect(find.text('a'), findsNWidgets(2));
    });

    testWidgets('itemStartsWith parameter works', (tester) async {
      final searchPage = SearchPage<String>(
        items: ['female', 'male', 'female'],
        itemStartsWith: true,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Typing query 'male'
      await tester.enterText(find.byType(TextField), 'mal');
      await tester.pumpAndSettle();

      // Search has been successfull
      expect(searchPage.query, 'mal');
      expect(find.text('male'), findsOneWidget);
      expect(find.text('female'), findsNothing);
    });

    testWidgets('itemEndsWith parameter works', (tester) async {
      final searchPage = SearchPage<String>(
        items: ['malefe', 'male', 'malefe'],
        itemEndsWith: true,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Typing query 'fe'
      await tester.enterText(find.byType(TextField), 'fe');
      await tester.pumpAndSettle();

      // Search has been successfull
      expect(searchPage.query, 'fe');
      expect(find.text('malefe'), findsNWidgets(2));
      expect(find.text('male'), findsNothing);
    });

    testWidgets('itemStartsWith & itemEndsWith parameters works',
        (tester) async {
      final searchPage = SearchPage<String>(
        items: ['female', 'male', 'female123'],
        itemStartsWith: true,
        itemEndsWith: true,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Typing query 'female123'
      await tester.enterText(find.byType(TextField), 'female123');
      await tester.pumpAndSettle();

      // Search has been successfull
      expect(searchPage.query, 'female123');
      expect(find.text('female123'), findsNWidgets(2));
      expect(find.text('female'), findsNothing);
      expect(find.text('male'), findsNothing);
    });

    testWidgets(
      'Shows results when query is capital and has blankspaces',
      (tester) async {
        final searchPage = SearchPage<String>(
          items: _mockList,
          suggestion: const Text('Suggestion text'),
          failure: const Text('Failure text'),
          filter: (string) => [string],
          builder: Text.new,
        );

        await tester.pumpWidget(
          TestPage(searchPage),
        );

        // Entering search page
        await tester.tap(find.byTooltip('Search'));
        await tester.pumpAndSettle();

        // Typing query '  A  '
        await tester.enterText(find.byType(TextField), '  A  ');
        await tester.pumpAndSettle();

        // Search has been successfull
        expect(find.text('a'), findsOneWidget);
      },
    );

    testWidgets('Builds correct custom result widgets', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: (string) => ListTile(title: Text(string)),
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Typing query 'a'
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // Looks for the custom build widget
      expect(
        find.ancestor(
          of: find.text('a'),
          matching: find.byType(ListTile),
        ),
        findsOneWidget,
      );
    });
  });

  group('Shows clear button functionality', () {
    testWidgets(
      'Shows trailing clear button when writting query',
      (tester) async {
        final searchPage = SearchPage<String>(
          items: _mockList,
          suggestion: const Text('Suggestion text'),
          failure: const Text('Failure text'),
          filter: (string) => [string],
          builder: Text.new,
        );

        await tester.pumpWidget(
          TestPage(searchPage),
        );

        // Entering search page
        await tester.tap(find.byTooltip('Search'));
        await tester.pumpAndSettle();

        // Shows suggestion text and a hidden clear button
        var clearButton = tester.widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byIcon(Icons.clear),
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(clearButton.opacity, 0);

        // Typing query 'Wow'
        await tester.enterText(find.byType(TextField), 'Wow');
        await tester.pumpAndSettle();

        // Shows trailling clear button
        clearButton = tester.widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byIcon(Icons.clear),
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(clearButton.opacity, 1);

        // Clears query and the clear button dissapears
        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();

        clearButton = tester.widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byIcon(Icons.clear),
            matching: find.byType(AnimatedOpacity),
          ),
        );
        expect(clearButton.opacity, 0);
      },
    );

    testWidgets('Clears query when clicking on clear button', (tester) async {
      final searchPage = SearchPage<String>(
        items: _mockList,
        suggestion: const Text('Suggestion text'),
        failure: const Text('Failure text'),
        filter: (string) => [string],
        builder: Text.new,
      );

      await tester.pumpWidget(
        TestPage(searchPage),
      );

      // Entering search page
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Shows suggestion text and a hidden clear button
      var clearButton = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byIcon(Icons.clear),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(clearButton.opacity, 0);

      // Typing query Wow
      await tester.enterText(find.byType(TextField), 'Wow');
      await tester.pumpAndSettle();

      // Shows trailling clear button
      clearButton = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byIcon(Icons.clear),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(clearButton.opacity, 1);

      // Taps clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      clearButton = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.byIcon(Icons.clear),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(find.text('Wow'), findsNothing);
      expect(searchPage.query, '');
      expect(clearButton.opacity, 0);
    });
  });
}
