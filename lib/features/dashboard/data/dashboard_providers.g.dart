// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [DashboardRepository] used for streaming and RPC calls.

@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider = DashboardRepositoryProvider._();

/// Provides the [DashboardRepository] used for streaming and RPC calls.

final class DashboardRepositoryProvider
    extends
        $FunctionalProvider<
          DashboardRepository,
          DashboardRepository,
          DashboardRepository
        >
    with $Provider<DashboardRepository> {
  /// Provides the [DashboardRepository] used for streaming and RPC calls.
  DashboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<DashboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardRepository create(Ref ref) {
    return dashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardRepository>(value),
    );
  }
}

String _$dashboardRepositoryHash() =>
    r'b57ac1694d73e47baefb3e5b145c06a055a41dcd';

/// Provides a live stream of typed [WsEvent]s from the WebSocket.

@ProviderFor(dashboardStream)
final dashboardStreamProvider = DashboardStreamProvider._();

/// Provides a live stream of typed [WsEvent]s from the WebSocket.

final class DashboardStreamProvider
    extends $FunctionalProvider<AsyncValue<WsEvent>, WsEvent, Stream<WsEvent>>
    with $FutureModifier<WsEvent>, $StreamProvider<WsEvent> {
  /// Provides a live stream of typed [WsEvent]s from the WebSocket.
  DashboardStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStreamHash();

  @$internal
  @override
  $StreamProviderElement<WsEvent> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<WsEvent> create(Ref ref) {
    return dashboardStream(ref);
  }
}

String _$dashboardStreamHash() => r'727443ed058e58e6656cce0683899f9c1ff19aaf';
