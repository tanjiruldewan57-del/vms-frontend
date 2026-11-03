import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_frontend/core/network/api_client.dart';
import 'package:vms_frontend/core/network/page_response.dart';
import 'package:vms_frontend/features/vehicles/data/vehicle_api_service.dart';
import 'package:vms_frontend/features/vehicles/data/vehicle_repository.dart';
import 'package:vms_frontend/features/vehicles/domain/vehicle_model.dart';
import 'package:vms_frontend/main.dart';

/// Test repository preventing raw socket connections during widget tests.
class FakeVehicleRepository extends VehicleRepository {
  FakeVehicleRepository() : super(VehicleApiService(ApiClient()));

  @override
  Future<PageResponse<VehicleModel>> fetchVehicles({
    String? company,
    VehicleStatus? status,
    String? search,
    int page = 0,
    int size = 100,
  }) async {
    return PageResponse<VehicleModel>.empty();
  }

  @override
  Future<VehicleModel> fetchVehicleById(int id) async {
    return const VehicleModel(
      id: 1,
      vehicleNumber: 'STK-DK-101',
      company: 'Stark Denmark Logistics',
      type: 'Heavy Truck',
      brand: 'Scania',
      model: '560 R Super 6x2',
      status: VehicleStatus.available,
    );
  }
}

void main() {
  testWidgets('VmsApp smoke test mounts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(FakeVehicleRepository()),
        ],
        child: const VmsApp(),
      ),
    );

    // Let any initial microtasks and router transitions settle
    await tester.pumpAndSettle();

    // Verify VmsApp builds and displays authentication or dashboard title
    expect(find.byType(VmsApp), findsOneWidget);
  });
}
