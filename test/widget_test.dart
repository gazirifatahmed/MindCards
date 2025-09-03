// This is a basic Flutter widget test for MCQ Maker app.
//
// It checks that the app builds, shows the home screen title,
// and that core UI elements are present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mcq_maker/main.dart';

void main() {
  testWidgets('MCQ Maker home screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MCQApp());

    // Verify that the home page title is shown.
    expect(find.text('MCQ Maker (Offline)'), findsOneWidget);

    // Verify that key instructions are present.
    expect(find.textContaining('Choose a generation mode'), findsOneWidget);
    expect(find.textContaining('How many questions?'), findsOneWidget);

    // Check that the "Generate Quiz" button is there.
    expect(find.text('Generate Quiz'), findsOneWidget);
  });
}
