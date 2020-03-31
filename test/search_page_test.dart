import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search_page/search_page.dart';

const List<String> _mockList = ['a', 'b', 'c'];

class TestPage extends StatelessWidget {
  final SearchDelegate delegate;

  const TestPage(this.delegate);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('AppBar'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Search',
                icon: Icon(Icons.search),
                onPressed: () async {
                  showSearch<String>(
                    context: context,
                    delegate: delegate,
                  );
                },
              ),
            ],
          ),
          body: Text('Body'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Can open and close search page', (tester) async {
    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // We are on the homepage
    expect(find.text('AppBar'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    expect(find.text('AppBar'), findsNothing);
    expect(find.text('Body'), findsNothing);

    // Shows suggestion text
    expect(find.text('Suggestion text'), findsOneWidget);

    // Check whether the text field has focus
    final TextField textField = tester.widget(find.byType(TextField));
    expect(textField.focusNode.hasFocus, isTrue);

    // Close search
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();

    // We're once again inside the Home page
    expect(find.text('AppBar'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('Fresh search allways starts with empty query', (tester) async {
    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    // Search query is empty
    expect(_searchPage.query, '');

    // Search query has 'Foo'
    _searchPage.query = 'Foo';
    expect(_searchPage.query, 'Foo');

    // Search query is empty if we go back
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    expect(_searchPage.query, '');
  });

  testWidgets('Changing query shows up in search field', (tester) async {
    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    _searchPage.query = 'Foo';

    expect(find.text('Foo'), findsOneWidget);
    expect(find.text('Bar'), findsNothing);

    _searchPage.query = 'Bar';

    expect(find.text('Foo'), findsNothing);
    expect(find.text('Bar'), findsOneWidget);
  });

  testWidgets('Custom searchFieldLabel value', (WidgetTester tester) async {
    const searchHint = 'custom search hint';
    final defaultSearchHint =
        const DefaultMaterialLocalizations().searchFieldLabel;

    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
      searchLabel: searchHint,
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(find.text(searchHint), findsOneWidget);
    expect(find.text(defaultSearchHint), findsNothing);
  });

  testWidgets('Default searchFieldLabel is used when it is set to null',
      (tester) async {
    final searchHint = const DefaultMaterialLocalizations().searchFieldLabel;

    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(find.text(searchHint), findsOneWidget);
  });

  testWidgets('Shows results when query is correct', (tester) async {
    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    // Shows suggestion text
    expect(find.text('Suggestion text'), findsOneWidget);

    // Typing query 'a'
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pumpAndSettle();

    // Search has been successfull
    expect(_searchPage.query, 'a');
    expect(find.text('a'), findsNWidgets(2));
    expect(find.text('Failure text'), findsNothing);

    // Deleting previous query shows suggestion label
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('a'), findsNothing);
    expect(find.text('Suggestion text'), findsOneWidget);
  });

  testWidgets('Shows failure text when results are empty', (tester) async {
    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    // Shows suggestion text
    expect(find.text('Suggestion text'), findsOneWidget);

    // Typing query Wow
    await tester.enterText(find.byType(TextField), 'Wow');
    await tester.pumpAndSettle();

    // Shows failure text
    expect(_searchPage.query, 'Wow');
    expect(find.text('Failure text'), findsOneWidget);
  });
}
