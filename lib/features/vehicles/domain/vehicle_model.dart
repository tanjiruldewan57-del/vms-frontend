import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Operational statuses for Stark Group fleet assets.
enum VehicleStatus {
  active('Active', AppColors.statusActive, AppColors.statusActiveBg),
  maintenance('In Maintenance', AppColors.statusMaintenance, AppColors.statusMaintenanceBg),
  outOfService('Out of Service', AppColors.statusOutOfService, AppColors.statusOutOfServiceBg);

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  const VehicleStatus(this.label, this.foregroundColor, this.backgroundColor);

  static VehicleStatus fromString(String value) {
    return VehicleStatus.values.firstWhere(
      (VehicleStatus status) =>
          status.name.toLowerCase() == value.toLowerCase() ||
          status.label.toLowerCase() == value.toLowerCase(),
      orElse: () => VehicleStatus.active,
    );
  }
}

/// Vehicle categorization type for heavy materials distribution and operations.
enum VehicleType {
  heavyTruck('Heavy Truck', Icons.local_shipping_rounded),
  distributionVan('Distribution Van', Icons.airport_shuttle_rounded),
  flatbed('Flatbed Crane Truck', Icons.rv_hookup_rounded),
  electricTransporter('Electric Transporter', Icons.electric_bolt_rounded),
  lightUtility('Light Utility Vehicle', Icons.directions_car_rounded);

  final String label;
  final IconData icon;

  const VehicleType(this.label, this.icon);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (VehicleType type) =>
          type.name.toLowerCase() == value.toLowerCase() ||
          type.label.toLowerCase() == value.toLowerCase(),
      orElse: () => VehicleType.heavyTruck,
    );
  }
}

/// Domain model representing a Stark Group fleet asset.
/// Strictly models the 6 core domain properties:
/// 1. Vehicle Number
/// 2. Company
/// 3. Type
/// 4. Brand
/// 5. Model
/// 6. Status
class VehicleModel {
  final String id;
  final String vehicleNumber;
  final String company;
  final VehicleType type;
  final String brand;
  final String model;
  final VehicleStatus status;

  const VehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    required this.status,
  });

  /// Formatted display string combining Brand and Model (e.g. "Volvo FH16 Aero 750").
  String get displayName => '$brand $model';

  /// Creates a copy of this vehicle model with the given fields replaced.
  VehicleModel copyWith({
    String? id,
    String? vehicleNumber,
    String? company,
    VehicleType? type,
    String? brand,
    String? model,
    VehicleStatus? status,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
    );
  }

  /// Converts this vehicle into a JSON-compatible map for future Spring Boot REST integration.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vehicleNumber': vehicleNumber,
      'company': company,
      'type': type.name,
      'brand': brand,
      'model': model,
      'status': status.name,
    };
  }

  /// Parses a vehicle model from a JSON map.
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      company: json['company'] as String,
      type: VehicleType.fromString(json['type'] as String),
      brand: json['brand'] as String,
      model: json['model'] as String,
      status: VehicleStatus.fromString(json['status'] as String),
    );
  }
}
