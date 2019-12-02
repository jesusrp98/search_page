import 'package:flutter/material.dart';

typedef SearchFilter<T> = List<String> Function(T t);
typedef ResultBuilder<T> = Widget Function(T t);

/// This class helps to implement a search view, using [SearchDelegate].
/// It can show suggestion & unsuccessful-search widgets.
class SearchPage<T> extends SearchDelegate<T> {
  /// Widget that is built when current query is empty.
  /// Suggests the user what's possible to do.
  final Widget suggestion;

  /// Widget built when there's no item in [items] that
  /// matches current query.
  final Widget failure;

  /// Method that builds a widget for each item that matches
  /// the current query parameter entered by the user.
  ///
  /// If no builder is provided by the user, the package will try
  /// to display a [ListTile] for each child, with a string
  /// representation of itself as the title.
  final ResultBuilder<T> builder;

  /// Method that returns the specific parameters intrinsic
  /// to a [T] instance.
  ///
  /// For example, filter a person by its name & age parameters:
  /// filter: (person) => [
  ///   person.name,
  ///   person.age.toString(),
  /// ]
  ///
  /// Al parameters to filter through must be [String] instances.
  final SearchFilter<T> filter;

  /// This text will be shown in the [AppBar] when
  /// current query is empty.
  final String searchLabel;

  /// List of items where the search is going to take place on.
  /// They have [T] on run time.
  final List<T> items;

  /// Theme that would be used in the [AppBar] widget, inside
  /// the search view.
  final ThemeData barTheme;

  SearchPage({
    this.suggestion = const SizedBox(),
    this.failure = const SizedBox(),
    this.builder,
    @required this.filter,
    @required this.items,
    this.searchLabel,
    this.barTheme,
  })  : assert(suggestion != null),
        assert(failure != null),
        assert(builder != null),
        assert(filter != null),
        assert(items != null),
        super(searchFieldLabel: searchLabel);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return barTheme ??
        Theme.of(context).copyWith(
          textTheme: TextTheme(
            title: TextStyle(
              color: Theme.of(context).primaryTextTheme.title.color,
              fontSize: 20,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
              color: Theme.of(context).primaryTextTheme.caption.color,
              fontSize: 20,
            ),
          ),
        );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // Builds a 'clear' button at the end of the [AppBar]
    return [
      AnimatedOpacity(
        opacity: query.isNotEmpty ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        child: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Creates a default back button as the leading widget.
    // It's aware of targeted platform.
    // Used to close the view.
    return IconButton(
      icon: const BackButtonIcon(),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    // Deletes possible blank spaces & converts the string to lower case
    final String cleanQuery = query.toLowerCase().trim();

    // Using the [filter] moethod, filters through the [items] list
    final List<T> result = items
        .where(
          (item) => filter(item)
              .map((value) => value = value?.toLowerCase()?.trim())
              .any((value) => value?.contains(cleanQuery) == true),
        )
        .toList();

    // Builds a list with all filtered items
    // if query and result list are not empty
    return Builder(
      builder: (_) {
        if (cleanQuery.isEmpty) {
          return suggestion;
        } else if (result.isEmpty) {
          return failure;
        } else {
          return ListView(
            children: result
                .map(
                  builder ??
                      (child) => ListTile(
                            title: Text(child.toString()),
                          ),
                )
                .toList(),
          );
        }
      },
    );
  }
}
