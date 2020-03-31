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
    expect(find.text('Suggestion text'), findsNothing);
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
    expect(find.text('Suggestion text'), findsOneWidget);
    expect(find.text('Failure text'), findsNothing);

    // Search query has 'Foo'
    await tester.enterText(find.byType(TextField), 'Foo');
    await tester.pumpAndSettle();

    expect(_searchPage.query, 'Foo');
    expect(find.text('Suggestion text'), findsNothing);
    expect(find.text('Failure text'), findsOneWidget);

    // Search query is empty even if we go back
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(_searchPage.query, '');
    expect(find.text('Suggestion text'), findsOneWidget);
    expect(find.text('Failure text'), findsNothing);
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

    expect(find.text('Suggestion text'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Foo');
    await tester.pumpAndSettle();

    expect(find.text('Foo'), findsOneWidget);
    expect(find.text('Bar'), findsNothing);
    expect(find.text('Suggestion text'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Bar');
    await tester.pumpAndSettle();

    expect(find.text('Foo'), findsNothing);
    expect(find.text('Bar'), findsOneWidget);
    expect(find.text('Suggestion text'), findsNothing);
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
    expect(find.text('Suggestion text'), findsNothing);
    expect(find.text('Failure text'), findsNothing);
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

    // Typing query 'Wow'
    await tester.enterText(find.byType(TextField), 'Wow');
    await tester.pumpAndSettle();

    // Shows failure text
    expect(_searchPage.query, 'Wow');
    expect(find.text('Wow'), findsOneWidget);
    expect(find.text('Suggestion text'), findsNothing);
    expect(find.text('Failure text'), findsOneWidget);
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
    expect(find.text('Suggestion text'), findsOneWidget);
    expect(clearButton.opacity, 0);

    // Typing query 'Wow'
    await tester.enterText(find.byType(TextField), 'Wow');
    await tester.pumpAndSettle();

    // Shows trailling clear button
    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(_searchPage.query, 'Wow');
    expect(find.text('Suggestion text'), findsNothing);
    expect(clearButton.opacity, 1);

    // Clears query and the clear button dissapears
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(find.text('Suggestion text'), findsOneWidget);
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
    expect(find.text('Suggestion text'), findsOneWidget);
    expect(clearButton.opacity, 0);

    // Typing query Wow
    await tester.enterText(find.byType(TextField), 'Wow');
    await tester.pumpAndSettle();

    // Shows trailling clear button
    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(_searchPage.query, 'Wow');
    expect(find.text('Suggestion text'), findsNothing);
    expect(clearButton.opacity, 1);

    // Taps clear button
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    clearButton = tester.widget<AnimatedOpacity>(find.ancestor(
      of: find.byIcon(Icons.clear),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(find.text('Suggestion text'), findsOneWidget);
    expect(find.text('Wow'), findsNothing);
    expect(_searchPage.query, '');
    expect(clearButton.opacity, 0);
  });
}
