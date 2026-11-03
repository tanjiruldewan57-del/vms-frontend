import '../domain/vehicle_model.dart';

/// Status of the vehicle fleet data loading lifecycle.
enum VehicleListStatus {
  initial,
  loading,
  success,
  error,
}

/// Immutable state container holding the vehicle inventory and UI operation statuses.
class VehicleListState {
  final VehicleListStatus status;
  final List<VehicleModel> vehicles;
  final int totalElements;
  final String? errorMessage;
  final String? errorDetails;
  final bool isSubmitting;

  const VehicleListState({
    required this.status,
    required this.vehicles,
    required this.totalElements,
    this.errorMessage,
    this.errorDetails,
    this.isSubmitting = false,
  });

  factory VehicleListState.initial() {
    return const VehicleListState(
      status: VehicleListStatus.initial,
      vehicles: <VehicleModel>[],
      totalElements: 0,
      errorMessage: null,
      errorDetails: null,
      isSubmitting: false,
    );
  }

  bool get isInitial => status == VehicleListStatus.initial;
  bool get isLoading => status == VehicleListStatus.loading;
  bool get isSuccess => status == VehicleListStatus.success;
  bool get isError => status == VehicleListStatus.error;
  bool get isEmpty => isSuccess && vehicles.isEmpty;

  VehicleListState copyWith({
    VehicleListStatus? status,
    List<VehicleModel>? vehicles,
    int? totalElements,
    String? errorMessage,
    String? errorDetails,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return VehicleListState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      totalElements: totalElements ?? this.totalElements,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorDetails: clearError ? null : (errorDetails ?? this.errorDetails),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

