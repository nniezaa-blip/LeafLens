import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

/// Pushes [page] into the sheet [context] is a page of, or opens a sheet for
/// it anywhere else.
Future<T?> pushNestedPage<T>(BuildContext context, Widget page) {
  return showInSheet<T>(
    context,
    builder: (_) => page,
  );
}

/// Opens a sheet whose pages can push further pages inside it.
Future<T?> showNestedSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  List<double> detents = snapSheetDetents,
}) {
  if (isSheetPage(context)) {
    return Navigator.of(context).push(
      PagedSheetRoute<T>(builder: builder),
    );
  }
  return showSheet<T>(
    context: context,
    props: SheetProps(
      backgroundColor: nestedPagedSheetProps.backgroundColor,
      detents: detents,
    ),
    builder: (_) => NestedPagedSheet(builder: builder),
  );
}

/// Opens a full page from a sheet, or a sheet of pages elsewhere.
Future<T?> showNestedExtend<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  ExtendProps props = const ExtendProps(),
}) {
  if (isSheetPage(context)) {
    return Navigator.of(context).push(
      PagedSheetRoute<T>(builder: builder),
    );
  }
  if (context.isMobileView || props.forceFull) {
    return showExtend<T>(context, props: props, builder: builder);
  }
  return showExtend<T>(
    context,
    props: props,
    builder: (_) => NestedPagedSheet(builder: builder),
  );
}
