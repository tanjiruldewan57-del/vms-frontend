import '../domain/vehicle_model.dart';

/// In-memory mock repository providing Stark Group fleet seed data and state.
class MockVehicleRepository {
  MockVehicleRepository._();

  static final List<VehicleModel> initialVehicles = <VehicleModel>[
    const VehicleModel(
      id: 1,
      vehicleNumber: 'STK-DK-101',
      company: 'Stark Denmark Logistics',
      type: 'Heavy Truck',
      brand: 'Scania',
      model: '560 R Super 6x2',
      status: VehicleStatus.available,
    ),
    const VehicleModel(
      id: 2,
      vehicleNumber: 'STK-UK-204',
      company: 'Stark Building Materials UK',
      type: 'Flatbed Crane Truck',
      brand: 'Volvo',
      model: 'FH16 750 Crane Transporter',
      status: VehicleStatus.inUse,
    ),
    const VehicleModel(
      id: 3,
      vehicleNumber: 'STK-DE-308',
      company: 'Stark Deutschland GmbH',
      type: 'Heavy Truck',
      brand: 'Mercedes-Benz',
      model: 'Actros L 1853 GigaSpace',
      status: VehicleStatus.available,
    ),
    const VehicleModel(
      id: 4,
      vehicleNumber: 'STK-DK-115',
      company: 'Stark Denmark Logistics',
      type: 'Distribution Van',
      brand: 'Mercedes-Benz',
      model: 'Sprinter 319 CDI Pro',
      status: VehicleStatus.available,
    ),
    const VehicleModel(
      id: 5,
      vehicleNumber: 'STK-SU-402',
      company: 'Stark Suomi Distribution',
      type: 'Electric Transporter',
      brand: 'Volvo',
      model: 'FM Electric 4x2 Tractor',
      status: VehicleStatus.underMaintenance,
    ),
    const VehicleModel(
      id: 6,
      vehicleNumber: 'STK-NO-510',
      company: 'Stark Distribution Nordics',
      type: 'Heavy Truck',
      brand: 'MAN',
      model: 'TGX 26.640 Individual Lion',
      status: VehicleStatus.available,
    ),
    const VehicleModel(
      id: 7,
      vehicleNumber: 'STK-UK-219',
      company: 'Stark Building Materials UK',
      type: 'Distribution Van',
      brand: 'Ford',
      model: 'E-Transit 350 L3H2',
      status: VehicleStatus.inUse,
    ),
    const VehicleModel(
      id: 8,
      vehicleNumber: 'STK-DE-322',
      company: 'Stark Deutschland GmbH',
      type: 'Flatbed Crane Truck',
      brand: 'DAF',
      model: 'XG+ 530 Flatbed Cargo',
      status: VehicleStatus.decommissioned,
    ),
  ];

  static const List<String> companies = <String>[
    'Stark Denmark Logistics',
    'Stark Building Materials UK',
    'Stark Deutschland GmbH',
    'Stark Suomi Distribution',
    'Stark Distribution Nordics',
  ];
}
