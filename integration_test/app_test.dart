import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../test/fake_shared_preferences_async.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance = FakeSharedPreferencesAsync();
    });

    testWidgets('tap on the floating action button, verify counter', (
      tester,
    ) async {
      await tester.pumpWidget(ProviderScope(child: const MyApp()));
      // This is required prior to taking the screenshot (Android only).
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();

      await binding.takeScreenshot("screnshot");
    });
  });
}
