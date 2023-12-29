import 'package:example/modules/autocomplete_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ShowcasePage extends HookWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = usePageController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShowcasePage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: PageView(
          controller: controller,

          children: const [
            AutocompletePage(),
          ],
        ),
      ),
    );
  }
}
