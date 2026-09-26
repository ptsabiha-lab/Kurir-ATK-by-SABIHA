import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kurir_atk/main.dart';

void main() {
  testWidgets('App menampilkan splash screen saat pertama dibuka', (WidgetTester tester) async {
    await tester.pumpWidget(const KurirAtkApp());
    await tester.pump();

    expect(find.text('Kurir ATK'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
