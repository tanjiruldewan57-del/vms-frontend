import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/vehicle_model.dart';
import '../vehicle_provider.dart';

/// Desktop-first Material 3 data table and responsive list for fleet vehicles.
class VehicleTable extends ConsumerWidget {
  final List<VehicleModel> vehicles;

  const VehicleTable({
    super.key,
    required this.vehicles,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vehicles.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return _buildDesktopTable(context, ref);
    }

    return _buildMobileCardList(context, ref);
  }

  Widget _buildDesktopTable(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1000),
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 20,
              headingRowHeight: 52,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 64,
              columns: const <DataColumn>[
                DataColumn(label: Text('LICENSE PLATE')),
                DataColumn(label: Text('VEHICLE')),
                DataColumn(label: Text('VIN')),
                DataColumn(label: Text('TYPE')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ASSIGNED DRIVER')),
                DataColumn(label: Text('MILEAGE')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: vehicles.map((VehicleModel vehicle) {
                return DataRow(
                  cells: <DataCell>[
                    // License Plate
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF131D31)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          vehicle.licensePlate,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    // Vehicle Make & Model
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            vehicle.fuelType,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // VIN
                    DataCell(
                      Text(
                        vehicle.vin,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),

                    // Type
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            vehicle.type.icon,
                            size: 16,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(vehicle.type.label),
                        ],
                      ),
                    ),

                    // Status
                    DataCell(StatusBadge(status: vehicle.status)),

                    // Driver
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vehicle.assignedDriver ?? 'Unassigned',
                            style: TextStyle(
                              fontStyle: vehicle.assignedDriver == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: vehicle.assignedDriver == null
                                  ? (isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mileage
                    DataCell(
                      Text(
                        vehicle.formattedMileage,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),

                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit Vehicle',
                            onPressed: () => context.go('/vehicles/${vehicle.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.statusOutOfService,
                            ),
                            tooltip: 'Delete Vehicle',
                            onPressed: () => _confirmDelete(context, ref, vehicle),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCardList(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final vehicle = vehicles[index];
        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vehicle.licensePlate,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  StatusBadge(status: vehicle.status, compact: true),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'VIN: ${vehicle.vin} • ${vehicle.formattedMileage}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Driver: ${vehicle.assignedDriver ?? "Unassigned"}',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    onPressed: () => context.go('/vehicles/${vehicle.id}/edit'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusOutOfService),
                    onPressed: () => _confirmDelete(context, ref, vehicle),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 40,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Vehicles Match Your Search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search query, status filters, or register a new vehicle.',
              style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Clear Filters'),
                  onPressed: () {
                    ref.read(vehicleSearchQueryProvider.notifier).state = '';
                    ref.read(vehicleStatusFilterProvider.notifier).state = null;
                    ref.read(vehicleTypeFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 12),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, VehicleModel vehicle) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to remove vehicle "${vehicle.displayName}" (${vehicle.licensePlate}) from the fleet inventory?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.statusOutOfService,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(vehicleListProvider.notifier).deleteVehicle(vehicle.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vehicle ${vehicle.licensePlate} was deleted.'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ref.read(vehicleListProvider.notifier).addVehicle(vehicle);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
