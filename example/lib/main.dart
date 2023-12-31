import 'package:example/pages/showcase_page.dart';
import 'package:flutter/material.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        extensions: [
          ReactiveTextFieldBehavior(),
          ReactiveTextFieldTheme(),
        ],
      ),
      home: const ShowcasePage(),
    );
  }
}
