import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Operational statuses for a fleet vehicle.
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
      (status) => status.name.toLowerCase() == value.toLowerCase() ||
          status.label.toLowerCase() == value.toLowerCase(),
      orElse: () => VehicleStatus.active,
    );
  }
}

/// Vehicle categorization type.
enum VehicleType {
  sedan('Sedan', Icons.directions_car_outlined),
  suv('SUV', Icons.airport_shuttle_outlined),
  truck('Truck', Icons.local_shipping_outlined),
  van('Van', Icons.directions_bus_outlined),
  electric('Electric', Icons.electric_car_outlined),
  hybrid('Hybrid', Icons.eco_outlined);

  final String label;
  final IconData icon;

  const VehicleType(this.label, this.icon);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase() ||
          type.label.toLowerCase() == value.toLowerCase(),
      orElse: () => VehicleType.sedan,
    );
  }
}

/// Domain model representing a vehicle in the fleet.
class VehicleModel {
  final String id;
  final String licensePlate;
  final String vin;
  final String make;
  final String model;
  final int year;
  final VehicleType type;
  final VehicleStatus status;
  final int mileage;
  final String fuelType;
  final String? assignedDriver;
  final String? notes;
  final DateTime? lastServicedDate;

  const VehicleModel({
    required this.id,
    required this.licensePlate,
    required this.vin,
    required this.make,
    required this.model,
    required this.year,
    required this.type,
    required this.status,
    required this.mileage,
    required this.fuelType,
    this.assignedDriver,
    this.notes,
    this.lastServicedDate,
  });

  /// Human-friendly display string (e.g. "2023 Ford F-150").
  String get displayName => '$year $make $model';

  /// Formatted mileage with thousands separators (e.g. "24,500 mi").
  String get formattedMileage {
    final str = mileage.toString();
    final buffer = StringBuffer();
    final length = str.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} mi';
  }

  /// Creates a copy of this vehicle model with the given fields replaced.
  VehicleModel copyWith({
    String? id,
    String? licensePlate,
    String? vin,
    String? make,
    String? model,
    int? year,
    VehicleType? type,
    VehicleStatus? status,
    int? mileage,
    String? fuelType,
    String? assignedDriver,
    String? notes,
    DateTime? lastServicedDate,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      status: status ?? this.status,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      notes: notes ?? this.notes,
      lastServicedDate: lastServicedDate ?? this.lastServicedDate,
    );
  }

  /// Converts this vehicle into a JSON-compatible map for future Spring Boot REST integration.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'licensePlate': licensePlate,
      'vin': vin,
      'make': make,
      'model': model,
      'year': year,
      'type': type.name,
      'status': status.name,
      'mileage': mileage,
      'fuelType': fuelType,
      'assignedDriver': assignedDriver,
      'notes': notes,
      'lastServicedDate': lastServicedDate?.toIso8601String(),
    };
  }

  /// Parses a vehicle model from a JSON map.
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      licensePlate: json['licensePlate'] as String,
      vin: json['vin'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      type: VehicleType.fromString(json['type'] as String),
      status: VehicleStatus.fromString(json['status'] as String),
      mileage: (json['mileage'] as num).toInt(),
      fuelType: json['fuelType'] as String,
      assignedDriver: json['assignedDriver'] as String?,
      notes: json['notes'] as String?,
      lastServicedDate: json['lastServicedDate'] != null
          ? DateTime.tryParse(json['lastServicedDate'] as String)
          : null,
    );
  }
}

