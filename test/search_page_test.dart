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

  testWidgets('Shows custom suggestion widget', (tester) async {
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

  testWidgets('Applies custom AppBar to the widget', (tester) async {
    final _searchPage = SearchPage<String>(
      items: _mockList,
      suggestion: Text('Suggestion text'),
      failure: Text('Failure text'),
      filter: (string) => [string],
      builder: (string) => Text(string),
      barTheme: ThemeData(
        primaryColor: Colors.red,
      ),
    );

    await tester.pumpWidget(
      TestPage(_searchPage),
    );

    // Entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    AppBar searchBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(searchBar.backgroundColor, Colors.red);
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

    // Search query is empty when entering search page
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(_searchPage.query, '');

    // Search query has 'Foo'
    await tester.enterText(find.byType(TextField), 'Foo');
    await tester.pumpAndSettle();

    expect(_searchPage.query, 'Foo');

    // Search query is empty even if we go back
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

    await tester.enterText(find.byType(TextField), 'Foo');
    await tester.pumpAndSettle();

    expect(find.text('Foo'), findsOneWidget);
    expect(find.text('Bar'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Bar');
    await tester.pumpAndSettle();

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

    // Typing query 'a'
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pumpAndSettle();

    // Search has been successfull
    expect(_searchPage.query, 'a');
    expect(find.text('a'), findsNWidgets(2));
  });

  testWidgets('Shows trailing clear button when writting query',
      (tester) async {
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

    // Shows suggestion text and a hidden clear button
    AnimatedOpacity clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(clearButton.opacity, 0);

    // Typing query 'Wow'
    await tester.enterText(find.byType(TextField), 'Wow');
    await tester.pumpAndSettle();

    // Shows trailling clear button
    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(clearButton.opacity, 1);

    // Clears query and the clear button dissapears
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(clearButton.opacity, 0);
  });

  testWidgets('Clears query when clicking on clear button', (tester) async {
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

    // Shows suggestion text and a hidden clear button
    AnimatedOpacity clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(clearButton.opacity, 0);

    // Typing query Wow
    await tester.enterText(find.byType(TextField), 'Wow');
    await tester.pumpAndSettle();

    // Shows trailling clear button
    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(clearButton.opacity, 1);

    // Taps clear button
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(find.text('Wow'), findsNothing);
    expect(_searchPage.query, '');
    expect(clearButton.opacity, 0);
  });
}
