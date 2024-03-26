import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/src/hooks/hooks.dart';
import 'package:v_flutter_core/src/hooks/use_effect_hooks.dart';

Widget Function(Size, Offset) _defaultBuilder(Widget child) {
  return (Size size, Offset offset) => child;
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
    required this.onChange,
  });

  final GlobalKey? childKey;

  final Widget Function(Size size, Offset offset) builder;
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
                    useValueListenable(size) ?? Size.zero,
                    useValueListenable(offset) ?? Offset.zero,
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

extension GlobalKeyX on GlobalKey {
  Size? get maybeSize {
    if (currentContext == null) {
      return null;
    }

    final renderBox = currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint('Could not find RenderBox when trying to resolve size.');
      return null;
    } else {
      return renderBox.size;
    }
  }

  Offset? get maybeOffset {
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint('Could not find RenderBox when trying to resolve offset.');
      return null;
    } else {
      return renderBox.localToGlobal(Offset.zero);
    }
  }

  Size get size => maybeSize ?? Size.zero;

  Offset get offset => maybeOffset ?? Offset.zero;
}
