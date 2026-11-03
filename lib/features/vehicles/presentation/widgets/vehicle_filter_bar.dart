import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/vehicle_model.dart';
import '../vehicle_provider.dart';

/// Interactive search and filter control bar for fleet management.
/// Designed with adaptive flex bounds and text overflow guards.
class VehicleFilterBar extends ConsumerStatefulWidget {
  const VehicleFilterBar({super.key});

  @override
  ConsumerState<VehicleFilterBar> createState() => _VehicleFilterBarState();
}

class _VehicleFilterBarState extends ConsumerState<VehicleFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    ref.read(vehicleSearchQueryProvider.notifier).state = '';
    ref.read(vehicleStatusFilterProvider.notifier).state = null;
    ref.read(vehicleTypeFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedStatus = ref.watch(vehicleStatusFilterProvider);
    final selectedType = ref.watch(vehicleTypeFilterProvider);
    final searchQuery = ref.watch(vehicleSearchQueryProvider);

    final hasActiveFilters = searchQuery.isNotEmpty ||
        selectedStatus != null ||
        selectedType != null;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Desktop / wide container layout (>= 740px available width)
        if (constraints.maxWidth >= 740) {
          return Row(
            children: [
              // Search input field
              Expanded(
                flex: 4,
                child: _buildSearchField(theme, isDark),
              ),
              const SizedBox(width: 12),

              // Status filter dropdown
              SizedBox(
                width: 175,
                child: _buildStatusDropdown(selectedStatus),
              ),
              const SizedBox(width: 12),

              // Type filter dropdown
              SizedBox(
                width: 155,
                child: _buildTypeDropdown(selectedType),
              ),

              // Reset button
              if (hasActiveFilters) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  onPressed: _resetFilters,
                ),
              ],
            ],
          );
        }

        // Narrow / Tablet / Mobile stacked layout (< 740px available width)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField(theme, isDark),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusDropdown(selectedStatus),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTypeDropdown(selectedType),
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Reset Filters',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _resetFilters,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search plate, make, model, VIN, driver...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  ref.read(vehicleSearchQueryProvider.notifier).state = '';
                },
              )
            : null,
      ),
      onChanged: (String value) {
        ref.read(vehicleSearchQueryProvider.notifier).state = value;
      },
    );
  }

  Widget _buildStatusDropdown(VehicleStatus? selectedStatus) {
    return DropdownButtonFormField<VehicleStatus?>(
      value: selectedStatus,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Status',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        const DropdownMenuItem<VehicleStatus?>(
          value: null,
          child: Text(
            'All Statuses',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...VehicleStatus.values.map(
          (VehicleStatus status) => DropdownMenuItem<VehicleStatus?>(
            value: status,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: status.foregroundColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      onChanged: (VehicleStatus? value) {
        ref.read(vehicleStatusFilterProvider.notifier).state = value;
      },
    );
  }

  Widget _buildTypeDropdown(VehicleType? selectedType) {
    return DropdownButtonFormField<VehicleType?>(
      value: selectedType,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Type',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        const DropdownMenuItem<VehicleType?>(
          value: null,
          child: Text(
            'All Types',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...VehicleType.values.map(
          (VehicleType type) => DropdownMenuItem<VehicleType?>(
            value: type,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(type.icon, size: 16, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      onChanged: (VehicleType? value) {
        ref.read(vehicleTypeFilterProvider.notifier).state = value;
      },
    );
  }
}
