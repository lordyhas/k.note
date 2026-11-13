import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knote/ui/core/widgets/responsive.dart';

void main() {
  group('centeredPadding', () {
    test('keeps the gutter when the window is narrower than the content', () {
      expect(
        centeredPadding(400, maxWidth: 720, gutter: 16),
        const EdgeInsets.symmetric(horizontal: 16),
      );
    });

    test('centers the content in a wide window', () {
      final padding = centeredPadding(1280, maxWidth: 720, gutter: 16);
      expect(padding.left, 280);
      expect(padding.right, 280);
      expect(1280 - padding.horizontal, 720);
    });

    test('keeps the top and bottom it is given', () {
      final padding = centeredPadding(400, top: 8, bottom: fabClearance);
      expect(padding.top, 8);
      expect(padding.bottom, fabClearance);
    });
  });

  group('CenteredContent', () {
    Future<Size> sizeIn(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(
        home: CenteredContent(
          maxWidth: 720,
          child: SizedBox(key: Key('content'), height: 100),
        ),
      ));
      return tester.getSize(find.byKey(const Key('content')));
    }

    testWidgets('fills a narrow window', (tester) async {
      expect((await sizeIn(tester, 400)).width, 400);
    });

    testWidgets('stops at its maximum width, centered', (tester) async {
      expect((await sizeIn(tester, 1280)).width, 720);
      expect(tester.getCenter(find.byKey(const Key('content'))).dx, 640);
    });
  });
}
