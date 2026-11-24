import 'package:flutter/widgets.dart';

/// The text the components of this package show of their own. The app loads it
/// from its ARB strings through a delegate it registers on the app.
abstract class UiLocalizations {
  static UiLocalizations of(BuildContext context) {
    final localizations = Localizations.of<UiLocalizations>(
      context,
      UiLocalizations,
    );
    assert(
      localizations != null,
      'No UiLocalizations found. Add the app delegate to localizationsDelegates.',
    );
    return localizations!;
  }

  String get back;

  String get cancel;

  String get clearSearch;

  String get close;

  String get copy;

  String get cut;

  String get dialog;

  String get hidePassword;

  String get more;

  String get noSearchResults;

  String get paste;

  String get reset;

  String get select;

  String get search;

  String get selectAll;

  String get showLess;

  String get showMore;

  String get showPassword;

  String get sort;

  String get submit;
}


class DefaultUiLocalizations implements UiLocalizations {
  const DefaultUiLocalizations();

  static const LocalizationsDelegate<UiLocalizations> delegate = _DefaultUiLocalizationsDelegate();

  @override String get back => 'Back';
  @override String get cancel => 'Cancel';
  @override String get clearSearch => 'Clear search';
  @override String get close => 'Close';
  @override String get copy => 'Copy';
  @override String get cut => 'Cut';
  @override String get dialog => 'Dialog';
  @override String get hidePassword => 'Hide password';
  @override String get more => 'More';
  @override String get noSearchResults => 'No search results';
  @override String get paste => 'Paste';
  @override String get reset => 'Reset';
  @override String get select => 'Select';
  @override String get search => 'Search';
  @override String get selectAll => 'Select all';
  @override String get showLess => 'Show less';
  @override String get showMore => 'Show more';
  @override String get showPassword => 'Show password';
  @override String get sort => 'Sort';
  @override String get submit => 'Submit';
}

class _DefaultUiLocalizationsDelegate extends LocalizationsDelegate<UiLocalizations> {
  const _DefaultUiLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<UiLocalizations> load(Locale locale) async => const DefaultUiLocalizations();

  @override
  bool shouldReload(_DefaultUiLocalizationsDelegate old) => false;
}
