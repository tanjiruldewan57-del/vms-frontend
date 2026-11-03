import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/page_response.dart';
import '../domain/vehicle_model.dart';

/// Service interfacing directly with Spring Boot VehicleController endpoints.
class VehicleApiService {
  final ApiClient _client;

  const VehicleApiService(this._client);

  /// Fetches paginated and filtered fleet vehicles from `GET /api/v1/vehicles`.
  Future<PageResponse<VehicleModel>> getVehicles({
    String? company,
    VehicleStatus? status,
    String? search,
    int page = 0,
    int size = 100,
    String sort = 'id,desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': sort,
      if (company != null && company.trim().isNotEmpty) 'company': company.trim(),
      if (status != null) 'status': status.apiValue,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.vehiclesEndpoint,
      queryParameters: queryParams,
    );

    final rootData = response.data;
    if (rootData == null || rootData['data'] == null) {
      return PageResponse<VehicleModel>.empty();
    }

    final pageJson = rootData['data'] as Map<String, dynamic>;
    return PageResponse<VehicleModel>.fromJson(
      pageJson,
      VehicleModel.fromJson,
    );
  }

  /// Retrieves a single vehicle by its database ID from `GET /api/v1/vehicles/{id}`.
  Future<VehicleModel> getVehicleById(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.vehicleByIdEndpoint(id),
    );

    final rootData = response.data;
    if (rootData == null || rootData['data'] == null) {
      throw const ApiException(
        statusCode: 404,
        message: 'Vehicle resource not found.',
      );
    }

    return VehicleModel.fromJson(rootData['data'] as Map<String, dynamic>);
  }

  /// Retrieves a single vehicle by its unique vehicle number from `GET /api/v1/vehicles/number/{vehicleNumber}`.
  Future<VehicleModel> getVehicleByNumber(String vehicleNumber) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConfig.vehicleByNumberEndpoint(vehicleNumber),
    );

    final rootData = response.data;
    if (rootData == null || rootData['data'] == null) {
      throw const ApiException(
        statusCode: 404,
        message: 'Vehicle resource not found.',
      );
    }

    return VehicleModel.fromJson(rootData['data'] as Map<String, dynamic>);
  }

  /// Creates a new vehicle asset via `POST /api/v1/vehicles`.
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConfig.vehiclesEndpoint,
      data: vehicle.toCreateJson(),
    );

    final rootData = response.data;
    if (rootData == null || rootData['data'] == null) {
      throw const ApiException(
        message: 'Failed to create vehicle: Empty response from server.',
      );
    }

    return VehicleModel.fromJson(rootData['data'] as Map<String, dynamic>);
  }

  /// Updates an existing vehicle asset via `PUT /api/v1/vehicles/{id}`.
  Future<VehicleModel> updateVehicle(int id, VehicleModel vehicle) async {
    final response = await _client.put<Map<String, dynamic>>(
      ApiConfig.vehicleByIdEndpoint(id),
      data: vehicle.toUpdateJson(),
    );

    final rootData = response.data;
    if (rootData == null || rootData['data'] == null) {
      throw const ApiException(
        message: 'Failed to update vehicle: Empty response from server.',
      );
    }

    return VehicleModel.fromJson(rootData['data'] as Map<String, dynamic>);
  }

  /// Deletes a vehicle by ID via `DELETE /api/v1/vehicles/{id}`.
  Future<void> deleteVehicle(int id) async {
    await _client.delete<dynamic>(
      ApiConfig.vehicleByIdEndpoint(id),
    );
  }
}

/// Global Riverpod provider for VehicleApiService.
final vehicleApiServiceProvider = Provider<VehicleApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VehicleApiService(apiClient);
});

