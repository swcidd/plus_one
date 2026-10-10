import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_stats.dart';
import '../providers/workout_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/stat_tile.dart';
import 'navigation_shell.dart';

/// Who is training, what they have done, and the settings that change it.
///
/// The stats read from [ProfileStats] while the streak and consistency figures
/// read from [WorkoutProvider]. That split is deliberate: the profile block is
/// an account-level snapshot the API would own, whereas the streak is derived
/// from the sessions on this device and must agree with what the home screen
/// shows. Deriving it twice from different sources is how two screens end up
/// disagreeing about the same number.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onSelectTab});

  final ValueChanged<AppTab>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: const BrandAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Identity(profile: profile),
          const SizedBox(height: 24),
          Text('TRAINING', style: context.text.labelCaps),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatTile(
                    value: '${profile.totalWorkouts}',
                    label: 'Workouts',
                    icon: Icons.fitness_center_outlined,
                    emphasis: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    value: '${provider.streakDays}',
                    label: 'Day streak',
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatTile(
                    value: '${profile.badgeCount}',
                    label: 'Badges',
                    icon: Icons.workspace_premium_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    value: '${provider.consistencyPercent}%',
                    label: 'This month',
                    icon: Icons.insights_outlined,
                    caption:
                        '${provider.completedThisMonth} '
                        'of ${provider.workoutsThisMonth}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('SETTINGS', style: context.text.labelCaps),
          const SizedBox(height: 8),
          _SettingsGroup(
            children: [
              _SettingsRow(
                icon: Icons.flag_outlined,
                title: 'Weekly goal',
                value: '${provider.weeklyGoal} sessions',
                onTap: () => _editWeeklyGoal(context, provider),
              ),
              _SettingsRow(
                icon: Icons.monitor_weight_outlined,
                title: 'Body weight',
                value: '${profile.weightKg.toStringAsFixed(1)} kg',
                onTap: () => _editBodyWeight(context, provider, profile),
              ),
              _SettingsRow(
                icon: Icons.straighten_outlined,
                title: 'Height',
                value: '${profile.heightCm.round()} cm',
              ),
              _SettingsRow(
                icon: Icons.favorite_outline_rounded,
                title: 'Resting heart rate',
                value: '${profile.restingHrBpm} bpm',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('PERSONAL RECORDS', style: context.text.labelCaps),
          const SizedBox(height: 8),
          _SettingsGroup(
            children: [
              for (final record in profile.records) _RecordRow(record: record),
            ],
          ),
          const SizedBox(height: 24),
          Text('BADGES', style: context.text.labelCaps),
          const SizedBox(height: 8),
          _BadgeGrid(achievements: profile.achievements),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Text('+1 PLUS ONE', style: context.text.labelCaps),
                const SizedBox(height: 4),
                Text(
                  'Member since ${profile.memberSince}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  profile.isPro ? 'Pro plan' : 'Free plan',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editWeeklyGoal(
    BuildContext context,
    WorkoutProvider provider,
  ) async {
    final controller = TextEditingController(text: '${provider.weeklyGoal}');

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Weekly session goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Sessions per week',
            helperText: 'Between 1 and 14.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    // A null result means cancelled, and the provider's own bounds check
    // rejects an out-of-range value, so a bad number simply leaves the goal
    // unchanged instead of writing a nonsense target.
    if (result != null) provider.setWeeklyGoal(result);
  }

  Future<void> _editBodyWeight(
    BuildContext context,
    WorkoutProvider provider,
    ProfileStats profile,
  ) async {
    final controller = TextEditingController(
      text: profile.weightKg.toStringAsFixed(1),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Body weight'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight in kilograms'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(double.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result == null || result <= 0) return;
    provider.updateProfile(profile.copyWith(weightKg: result));
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final ProfileStats profile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            _initialsOf(profile.name),
            style: textTheme.titleLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(profile.handle, style: context.text.labelCaps),
              const SizedBox(height: 2),
              Text(
                '${profile.role} · member since ${profile.memberSince}',
                style: textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final words = parts.toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words.last.substring(0, 1))
        .toUpperCase();
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          // The chevron only appears when the row is actually editable, so a
          // read-only figure never looks tappable and then does nothing.
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, size: 18, color: scheme.outline),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});

  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: AppRadius.tag,
            ),
            child: Text(
              record.id,
              style: context.text.labelCaps.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  record.protocol,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(record.value, style: context.text.metric.copyWith(fontSize: 18)),
          const SizedBox(width: 4),
          Text(record.unit, style: context.text.labelCaps),
        ],
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.achievements});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final badge in achievements)
          Container(
            width: (MediaQuery.sizeOf(context).width - 32 - 10) / 2,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: AppRadius.card,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  badge.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(badge.subtitle, style: context.text.labelCaps),
                const SizedBox(height: 2),
                Text(
                  badge.detail,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
