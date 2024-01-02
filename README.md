# Search Page

[![Package](https://img.shields.io/pub/v/search_page.svg?style=for-the-badge)](https://pub.dartlang.org/packages/search_page)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg?style=for-the-badge)](https://pub.dev/packages/very_good_analysis)
[![Build](https://img.shields.io/github/actions/workflow/status/jesusrp98/search_page/flutter_package.yml?branch=master&style=for-the-badge)](https://github.com/jesusrp98/search_page/actions)
[![Patreon](https://img.shields.io/badge/Support-Patreon-orange.svg?style=for-the-badge)](https://www.patreon.com/jesusrp98)
[![License](https://img.shields.io/github/license/jesusrp98/search_page.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0.en.html)

Fast and easy way to build a custom search experience in you app.

This package aims to provide a simple way to build a search view, using available resources from the Flutter framework. It uses `SearchDelegate` as its fondation, in order to build a 'material'
experience.

One of the special features of this package is the `filter` parameter. It's a very simple way to filter out items inside a list, using different string representations.

Also, you can customize suggestion and on-error widgets, provide custom search filters, change AppBar's theme...

<p align="center">
  <img src="https://raw.githubusercontent.com/jesusrp98/search_page/master/screenshots/0.png" width="256" hspace="4">
  <img src="https://raw.githubusercontent.com/jesusrp98/search_page/master/screenshots/1.png" width="256" hspace="4">
  <img src="https://raw.githubusercontent.com/jesusrp98/search_page/master/screenshots/2.png" width="256" hspace="4">
</p>

## Example

Here is a example on how to use this package. You'd need to call the `SearchPage` class using the `showSearch` function built in.

If you want to take a deeper look at the example, take a look at the [example](https://github.com/jesusrp98/search_page/tree/master/example) folder provided with the project.

```
FloatingActionButton(
  child: Icon(Icons.search),
  tooltip: 'Search people',
  onPressed: () => showSearch(
    context: context,
    delegate: SearchPage<Person>(
      items: people,
      searchLabel: 'Search people',
      suggestion: Center(
        child: Text('Filter people by name, surname or age'),
      ),
      failure: Center(
        child: Text('No person found :('),
      ),
      filter: (person) => [
        person.name,
        person.surname,
        person.age.toString(),
      ],
      builder: (person) => ListTile(
        title: Text(person.name),
        subtitle: Text(person.surname),
        trailing: Text('${person.age} yo'),
      ),
    ),
  ),
),
```

## Getting Started

This project is a starting point for a Dart [package](https://flutter.io/developing-packages/), a library module containing code that can be shared easily across multiple Flutter or Dart projects.

For help getting started with Flutter, view our [online documentation](https://flutter.io/docs), which offers tutorials, samples, guidance on mobile development, and a full API reference.

## Built with

- [Flutter](https://flutter.dev/) - Beautiful native apps in record time.
- [Android Studio](https://developer.android.com/studio/index.html/) - Tools for building apps on every type of Android device.
- [Visual Studio Code](https://code.visualstudio.com/) - Code editing. Redefined.

## Authors

- **Jesús Rodríguez** - you can find me on [GitHub](https://github.com/jesusrp98), [Twitter](https://twitter.com/jesusrp98) & [Reddit](https://www.reddit.com/user/jesusrp98).

## License

This project is licensed under the GNU GPL v3 License - see the [LICENSE](LICENSE) file for details.
