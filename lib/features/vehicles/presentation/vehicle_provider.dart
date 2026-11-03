import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_vehicle_repository.dart';
import '../domain/vehicle_model.dart';

/// Aggregated fleet metrics for Stark Group logistics operations.
class VehicleFleetStats {
  final int total;
  final int active;
  final int maintenance;
  final int outOfService;

  const VehicleFleetStats({
    required this.total,
    required this.active,
    required this.maintenance,
    required this.outOfService,
  });
}

/// State notifier managing the in-memory vehicle fleet collection.
class VehicleNotifier extends StateNotifier<List<VehicleModel>> {
  VehicleNotifier() : super(List<VehicleModel>.from(MockVehicleRepository.initialVehicles));

  /// Registers a new vehicle in the fleet inventory.
  void addVehicle(VehicleModel vehicle) {
    final newId = vehicle.id.isEmpty
        ? 'stk-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : vehicle.id;

    final newVehicle = vehicle.copyWith(id: newId);
    state = <VehicleModel>[newVehicle, ...state];
  }

  /// Updates an existing fleet asset.
  void updateVehicle(VehicleModel updated) {
    state = state.map((v) => v.id == updated.id ? updated : v).toList();
  }

  /// Removes a vehicle from the fleet inventory by ID.
  void deleteVehicle(String id) {
    state = state.where((v) => v.id != id).toList();
  }

  /// Restores default mock data for evaluation.
  void resetToDefault() {
    state = List<VehicleModel>.from(MockVehicleRepository.initialVehicles);
  }
}

/// Global provider for the fleet inventory state.
final vehicleListProvider =
    StateNotifierProvider<VehicleNotifier, List<VehicleModel>>((ref) {
  return VehicleNotifier();
});

/// Search query string provider.
final vehicleSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Filter provider for Operating Company (null represents 'All Companies').
final vehicleCompanyFilterProvider = StateProvider<String?>((ref) {
  return null;
});

/// Filter provider by vehicle status (null represents 'All Statuses').
final vehicleStatusFilterProvider = StateProvider<VehicleStatus?>((ref) {
  return null;
});

/// Filter provider by vehicle type (null represents 'All Types').
final vehicleTypeFilterProvider = StateProvider<VehicleType?>((ref) {
  return null;
});

/// Filtered vehicle list computed from search query, company, type, and status filters.
final filteredVehiclesProvider = Provider<List<VehicleModel>>((ref) {
  final vehicles = ref.watch(vehicleListProvider);
  final query = ref.watch(vehicleSearchQueryProvider).toLowerCase().trim();
  final companyFilter = ref.watch(vehicleCompanyFilterProvider);
  final statusFilter = ref.watch(vehicleStatusFilterProvider);
  final typeFilter = ref.watch(vehicleTypeFilterProvider);

  return vehicles.where((VehicleModel v) {
    final matchesQuery = query.isEmpty ||
        v.vehicleNumber.toLowerCase().contains(query) ||
        v.company.toLowerCase().contains(query) ||
        v.brand.toLowerCase().contains(query) ||
        v.model.toLowerCase().contains(query);

    final matchesCompany = companyFilter == null || v.company == companyFilter;
    final matchesStatus = statusFilter == null || v.status == statusFilter;
    final matchesType = typeFilter == null || v.type == typeFilter;

    return matchesQuery && matchesCompany && matchesStatus && matchesType;
  }).toList();
});

/// Computed statistics summarizing the fleet distribution.
final vehicleStatsProvider = Provider<VehicleFleetStats>((ref) {
  final vehicles = ref.watch(vehicleListProvider);

  int activeCount = 0;
  int maintenanceCount = 0;
  int outOfServiceCount = 0;

  for (final v in vehicles) {
    switch (v.status) {
      case VehicleStatus.active:
        activeCount++;
        break;
      case VehicleStatus.maintenance:
        maintenanceCount++;
        break;
      case VehicleStatus.outOfService:
        outOfServiceCount++;
        break;
    }
  }

  return VehicleFleetStats(
    total: vehicles.length,
    active: activeCount,
    maintenance: maintenanceCount,
    outOfService: outOfServiceCount,
  );
});

/// Provides the list of unique operating companies present in the fleet.
final availableCompaniesProvider = Provider<List<String>>((ref) {
  final vehicles = ref.watch(vehicleListProvider);
  final set = <String>{...MockVehicleRepository.companies};
  for (final v in vehicles) {
    set.add(v.company);
  }
  final list = set.toList();
  list.sort();
  return list;
});
