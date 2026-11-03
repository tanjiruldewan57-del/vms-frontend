import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_vehicle_repository.dart';
import '../domain/vehicle_model.dart';

/// Aggregated fleet metrics for executive and operational oversight.
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

  /// Adds a new vehicle to the fleet.
  void addVehicle(VehicleModel vehicle) {
    final newId = vehicle.id.isEmpty
        ? 'v-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : vehicle.id;

    final newVehicle = vehicle.copyWith(id: newId);
    state = <VehicleModel>[newVehicle, ...state];
  }

  /// Updates an existing vehicle with new details.
  void updateVehicle(VehicleModel updated) {
    state = state.map((v) => v.id == updated.id ? updated : v).toList();
  }

  /// Removes a vehicle from the fleet inventory by ID.
  void deleteVehicle(String id) {
    state = state.where((v) => v.id != id).toList();
  }

  /// Restores initial mock data for testing.
  void resetToDefault() {
    state = List<VehicleModel>.from(MockVehicleRepository.initialVehicles);
  }
}

/// Global provider for the vehicle fleet state.
final vehicleListProvider =
    StateNotifierProvider<VehicleNotifier, List<VehicleModel>>((ref) {
  return VehicleNotifier();
});

/// Search query string provider.
final vehicleSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Filter provider by vehicle status (null represents 'All').
final vehicleStatusFilterProvider = StateProvider<VehicleStatus?>((ref) {
  return null;
});

/// Filter provider by vehicle type (null represents 'All').
final vehicleTypeFilterProvider = StateProvider<VehicleType?>((ref) {
  return null;
});

/// Filtered vehicle list computed from search query, status, and type filters.
final filteredVehiclesProvider = Provider<List<VehicleModel>>((ref) {
  final vehicles = ref.watch(vehicleListProvider);
  final query = ref.watch(vehicleSearchQueryProvider).toLowerCase().trim();
  final statusFilter = ref.watch(vehicleStatusFilterProvider);
  final typeFilter = ref.watch(vehicleTypeFilterProvider);

  return vehicles.where((v) {
    final matchesQuery = query.isEmpty ||
        v.licensePlate.toLowerCase().contains(query) ||
        v.make.toLowerCase().contains(query) ||
        v.model.toLowerCase().contains(query) ||
        v.vin.toLowerCase().contains(query) ||
        (v.assignedDriver?.toLowerCase().contains(query) ?? false);

    final matchesStatus = statusFilter == null || v.status == statusFilter;
    final matchesType = typeFilter == null || v.type == typeFilter;

    return matchesQuery && matchesStatus && matchesType;
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

