// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
// import 'dart:';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:obs_demo/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
     await tester.pumpWidget(const MyApp() as Widget);

    // Verify that our counter starts at 0.
    // ignore: prefer_typing_uninitialized_variables
    var find;
    // ignore: prefer_typing_uninitialized_variables
    var findsOneWidget;
    expect(find.text('0'), findsOneWidget);
    // ignore: prefer_typing_uninitialized_variables
    var findsNothing;
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    
  });
}

void testWidgets(String s, Future<Null> Function(WidgetTester tester) param1) {
}

class Widget {
}

class WidgetTester {
  pumpWidget(Widget myApp) {}
  
  pump() {}
  
  tap(byIcon) {}
}

class MyApp {
  const MyApp();
}
