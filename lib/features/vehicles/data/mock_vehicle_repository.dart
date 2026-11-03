import '../domain/vehicle_model.dart';

/// In-memory mock repository providing Stark Group fleet seed data and state.
class MockVehicleRepository {
  MockVehicleRepository._();

  static final List<VehicleModel> initialVehicles = <VehicleModel>[
    const VehicleModel(
      id: 'stk-001',
      vehicleNumber: 'STK-DK-101',
      company: 'Stark Denmark Logistics',
      type: VehicleType.heavyTruck,
      brand: 'Scania',
      model: '560 R Super 6x2',
      status: VehicleStatus.active,
    ),
    const VehicleModel(
      id: 'stk-002',
      vehicleNumber: 'STK-UK-204',
      company: 'Stark Building Materials UK',
      type: VehicleType.flatbed,
      brand: 'Volvo',
      model: 'FH16 750 Crane Transporter',
      status: VehicleStatus.active,
    ),
    const VehicleModel(
      id: 'stk-003',
      vehicleNumber: 'STK-DE-308',
      company: 'Stark Deutschland GmbH',
      type: VehicleType.heavyTruck,
      brand: 'Mercedes-Benz',
      model: 'Actros L 1853 GigaSpace',
      status: VehicleStatus.active,
    ),
    const VehicleModel(
      id: 'stk-004',
      vehicleNumber: 'STK-DK-115',
      company: 'Stark Denmark Logistics',
      type: VehicleType.distributionVan,
      brand: 'Mercedes-Benz',
      model: 'Sprinter 319 CDI Pro',
      status: VehicleStatus.active,
    ),
    const VehicleModel(
      id: 'stk-005',
      vehicleNumber: 'STK-SU-402',
      company: 'Stark Suomi Distribution',
      type: VehicleType.electricTransporter,
      brand: 'Volvo',
      model: 'FM Electric 4x2 Tractor',
      status: VehicleStatus.maintenance,
    ),
    const VehicleModel(
      id: 'stk-006',
      vehicleNumber: 'STK-NO-510',
      company: 'Stark Distribution Nordics',
      type: VehicleType.heavyTruck,
      brand: 'MAN',
      model: 'TGX 26.640 Individual Lion',
      status: VehicleStatus.active,
    ),
    const VehicleModel(
      id: 'stk-007',
      vehicleNumber: 'STK-UK-219',
      company: 'Stark Building Materials UK',
      type: VehicleType.distributionVan,
      brand: 'Ford',
      model: 'E-Transit 350 L3H2',
      status: VehicleStatus.active,
    ),
    const VehicleModel(
      id: 'stk-008',
      vehicleNumber: 'STK-DE-322',
      company: 'Stark Deutschland GmbH',
      type: VehicleType.flatbed,
      brand: 'DAF',
      model: 'XG+ 530 Flatbed Cargo',
      status: VehicleStatus.outOfService,
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
