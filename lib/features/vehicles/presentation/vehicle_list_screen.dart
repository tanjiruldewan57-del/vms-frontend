import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/stat_summary_card.dart';
import 'vehicle_provider.dart';
import 'widgets/vehicle_filter_bar.dart';
import 'widgets/vehicle_table.dart';

/// Main Dashboard and Fleet Inventory screen.
class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final stats = ref.watch(vehicleStatsProvider);
    final filteredVehicles = ref.watch(filteredVehiclesProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header with Title and Primary Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fleet Overview',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track, audit, and configure vehicle specifications across enterprise logistics.',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Register Vehicle'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () => context.go(AppConstants.routeVehicleCreate),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metric Summary Cards Row
            _buildMetricsGrid(context, stats, isDesktop),
            const SizedBox(height: 24),

            // Search and Filter Controls
            const VehicleFilterBar(),
            const SizedBox(height: 16),

            // Vehicle Table or Responsive Cards
            VehicleTable(vehicles: filteredVehicles),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    VehicleFleetStats stats,
    bool isDesktop,
  ) {
    final cards = <Widget>[
      StatSummaryCard(
        title: 'Total Fleet',
        value: stats.total.toString(),
        subtitle: 'All tracked assets',
        icon: Icons.directions_car_rounded,
        accentColor: AppColors.primaryLight,
      ),
      StatSummaryCard(
        title: 'Active Fleet',
        value: stats.active.toString(),
        subtitle: '${_calculatePercentage(stats.active, stats.total)}% operational',
        icon: Icons.check_circle_outline_rounded,
        accentColor: AppColors.statusActive,
      ),
      StatSummaryCard(
        title: 'In Maintenance',
        value: stats.maintenance.toString(),
        subtitle: 'Scheduled services',
        icon: Icons.build_circle_outlined,
        accentColor: AppColors.statusMaintenance,
      ),
      StatSummaryCard(
        title: 'Out of Service',
        value: stats.outOfService.toString(),
        subtitle: 'Awaiting repair/inspection',
        icon: Icons.warning_amber_rounded,
        accentColor: AppColors.statusOutOfService,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    // Tablet & Mobile 2x2 or column wrap
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final crossAxisCount = constraints.maxWidth > 550 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 2 ? 2.4 : 3.0,
          children: cards,
        );
      },
    );
  }

  String _calculatePercentage(int count, int total) {
    if (total == 0) return '0';
    return ((count / total) * 100).toStringAsFixed(0);
  }
}

