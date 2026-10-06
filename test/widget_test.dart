import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:plus_one/main.dart';
import 'package:plus_one/theme/app_theme.dart';

void main() {
  setUpAll(() {
    // Tests run offline; letting google_fonts hit the network makes them
    // flaky and slow. The platform font is enough to assert layout.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders the app shell with the monochrome theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlusOneApp());
    await tester.pump();

    expect(find.text('Plus One'), findsOneWidget);
    expect(find.text('Primary action'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, isTrue);
    expect(
      app.theme?.colorScheme.primary,
      AppTheme.light().colorScheme.primary,
    );
    expect(app.darkTheme?.colorScheme.brightness, Brightness.dark);
  });

  test('light scheme keeps every surface inside the neutral ramp', () {
    final scheme = AppTheme.colorScheme(Brightness.light);

    expect(scheme.brightness, Brightness.light);
    expect(scheme.primary, const Color(0xFF000000));
    expect(scheme.surface, const Color(0xFFF9F9F9));

    // A monochrome palette only stays monochrome if the hue is locked, so
    // assert the neutrals carry no colour cast.
    for (final color in [
      scheme.surface,
      scheme.onSurface,
      scheme.outlineVariant,
      scheme.surfaceContainerHighest,
    ]) {
      final hsl = HSLColor.fromColor(color);
      expect(hsl.saturation, lessThan(0.05), reason: '$color is not neutral');
    }
  });
}
