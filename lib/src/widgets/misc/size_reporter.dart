import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/extensions/global_key_extensions.dart';
import 'package:v_flutter_core/src/hooks/use_effect_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_global_key.dart';

Widget Function(Size?, Offset?) _defaultBuilder(Widget child) => (Size? size, Offset? offset) => child;
void noOpOnChange(Size _, Offset __) {}

class SizeReporter extends HookWidget {
  SizeReporter({
    super.key,
    this.childKey,
    required Widget child,
    required this.onChange,
  }) : builder = _defaultBuilder(child);

  const SizeReporter.builder({
    super.key,
    this.childKey,
    required this.builder,
    void Function(Size, Offset)? onChange,
  }) : onChange = onChange ?? noOpOnChange;

  final GlobalKey? childKey;

  final Widget Function(Size? size, Offset? offset) builder;
  final void Function(Size size, Offset offset) onChange;

  void _onChange(Size? size, Offset? offset) {
    if (size == null && offset == null) {
      return;
    }

    onChange(size ?? Size.zero, offset ?? Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final globalKey = childKey ?? useGlobalKey();
    final size = useValueNotifier(globalKey.maybeSize);
    final offset = useValueNotifier(globalKey.maybeOffset);

    void _actualizeValuesAndInvokeCallback() {
      if (context.mounted) {
        size.value = globalKey.size;
        offset.value = globalKey.offset;

        _onChange(size.value, offset.value);
      }
    }

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _actualizeValuesAndInvokeCallback());
        return true;
      },
      child: HookBuilder(
        builder: (context) {
          usePlainPostFrameEffect(() => _actualizeValuesAndInvokeCallback());

          return SizeChangedLayoutNotifier(
            child: KeyedSubtree(
              key: globalKey,
              child: HookBuilder(
                builder: (context) {
                  return builder(
                    useValueListenable(size),
                    useValueListenable(offset),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class SizedBy extends HookWidget {
  const SizedBy({
    required this.builder,
    required this.anchor,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget Function(Size) builder;
  final EdgeInsets padding;
  final Widget anchor;

  @override
  Widget build(BuildContext context) {
    final size = useValueNotifier(Size.zero);

    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeFocus(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: SizeReporter(
                child: anchor,
                onChange: (reportedSize, offset) => size.value = reportedSize,
              ),
            ),
          ),
        ),
        HookBuilder(builder: (context) => builder(useValueListenable(size))),
      ],
    );
  }
}
