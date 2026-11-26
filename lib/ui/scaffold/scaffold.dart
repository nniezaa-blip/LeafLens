import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// A removable filter chip shown under a page bar.
class ScaffoldKeyword {
  /// Creates a [ScaffoldKeyword].
  const ScaffoldKeyword({
    required this.key,
    required this.label,
    this.onDeleted,
    this.onPressed,
    this.selected = false,
  });

  /// Stable identity for the keyword.
  final Object key;

  /// Visible label.
  final String label;

  /// Removes the keyword when set.
  final VoidCallback? onDeleted;

  /// Selects the keyword when set.
  final VoidCallback? onPressed;

  /// Whether the keyword is selected.
  final bool selected;
}

/// The state of a page's search field.
class AppBarSearchState {
  /// Creates an [AppBarSearchState].
  const AppBarSearchState({required this.onSearch, this.query});

  /// Called with the current query as it changes.
  final ValueChanged<String> onSearch;

  /// Initial query, when the page restores one.
  final String? query;

  /// Returns a copy with a different [query].
  AppBarSearchState withQuery(String? query) {
    return AppBarSearchState(onSearch: onSearch, query: query);
  }
}

/// A page layout with a floating bar, loading line, actions and search.
///
/// The API mirrors FlClash's scaffold: a page supplies its content and the
/// state of its bar instead of building a bar by hand.
class Scaffold extends StatefulWidget {
  /// Creates a [Scaffold].
  const Scaffold({
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.statusActions = const <Widget>[],
    this.primaryAction,
    this.iconActions = const <IconButtonData>[],
    this.menuItems = const <PopupMenuItem>[],
    this.selectionActions = const <IconButtonData>[],
    this.keywords,
    this.isLoading = false,
    this.backAction,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.searchState,
    super.key,
  });

  /// Page content.
  final Widget body;

  /// Plain title text.
  final String? title;

  /// Rich title, used instead of [title] when set.
  final Widget? titleWidget;

  /// Widgets placed at the end of the bar.
  final List<Widget>? actions;

  /// Status widgets placed before the bar buttons.
  final List<Widget> statusActions;

  /// A primary action, folded into the overflow when space runs out.
  final IconButtonData? primaryAction;

  /// Secondary bar actions, folded into the overflow when space runs out.
  final List<IconButtonData> iconActions;

  /// Items opened by the overflow button.
  final List<PopupMenuItem> menuItems;

  /// Actions shown while a selection is active.
  final List<IconButtonData> selectionActions;

  /// Filter chips shown under the bar.
  final ValueListenable<List<ScaffoldKeyword>>? keywords;

  /// Whether the loading line under the bar is active.
  final bool isLoading;

  /// Overrides the default back action.
  final VoidCallback? backAction;

  /// Page background colour.
  final Color? backgroundColor;

  /// Whether the body resizes when the keyboard appears.
  final bool? resizeToAvoidBottomInset;

  /// Enables the search button and field when set.
  final AppBarSearchState? searchState;

  @override
  State<Scaffold> createState() => _ScaffoldState();
}

class _ScaffoldState extends State<Scaffold> {
  final ValueNotifier<int> _barRefresh = ValueNotifier<int>(0);
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loading.value = widget.isLoading;
  }

  @override
  void didUpdateWidget(covariant Scaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      _loading.value = widget.isLoading;
    }
    if (oldWidget.searchState == null && widget.searchState == null) {
      return;
    }
    if (widget.searchState == null && _searching) {
      _closeSearch();
    }
  }

  @override
  void dispose() {
    _barRefresh.dispose();
    _loading.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _refreshBar() {
    _barRefresh.value++;
  }

  void _openSearch() {
    setState(() => _searching = true);
    _refreshBar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    widget.searchState?.onSearch('');
    setState(() => _searching = false);
    _refreshBar();
  }

  @override
  Widget build(BuildContext context) {
    final compact = isCompactBar(context, ViewScope.isMobileOf(context));
    final bar = ScaffoldBar(
      isCompact: compact,
      listenable: _barRefresh,
      loading: _loading,
      backgroundColor: widget.backgroundColor,
      builder: _buildBar,
    );
    return PrismScaffold(
      bar: bar,
      body: widget.body,
      headerListenable: _barRefresh,
      headerBuilder: _buildHeader,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
    );
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (_searching) {
      return AppBarActionButton(
        data: IconButtonData(
          glyph: Glyphs.close,
          tooltip: 'Cancel search',
          onPressed: _closeSearch,
        ),
      );
    }
    final backAction = widget.backAction;
    if (backAction != null) {
      return _buildBackButton(context, backAction);
    }
    if (Navigator.of(context).canPop()) {
      return _buildBackButton(context, () => Navigator.of(context).maybePop());
    }
    return null;
  }

  Widget _buildBackButton(BuildContext context, VoidCallback onPressed) {
    return AppBarActionButton(
      data: IconButtonData(
        glyph: Glyphs.backFor(Theme.of(context).platform),
        tooltip: 'Back',
        onPressed: onPressed,
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (_searching) {
      return TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        autofocus: true,
        onChanged: widget.searchState?.onSearch,
        decoration: const InputDecoration(hintText: 'Search'),
      );
    }
    final titleWidget = widget.titleWidget;
    if (titleWidget != null) return titleWidget;
    final title = widget.title;
    if (title == null) return null;
    return Text(title);
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[
      ...widget.statusActions,
      ...widget.selectionActions.map(_buildActionButton),
    ];
    final primaryAction = widget.primaryAction;
    if (primaryAction != null) {
      actions.add(_buildActionButton(primaryAction));
    }
    for (final action in widget.iconActions) {
      actions.add(_buildActionButton(action));
    }
    if (widget.menuItems.isNotEmpty) {
      actions.add(
        AppBarActionButton(
          data: IconButtonData(
            glyph: Glyphs.more,
            tooltip: 'More',
            onPressed: null,
            menuItems: () => widget.menuItems,
          ),
        ),
      );
    }
    if (widget.searchState != null && !_searching) {
      actions.add(
        AppBarActionButton(
          data: IconButtonData(
            glyph: Glyphs.search,
            tooltip: 'Search',
            onPressed: _openSearch,
          ),
        ),
      );
    }
    final extraActions = widget.actions;
    if (extraActions != null) actions.addAll(extraActions);
    return actions;
  }

  Widget _buildActionButton(IconButtonData data) {
    return AppBarActionButton(data: data);
  }

  Widget? _buildHeader(BuildContext context) {
    final keywords = widget.keywords;
    if (keywords == null) return null;
    return ValueListenableBuilder<List<ScaffoldKeyword>>(
      valueListenable: keywords,
      builder: (context, values, _) => _buildKeywordRow(values),
    );
  }

  Widget _buildKeywordRow(List<ScaffoldKeyword> keywords) {
    if (keywords.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final keyword in keywords)
            Chip(
              label: keyword.label,
              selected: keyword.selected,
              onPressed: keyword.onPressed,
              onDeleted: keyword.onDeleted,
            ),
        ],
      ),
    );
  }
}
