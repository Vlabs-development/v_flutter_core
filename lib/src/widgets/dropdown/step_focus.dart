import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_effect_hooks.dart';

/// This is a workaround widget, because wrapping [MenuItemButton] in a [Focus] (to add autfocus: true)
/// results in an unwanted side effect of not having a focus effect at all.
class StepFocus extends StatelessWidget {
  const StepFocus({
    required this.child,
    this.autofocus = true,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (enabled)
          HookBuilder(
            builder: (context) {
              final focusNode = useFocusNode();
              final checkIsMounted = useIsMounted();

              usePlainPostFrameEffectOnce(() async {
                await Future<void>.delayed(const Duration(milliseconds: 50));
                if (!checkIsMounted()) {
                  return;
                }
                focusNode.nextFocus();
                focusNode.skipTraversal = true;
                focusNode.canRequestFocus = false;
              });
              return Focus.withExternalFocusNode(
                focusNode: focusNode,
                autofocus: autofocus,
                child: const SizedBox(),
              );
            },
          ),
        child,
      ],
    );
  }
}
