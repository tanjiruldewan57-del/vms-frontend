import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/page_response.dart';
import '../domain/vehicle_model.dart';
import 'vehicle_api_service.dart';

/// Clean repository implementation separating UI presentation from REST networking.
class VehicleRepository {
  final VehicleApiService _apiService;

  const VehicleRepository(this._apiService);

  /// Retrieves filtered and paginated vehicle assets.
  Future<PageResponse<VehicleModel>> fetchVehicles({
    String? company,
    VehicleStatus? status,
    String? search,
    int page = 0,
    int size = 100,
  }) {
    return _apiService.getVehicles(
      company: company,
      status: status,
      search: search,
      page: page,
      size: size,
    );
  }

  /// Retrieves an individual vehicle by ID.
  Future<VehicleModel> fetchVehicleById(int id) {
    return _apiService.getVehicleById(id);
  }

  /// Adds a new vehicle asset.
  Future<VehicleModel> addVehicle(VehicleModel vehicle) {
    return _apiService.createVehicle(vehicle);
  }

  /// Updates an existing vehicle asset.
  Future<VehicleModel> editVehicle(int id, VehicleModel vehicle) {
    return _apiService.updateVehicle(id, vehicle);
  }

  /// Deletes a vehicle asset by its ID.
  Future<void> removeVehicle(int id) {
    return _apiService.deleteVehicle(id);
  }
}

/// Global provider for VehicleRepository.
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final apiService = ref.watch(vehicleApiServiceProvider);
  return VehicleRepository(apiService);
});

