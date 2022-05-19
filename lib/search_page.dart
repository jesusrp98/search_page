import 'package:flutter/material.dart';

typedef SearchFilter<T> = List<String?> Function(T t);
typedef ResultBuilder<T> = Widget Function(T t);

/// This class helps to implement a search view, using [SearchDelegate].
/// It can show suggestion & unsuccessful-search widgets.
class SearchPage<T> extends SearchDelegate<T?> {
  /// Set this to true to display the complete list instead of the [suggestion].
  /// This is useful to give your users the chance to explore all the items in the
  /// list without knowing what so search for.
  final bool showItemsOnEmpty;

  /// Widget that is built when current query is empty.
  /// Suggests the user what's possible to do.
  final Widget suggestion;

  /// Widget built when there's no item in [items] that
  /// matches current query.
  final Widget failure;

  final Widget searchHintWidget;

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
  final String? searchLabel;

  /// List of items where the search is going to take place on.
  /// They have [T] on run time.
  final List<T> items;

  /// Theme that would be used in the [AppBar] widget, inside
  /// the search view.
  final ThemeData? barTheme;

  /// Provided queries only matches with the begining of each
  /// string item's representation.
  final bool itemStartsWith;

  /// Provided queries only matches with the end of each
  /// string item's representation.
  final bool itemEndsWith;

  /// Functions that gets called when the screen performs a search operation.
  final void Function(String)? onQueryUpdate;

  /// The style of the [searchFieldLabel] text widget.
  final TextStyle? searchStyle;

  SearchPage({
    this.suggestion = const SizedBox(),
    this.failure = const SizedBox(),
    required this.builder,
    required this.filter,
    required this.items,
    this.searchHintWidget = const SizedBox(),
    this.showItemsOnEmpty = false,
    this.searchLabel,
    this.barTheme,
    this.itemStartsWith = false,
    this.itemEndsWith = false,
    this.onQueryUpdate,
    this.searchStyle,
  }) : super(
          searchFieldLabel: searchLabel,
          searchFieldStyle: searchStyle,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return barTheme ??
        Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
                headline6: TextStyle(
                  color: Theme.of(context).primaryTextTheme.headline6!.color,
                  fontSize: 20,
                ),
              ),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(
              color: Theme.of(context).primaryTextTheme.caption!.color,
              fontSize: 20,
            ),
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            border: InputBorder.none,
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
    // Calles the 'onQueryUpdated' functions at the start of the operation
    if (onQueryUpdate != null) onQueryUpdate!(query);

    // Deletes possible blank spaces & converts the string to lower case
    final String cleanQuery = query.toLowerCase().trim();

    // Using the [filter] method, filters through the [items] list
    // in order to select matching items
    final List<T> result = items
        .where(
          // First we collect all [String] representation of each [item]
          (item) => filter(item)
              // Then, transforms all results to lower case letters
              .map((value) => value?.toLowerCase().trim())
              // Finally, checks wheters any coincide with the cleaned query
              // Checks wheter the [startsWith] or [endsWith] are 'true'
              .any(
            (value) {
              if (itemStartsWith == true && itemEndsWith == true) {
                return value == cleanQuery;
              } else if (itemStartsWith == true) {
                return value?.startsWith(cleanQuery) == true;
              } else if (itemEndsWith == true) {
                return value?.endsWith(cleanQuery) == true;
              } else {
                return value?.contains(cleanQuery) == true;
              }
            },
          ),
        )
        .toList();

    // Builds a list with all filtered items
    // if query and result list are not empty
    return Theme(
      data: Theme.of(context),
      child: cleanQuery.isEmpty && !showItemsOnEmpty
          ? suggestion
          : result.isEmpty
              ? failure
              : searchHintWidget == const SizedBox()
                  ? ListView(children: result.map(builder).toList())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          searchHintWidget,
                          ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: result.map(builder).toList())
                        ],
                      ),
                    ),
    );
  }
}
