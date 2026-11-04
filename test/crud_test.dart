import 'package:flutter_test/flutter_test.dart';
import 'package:vms_frontend/core/network/api_client.dart';
import 'package:vms_frontend/core/network/api_exception.dart';
import 'package:vms_frontend/core/network/page_response.dart';
import 'package:vms_frontend/features/vehicles/data/vehicle_api_service.dart';
import 'package:vms_frontend/features/vehicles/data/vehicle_repository.dart';
import 'package:vms_frontend/features/vehicles/domain/vehicle_model.dart';
import 'package:vms_frontend/features/vehicles/presentation/vehicle_provider.dart';

class MockVehicleApiService extends VehicleApiService {
  MockVehicleApiService() : super(ApiClient());

  final List<VehicleModel> db = <VehicleModel>[
    const VehicleModel(
      id: 1,
      vehicleNumber: 'STK-DK-101',
      company: 'Stark Denmark Logistics',
      type: 'Heavy Truck',
      brand: 'Scania',
      model: '560 R',
      status: VehicleStatus.available,
    ),
    const VehicleModel(
      id: 2,
      vehicleNumber: 'STK-UK-202',
      company: 'Stark Building Materials UK',
      type: 'Distribution Van',
      brand: 'Mercedes-Benz',
      model: 'Sprinter',
      status: VehicleStatus.inUse,
    ),
  ];

  bool simulateDuplicateConflict = false;

  @override
  Future<PageResponse<VehicleModel>> getVehicles({
    String? company,
    VehicleStatus? status,
    String? search,
    int page = 0,
    int size = 100,
    String sort = 'id,desc',
  }) async {
    return PageResponse<VehicleModel>(
      content: List<VehicleModel>.from(db),
      pageNumber: 0,
      pageSize: 20,
      totalElements: db.length,
      totalPages: 1,
      isFirst: true,
      isLast: true,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<VehicleModel> getVehicleById(int id) async {
    final found = db.cast<VehicleModel?>().firstWhere(
          (VehicleModel? v) => v?.id == id,
          orElse: () => null,
        );
    if (found == null) {
      throw const ApiException(statusCode: 404, message: 'Not found');
    }
    return found;
  }

  @override
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    if (simulateDuplicateConflict ||
        db.any((VehicleModel v) => v.vehicleNumber == vehicle.vehicleNumber)) {
      throw const ApiException(
        statusCode: 409,
        message: 'Vehicle number already exists in the fleet',
      );
    }

    final created = VehicleModel(
      id: db.length + 1,
      vehicleNumber: vehicle.vehicleNumber,
      company: vehicle.company,
      type: vehicle.type,
      brand: vehicle.brand,
      model: vehicle.model,
      status: vehicle.status,
    );
    db.add(created);
    return created;
  }

  @override
  Future<VehicleModel> updateVehicle(int id, VehicleModel vehicle) async {
    final index = db.indexWhere((VehicleModel v) => v.id == id);
    if (index == -1) {
      throw const ApiException(statusCode: 404, message: 'Not found');
    }
    final updated = VehicleModel(
      id: id,
      vehicleNumber: vehicle.vehicleNumber,
      company: vehicle.company,
      type: vehicle.type,
      brand: vehicle.brand,
      model: vehicle.model,
      status: vehicle.status,
    );
    db[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteVehicle(int id) async {
    final index = db.indexWhere((VehicleModel v) => v.id == id);
    if (index == -1) {
      throw const ApiException(statusCode: 404, message: 'Not found');
    }
    db.removeAt(index);
  }
}

void main() {
  group('Real VMS CRUD Flow', () {
    late MockVehicleApiService mockService;
    late VehicleRepository repository;
    late VehicleListNotifier notifier;

    setUp(() {
      mockService = MockVehicleApiService();
      repository = VehicleRepository(mockService);
      notifier = VehicleListNotifier(repository);
    });

    test('Loads initial fleet from backend', () async {
      await notifier.loadVehicles();
      expect(notifier.state.vehicles.length, 2);
      expect(notifier.state.isSuccess, true);
      expect(notifier.state.vehicles.first.vehicleNumber, 'STK-DK-101');
    });

    test('Creates new vehicle asset and updates inventory', () async {
      await notifier.loadVehicles();

      const newVehicle = VehicleModel(
        vehicleNumber: 'STK-DE-303',
        company: 'Stark Deutschland GmbH',
        type: 'Electric Transporter',
        brand: 'Volvo',
        model: 'FM Electric',
        status: VehicleStatus.available,
      );

      final created = await notifier.createVehicle(newVehicle);
      expect(created.id, 3);
      expect(created.vehicleNumber, 'STK-DE-303');
      expect(notifier.state.vehicles.any((VehicleModel v) => v.id == 3), true);
    });

    test('Throws 409 Conflict with friendly message on duplicate vehicle number', () async {
      await notifier.loadVehicles();

      const duplicateVehicle = VehicleModel(
        vehicleNumber: 'STK-DK-101', // Already exists in mockService.db
        company: 'Stark Denmark Logistics',
        type: 'Heavy Truck',
        brand: 'Scania',
        model: '560 R',
        status: VehicleStatus.available,
      );

      expect(
        () => notifier.createVehicle(duplicateVehicle),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.message,
            'message',
            'Vehicle number already exists in the fleet',
          ),
        ),
      );
    });

    test('Updates existing vehicle asset and updates inventory', () async {
      await notifier.loadVehicles();

      const updatedVehicle = VehicleModel(
        id: 1,
        vehicleNumber: 'STK-DK-101-MOD',
        company: 'Stark Denmark Logistics',
        type: 'Heavy Truck',
        brand: 'Scania Super',
        model: '660 S',
        status: VehicleStatus.inUse,
      );

      final result = await notifier.updateVehicle(1, updatedVehicle);
      expect(result.vehicleNumber, 'STK-DK-101-MOD');
      expect(result.brand, 'Scania Super');

      final current = notifier.state.vehicles.firstWhere((VehicleModel v) => v.id == 1);
      expect(current.vehicleNumber, 'STK-DK-101-MOD');
      expect(current.status, VehicleStatus.inUse);
    });

    test('Deletes vehicle asset only upon successful server deletion', () async {
      await notifier.loadVehicles();
      expect(notifier.state.vehicles.length, 2);

      await notifier.deleteVehicle(1);
      expect(notifier.state.vehicles.length, 1);
      expect(notifier.state.vehicles.any((VehicleModel v) => v.id == 1), false);
    });
  });
}

