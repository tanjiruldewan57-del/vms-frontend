import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/stat_summary_card.dart';
import 'vehicle_provider.dart';
import 'widgets/vehicle_filter_bar.dart';
import 'widgets/vehicle_table.dart';

/// Main Dashboard and Fleet Inventory screen with Spring Boot REST integration.
/// Displays explicit Loading, Empty, Success, and Error states.
class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final vehicleState = ref.watch(vehicleListProvider);
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.starkOrange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.starkOrange.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'SPRING BOOT REST API // CONNECTED',
                              style: TextStyle(
                                color: AppColors.starkOrangeLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Fleet Inventory',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live vehicle data managed by Java Spring Boot backend service.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(width: 16),
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

            // Metric Summary Cards
            _buildMetricsGrid(context, stats),
            const SizedBox(height: 24),

            // Search and Filter Controls
            const VehicleFilterBar(),
            const SizedBox(height: 16),

            // Dynamic State Rendering: Loading, Error, Empty, Success
            if (vehicleState.isLoading)
              _buildLoadingState(theme, isDark)
            else if (vehicleState.isError)
              _buildErrorState(context, ref, vehicleState.errorMessage, vehicleState.errorDetails)
            else if (vehicleState.isEmpty || filteredVehicles.isEmpty)
              _buildEmptyState(context, ref)
            else
              VehicleTable(vehicles: filteredVehicles),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.starkOrange,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fetching Fleet Inventory...',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'Synchronizing with Spring Boot service at /api/v1/vehicles',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String? message,
    String? errorDetails,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.statusOutOfService.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 40,
                  color: AppColors.statusOutOfService,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Spring Boot Connection Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? 'Failed to communicate with the Spring Boot REST API.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              if (errorDetails != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Details: $errorDetails',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry Connection'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.starkOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                ),
                onPressed: () {
                  ref.read(vehicleListProvider.notifier).loadVehicles();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.starkOrange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 40,
                color: AppColors.starkOrange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Fleet Vehicles Found',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The Spring Boot database returned no vehicles matching your filter criteria.',
              style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset All Filters'),
                  onPressed: () {
                    ref.read(vehicleSearchQueryProvider.notifier).state = '';
                    ref.read(vehicleCompanyFilterProvider.notifier).state = null;
                    ref.read(vehicleTypeFilterProvider.notifier).state = null;
                    ref.read(vehicleStatusFilterProvider.notifier).state = null;
                    ref.read(vehicleListProvider.notifier).loadVehicles();
                  },
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Register Vehicle'),
                  onPressed: () => context.go(AppConstants.routeVehicleCreate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    VehicleFleetStats stats,
  ) {
    final cards = <Widget>[
      StatSummaryCard(
        title: 'Total Fleet Assets',
        value: stats.total.toString(),
        subtitle: 'All tracked vehicles',
        icon: Icons.local_shipping_rounded,
        accentColor: AppColors.starkOrangeLight,
      ),
      StatSummaryCard(
        title: 'Available',
        value: stats.available.toString(),
        subtitle: 'Ready for assignment',
        icon: Icons.check_circle_outline_rounded,
        accentColor: AppColors.statusActive,
      ),
      StatSummaryCard(
        title: 'In Use',
        value: stats.inUse.toString(),
        subtitle: 'On active delivery route',
        icon: Icons.alt_route_rounded,
        accentColor: AppColors.starkOrange,
      ),
      StatSummaryCard(
        title: 'Under Maintenance',
        value: stats.maintenance.toString(),
        subtitle: 'Workshop inspection',
        icon: Icons.build_circle_outlined,
        accentColor: AppColors.statusMaintenance,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Wide desktop container (>= 1080px): 4 cards in single row
        if (constraints.maxWidth >= 1080) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        // Intermediate width (580px - 1079px): 2x2 grid
        if (constraints.maxWidth >= 580) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: cards,
          );
        }

        // Narrow width (< 580px): vertical stacked list
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) => cards[index],
        );
      },
    );
  }
}
