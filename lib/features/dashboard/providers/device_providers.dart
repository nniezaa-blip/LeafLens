import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lextari/features/auth/providers/auth_providers.dart';
import 'package:lextari/features/dashboard/data/device_api.dart';
import 'package:lextari/features/dashboard/domain/device_summary.dart';

final deviceApiProvider = Provider<DeviceApi>((ref) {
  return DeviceApi(ref.watch(apiClientProvider));
});

final deviceListProvider = FutureProvider<List<DeviceSummary>>((ref) async {
  final session = ref.watch(authSessionProvider).value;
  if (session == null) return const <DeviceSummary>[];
  return ref.watch(deviceApiProvider).listDevices();
});

final hasLinkedDeviceProvider = Provider<AsyncValue<bool>>((ref) {
  return ref
      .watch(deviceListProvider)
      .whenData((devices) => devices.isNotEmpty);
});
