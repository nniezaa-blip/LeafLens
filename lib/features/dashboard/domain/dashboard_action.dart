enum DashboardAction {
  mistOn('mist_on'),
  mistOff('mist_off'),
  waterOn('water_on'),
  waterOff('water_off'),
  refillOn('refill_on'),
  refillOff('refill_off');

  const DashboardAction(this.rpcMethod);
  final String rpcMethod;
}
