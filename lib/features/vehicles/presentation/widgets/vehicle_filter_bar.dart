import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/vehicle_model.dart';
import '../vehicle_provider.dart';

/// Interactive search and filter control bar for Stark Group fleet management.
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
    ref.read(vehicleCompanyFilterProvider.notifier).state = null;
    ref.read(vehicleTypeFilterProvider.notifier).state = null;
    ref.read(vehicleStatusFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedCompany = ref.watch(vehicleCompanyFilterProvider);
    final selectedType = ref.watch(vehicleTypeFilterProvider);
    final selectedStatus = ref.watch(vehicleStatusFilterProvider);
    final searchQuery = ref.watch(vehicleSearchQueryProvider);
    final companies = ref.watch(availableCompaniesProvider);

    final hasActiveFilters = searchQuery.isNotEmpty ||
        selectedCompany != null ||
        selectedType != null ||
        selectedStatus != null;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Desktop / wide container layout (>= 860px)
        if (constraints.maxWidth >= 860) {
          return Row(
            children: [
              // Search input field
              Expanded(
                flex: 4,
                child: _buildSearchField(),
              ),
              const SizedBox(width: 12),

              // Company dropdown
              SizedBox(
                width: 190,
                child: _buildCompanyDropdown(companies, selectedCompany),
              ),
              const SizedBox(width: 12),

              // Type dropdown
              SizedBox(
                width: 170,
                child: _buildTypeDropdown(selectedType),
              ),
              const SizedBox(width: 12),

              // Status dropdown
              SizedBox(
                width: 160,
                child: _buildStatusDropdown(selectedStatus),
              ),

              // Reset CTA
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

        // Narrow / Tablet / Mobile stacked layout (< 860px)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchField(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompanyDropdown(companies, selectedCompany),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTypeDropdown(selectedType),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatusDropdown(selectedStatus),
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reset'),
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by vehicle number, brand, model, company...',
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

  Widget _buildCompanyDropdown(List<String> companies, String? selectedCompany) {
    return DropdownButtonFormField<String?>(
      value: selectedCompany,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Company',
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text(
            'All Companies',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...companies.map(
          (String comp) => DropdownMenuItem<String?>(
            value: comp,
            child: Text(
              comp,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: (String? value) {
        ref.read(vehicleCompanyFilterProvider.notifier).state = value;
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
                Icon(type.icon, size: 16, color: AppColors.starkOrange),
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
}
