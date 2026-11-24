import 'package:lextari/core/network/api_client.dart';
import 'package:lextari/core/network/api_endpoints.dart';
import 'package:lextari/core/network/ws_client.dart';
import 'package:lextari/features/auth/data/auth_repository.dart';
import 'package:lextari/features/auth/data/auth_session_manager.dart';
import 'package:lextari/features/auth/domain/auth_session.dart';
import 'package:lextari/features/dashboard/domain/rpc_result.dart';
import 'package:lextari/features/dashboard/domain/ws_event.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'dashboard_providers.g.dart';

/// Manages the WebSocket connection lifecycle for dashboard streaming.
class DashboardRepository {
  /// Creates a [DashboardRepository] backed by the given
  /// [ApiClient] and [WsClient].
  DashboardRepository(this._api, this._ws);
  final ApiClient _api;
  final WsClient _ws;

  /// Connect to FastAPI WS and start receiving dashboard updates.
  Stream<WsEvent> connect(String token) {
    return _ws
        .connect(token)
        .where((raw) => raw['type'] is String)
        .map(WsEvent.fromJson);
  }

  /// Send an RPC command to the backend (water, mist, refill).
  Future<RpcResult> sendRpc(String method) async {
    final response = await _api.post(ApiEndpoints.rpc, body: {'method': method});
    return RpcResult.fromJson(response);
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

/// Provides a live stream of typed [WsEvent]s from the WebSocket.
@riverpod
Stream<WsEvent> dashboardStream(Ref ref) {
  final repo = ref.read(dashboardRepositoryProvider);
  final session = ref.watch<AsyncValue<AuthSession?>>(authSessionProvider).value;
  if (session == null) return const Stream.empty();
  return repo.connect(session.accessToken);
}
