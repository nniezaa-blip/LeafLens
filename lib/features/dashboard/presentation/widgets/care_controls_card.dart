import 'package:lextari/features/dashboard/presentation/widgets/action_switch.dart';
import 'package:lextari/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:lextari/ui/ui.dart';

/// The dashboard's care control row.
class CareControlsCard extends StatelessWidget {
  /// Creates a [CareControlsCard].
  const CareControlsCard({
    required this.mistOn,
    required this.waterOn,
    required this.refillOn,
    required this.onMistChanged,
    required this.onWaterChanged,
    required this.onRefillChanged,
    super.key,
  });

  final bool mistOn;
  final bool waterOn;
  final bool refillOn;
  final ValueChanged<bool> onMistChanged;
  final ValueChanged<bool> onWaterChanged;
  final ValueChanged<bool> onRefillChanged;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DashboardCardHeader(
            glyph: AppGlyphs.tune,
            title: 'Care controls',
            trailing: [
              DashboardChip(label: 'Tap to toggle'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ActionSwitch(
                  icon: AppGlyphs.mist,
                  label: 'Mist',
                  value: mistOn,
                  onChanged: onMistChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionSwitch(
                  icon: AppGlyphs.waterDrop,
                  label: 'Water',
                  value: waterOn,
                  onChanged: onWaterChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ActionSwitch(
                  icon: AppGlyphs.refill,
                  label: 'Refill',
                  value: refillOn,
                  onChanged: onRefillChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
