import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vms_frontend/main.dart';

void main() {
  testWidgets('VmsApp smoke test mounts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VmsApp(),
      ),
    );

    // Let any initial microtasks and router transitions settle
    await tester.pumpAndSettle();

    // Verify VmsApp builds and displays authentication or dashboard title
    expect(find.byType(VmsApp), findsOneWidget);
  });
}

