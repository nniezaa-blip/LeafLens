import 'package:lextari/core/network/api_client.dart';
import 'package:lextari/core/network/ws_client.dart';
import 'package:lextari/features/auth/data/auth_repository.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/dashboard/domain/dashboard_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

/// Manages the WebSocket connection lifecycle for dashboard streaming.
class DashboardRepository {
  /// Creates a [DashboardRepository] backed by the given
  /// [ApiClient] and [WsClient].
  DashboardRepository(this._api, this._ws);
  final ApiClient _api;
  final WsClient _ws;
  Stream<DashboardUpdate>? _stream;

  /// Connect to FastAPI WS and start receiving dashboard updates.
  Stream<DashboardUpdate> connect(String token) {
    if (_stream != null) return _stream!;
    _stream = _ws
        .connect(token)
        .where((raw) => raw['type'] is String)
        .map(DashboardUpdate.fromJson);

    return _stream!;
  }

  /// Send an RPC command to the backend (water, mist, refill).
  Future<void> sendRpc(String method) async {
    await _api.post('/api/rpc', body: {'method': method});
  }

  /// Fetch 30-day history for a sensor key.
  Future<Map<String, dynamic>> fetchHistory(String key, int days) async {
    return _api.get('/api/telemetry/$key', params: {'days': '$days'});
  }

  /// Dispose of the WebSocket connection and associated resources.
  void dispose() {
    _ws.dispose();
  }
}

// ── Providers ────────────────────────────────────────────

/// Provides the [DashboardRepository] used for streaming and RPC calls.
@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  final api = ref.read(apiClientProvider);
  return DashboardRepository(api, WsClient());
}

/// Provides a live stream of [DashboardUpdate] events from the WebSocket.
@riverpod
Stream<DashboardUpdate> dashboardStream(Ref ref) {
  final repo = ref.read(dashboardRepositoryProvider);
  final session = ref.watch(authSessionProvider).value;

  if (session == null) return const Stream.empty();

  return repo.connect(session.accessToken);
}
