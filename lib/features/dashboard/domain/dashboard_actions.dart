import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/dashboard/domain/dashboard_action.dart';
import 'package:lextari/features/dashboard/domain/rpc_result.dart';
import 'package:lextari/features/dashboard/providers/dashboard_providers.dart';

final dashboardActionsProvider = Provider<DashboardActions>((ref) {
  return DashboardActions(ref);
});

class DashboardActions {
  DashboardActions(this._ref);
  final Ref _ref;

  Future<RpcResult> send(DashboardAction action) {
    return _ref.read(dashboardRepositoryProvider).sendRpc(action.rpcMethod);
  }

  Future<RpcResult> setMist(bool enabled) => send(enabled ? DashboardAction.mistOn : DashboardAction.mistOff);
  Future<RpcResult> setWater(bool enabled) => send(enabled ? DashboardAction.waterOn : DashboardAction.waterOff);
  Future<RpcResult> setRefill(bool enabled) => send(enabled ? DashboardAction.refillOn : DashboardAction.refillOff);
}
