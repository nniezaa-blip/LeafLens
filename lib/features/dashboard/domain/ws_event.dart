import 'package:lextari/features/dashboard/domain/dashboard_update.dart';

sealed class WsEvent {
  const WsEvent();

  factory WsEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString();
    return switch (type) {
      'auth_ok' => const WsAuthOk(),
      'auth_error' => WsAuthError(json['message']?.toString() ?? 'Authentication failed'),
      'pong' => const WsPong(),
      'subscribed' => WsSubscribed(json['device_id']?.toString() ?? ''),
      'telemetry' || 'ghs' || 'water_system' || 'ack' => WsDashboardUpdate(DashboardUpdate.fromJson(json)),
      _ => WsUnknown(json),
    };
  }
}

class WsAuthOk extends WsEvent {
  const WsAuthOk();
}

class WsAuthError extends WsEvent {
  const WsAuthError(this.message);
  final String message;
}

class WsPong extends WsEvent {
  const WsPong();
}

class WsSubscribed extends WsEvent {
  const WsSubscribed(this.deviceId);
  final String deviceId;
}

class WsDashboardUpdate extends WsEvent {
  const WsDashboardUpdate(this.update);
  final DashboardUpdate update;
}

class WsUnknown extends WsEvent {
  const WsUnknown(this.raw);
  final Map<String, dynamic> raw;
}
