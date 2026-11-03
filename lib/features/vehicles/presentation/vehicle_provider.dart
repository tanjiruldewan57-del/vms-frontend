import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../data/mock_vehicle_repository.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle_model.dart';
import 'vehicle_state.dart';

/// Aggregated fleet metrics for Stark Group logistics operations.
class VehicleFleetStats {
  final int total;
  final int available;
  final int inUse;
  final int maintenance;
  final int decommissioned;

  const VehicleFleetStats({
    required this.total,
    required this.available,
    required this.inUse,
    required this.maintenance,
    required this.decommissioned,
  });
}

/// State notifier managing the Spring Boot vehicle collection lifecycle and mutations.
class VehicleListNotifier extends StateNotifier<VehicleListState> {
  final VehicleRepository _repository;

  VehicleListNotifier(this._repository) : super(VehicleListState.initial()) {
    loadVehicles();
  }

  /// Loads fleet vehicles from the Spring Boot REST API.
  Future<void> loadVehicles({
    String? search,
    String? company,
    VehicleStatus? status,
  }) async {
    state = state.copyWith(
      status: VehicleListStatus.loading,
      clearError: true,
    );

    try {
      final page = await _repository.fetchVehicles(
        search: search,
        company: company,
        status: status,
        size: 100,
      );

      state = state.copyWith(
        status: VehicleListStatus.success,
        vehicles: page.content,
        totalElements: page.totalElements,
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: VehicleListStatus.error,
        errorMessage: e.message,
        errorDetails: e.error,
      );
    } catch (e) {
      state = state.copyWith(
        status: VehicleListStatus.error,
        errorMessage: 'An unexpected error occurred while loading vehicles: $e',
      );
    }
  }

  /// Creates a new vehicle asset via `POST /api/v1/vehicles`.
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final created = await _repository.addVehicle(vehicle);
      final updatedList = <VehicleModel>[created, ...state.vehicles];
      state = state.copyWith(
        vehicles: updatedList,
        totalElements: state.totalElements + 1,
        isSubmitting: false,
      );
      return created;
    } on ApiException {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      throw ApiException(message: 'Failed to create vehicle: $e');
    }
  }

  /// Updates an existing vehicle asset via `PUT /api/v1/vehicles/{id}`.
  Future<VehicleModel> updateVehicle(int id, VehicleModel vehicle) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final updated = await _repository.editVehicle(id, vehicle);
      final updatedList = state.vehicles
          .map((VehicleModel v) => v.id == id ? updated : v)
          .toList();
      state = state.copyWith(
        vehicles: updatedList,
        isSubmitting: false,
      );
      return updated;
    } on ApiException {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      throw ApiException(message: 'Failed to update vehicle: $e');
    }
  }

  /// Deletes a vehicle by ID via `DELETE /api/v1/vehicles/{id}`.
  Future<void> deleteVehicle(int id) async {
    try {
      await _repository.removeVehicle(id);
      final updatedList = state.vehicles.where((VehicleModel v) => v.id != id).toList();
      state = state.copyWith(
        vehicles: updatedList,
        totalElements: state.totalElements > 0 ? state.totalElements - 1 : 0,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete vehicle: $e');
    }
  }
}

/// Global provider for the fleet inventory state.
final vehicleListProvider =
    StateNotifierProvider<VehicleListNotifier, VehicleListState>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return VehicleListNotifier(repository);
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
final vehicleTypeFilterProvider = StateProvider<String?>((ref) {
  return null;
});

/// Filtered vehicle list computed from search query, company, type, and status filters.
final filteredVehiclesProvider = Provider<List<VehicleModel>>((ref) {
  final vehicleState = ref.watch(vehicleListProvider);
  final vehicles = vehicleState.vehicles;
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
  final vehicleState = ref.watch(vehicleListProvider);
  final vehicles = vehicleState.vehicles;

  int availableCount = 0;
  int inUseCount = 0;
  int maintenanceCount = 0;
  int decommissionedCount = 0;

  for (final v in vehicles) {
    switch (v.status) {
      case VehicleStatus.available:
        availableCount++;
        break;
      case VehicleStatus.inUse:
        inUseCount++;
        break;
      case VehicleStatus.underMaintenance:
        maintenanceCount++;
        break;
      case VehicleStatus.decommissioned:
        decommissionedCount++;
        break;
    }
  }

  return VehicleFleetStats(
    total: vehicleState.totalElements > 0 ? vehicleState.totalElements : vehicles.length,
    available: availableCount,
    inUse: inUseCount,
    maintenance: maintenanceCount,
    decommissioned: decommissionedCount,
  );
});

/// Provides the list of unique operating companies present in the fleet.
final availableCompaniesProvider = Provider<List<String>>((ref) {
  final vehicleState = ref.watch(vehicleListProvider);
  final set = <String>{...MockVehicleRepository.companies};
  for (final v in vehicleState.vehicles) {
    if (v.company.isNotEmpty) {
      set.add(v.company);
    }
  }
  final list = set.toList();
  list.sort();
  return list;
});
