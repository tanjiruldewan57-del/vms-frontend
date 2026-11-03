import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Operational lifecycle statuses for fleet vehicles matching Spring Boot enum VehicleStatus.
enum VehicleStatus {
  available('Available', AppColors.statusActive, AppColors.statusActiveBg),
  inUse('In Use', AppColors.starkOrange, Color(0x1AEA580C)),
  underMaintenance('Under Maintenance', AppColors.statusMaintenance, AppColors.statusMaintenanceBg),
  decommissioned('Decommissioned', AppColors.statusOutOfService, AppColors.statusOutOfServiceBg);

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  const VehicleStatus(this.label, this.foregroundColor, this.backgroundColor);

  /// Exact backend enum string for Spring Boot request payloads.
  String get apiValue {
    switch (this) {
      case VehicleStatus.available:
        return 'AVAILABLE';
      case VehicleStatus.inUse:
        return 'IN_USE';
      case VehicleStatus.underMaintenance:
        return 'UNDER_MAINTENANCE';
      case VehicleStatus.decommissioned:
        return 'DECOMMISSIONED';
    }
  }

  /// Parses a backend enum string into a strongly-typed enum.
  static VehicleStatus fromString(String? value) {
    if (value == null) return VehicleStatus.available;
    final normalized = value.trim().toUpperCase().replaceAll(' ', '_');
    switch (normalized) {
      case 'AVAILABLE':
        return VehicleStatus.available;
      case 'IN_USE':
      case 'INUSE':
      case 'ACTIVE':
        return VehicleStatus.inUse;
      case 'UNDER_MAINTENANCE':
      case 'MAINTENANCE':
        return VehicleStatus.underMaintenance;
      case 'DECOMMISSIONED':
      case 'OUT_OF_SERVICE':
        return VehicleStatus.decommissioned;
      default:
        return VehicleStatus.available;
    }
  }
}

/// Helper classifications for vehicle types.
class VehicleTypeHelper {
  const VehicleTypeHelper._();

  static const List<String> defaultTypes = <String>[
    'Heavy Truck',
    'Distribution Van',
    'Flatbed Crane Truck',
    'Electric Transporter',
    'Light Utility Vehicle',
  ];

  static IconData getIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('van')) {
      return Icons.airport_shuttle_rounded;
    } else if (lower.contains('flatbed') || lower.contains('crane')) {
      return Icons.rv_hookup_rounded;
    } else if (lower.contains('electric')) {
      return Icons.electric_bolt_rounded;
    } else if (lower.contains('utility') || lower.contains('car')) {
      return Icons.directions_car_rounded;
    }
    return Icons.local_shipping_rounded;
  }
}

/// Domain model representing a Stark Group fleet asset.
/// Strictly maps to Spring Boot VehicleResponse, VehicleCreateRequest, and VehicleUpdateRequest.
class VehicleModel {
  final int? id;
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final VehicleStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleModel({
    this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Formatted display string combining Brand and Model (e.g. "Volvo FH16 Aero 750").
  String get displayName => '$brand $model';

  /// Icon based on vehicle type.
  IconData get typeIcon => VehicleTypeHelper.getIcon(type);

  /// Creates a copy of this vehicle model with the given fields replaced.
  VehicleModel copyWith({
    int? id,
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Maps model into Spring Boot VehicleCreateRequest JSON format.
  Map<String, dynamic> toCreateJson() {
    return <String, dynamic>{
      'vehicleNumber': vehicleNumber.trim().toUpperCase(),
      'company': company.trim(),
      'type': type.trim(),
      'brand': brand.trim(),
      'model': model.trim(),
      'status': status.apiValue,
    };
  }

  /// Maps model into Spring Boot VehicleUpdateRequest JSON format.
  Map<String, dynamic> toUpdateJson() {
    return <String, dynamic>{
      'vehicleNumber': vehicleNumber.trim().toUpperCase(),
      'company': company.trim(),
      'type': type.trim(),
      'brand': brand.trim(),
      'model': model.trim(),
      'status': status.apiValue,
    };
  }

  /// Converts this vehicle into a general JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'vehicleNumber': vehicleNumber,
      'company': company,
      'type': type,
      'brand': brand,
      'model': model,
      'status': status.apiValue,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Parses a vehicle model from a Spring Boot JSON response payload.
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: (json['id'] as num?)?.toInt(),
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      company: json['company'] as String? ?? '',
      type: json['type'] as String? ?? 'Heavy Truck',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      status: VehicleStatus.fromString(json['status'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}
