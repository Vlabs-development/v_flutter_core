import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_core/src/hooks/use_effect_hooks.dart';

Widget Function(Size, Offset?) _defaultBuilder(Widget child) {
  return (Size size, Offset? offset) => child;
}

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
    this.onChange,
  });

  final GlobalKey? childKey;

  final Widget Function(Size size, Offset? offset) builder;
  final void Function(Size size, Offset? offset)? onChange;

  @override
  Widget build(BuildContext context) {
    final globalKey = childKey ?? useState(GlobalKey()).value;
    final size = useValueNotifier(globalKey.size);
    final offset = useValueNotifier(globalKey.offset);

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          size.value = globalKey.size;
          offset.value = globalKey.offset;

          onChange?.call(globalKey.size, globalKey.offset);
        });
        return true;
      },
      child: HookBuilder(
        builder: (context) {
          usePlainPostFrameEffect(() {
            size.value = globalKey.size;
            offset.value = globalKey.offset;
            onChange?.call(size.value, offset.value);
          });

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
    final size = useValueNotifier(const Size(0, 0));

    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeFocus(
          excluding: true,
          child: IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: 0,
              child: SizeReporter(
                child: anchor,
                onChange: (reportedSize, offset) => size.value = reportedSize,
              ),
            ),
          ),
        ),
        HookBuilder(builder: (context) => builder(useValueListenable(size)))
      ],
    );
  }
}

extension GlobalKeyX on GlobalKey {
  Size get size {
    if (currentContext == null) {
      return Size.zero;
    }

    final renderBox = currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint('Could not find RenderBox when getSize');
      return Size.zero;
    } else {
      return renderBox.size;
    }
  }

  Offset? get offset {
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(Offset.zero);
    }
    return null;
  }
}
