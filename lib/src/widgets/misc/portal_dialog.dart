import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:v_flutter_core/src/hooks/use_effect_hooks.dart';
import 'package:v_flutter_core/src/hooks/use_value_listener.dart';
import 'package:v_flutter_core/src/widgets/misc/dismissible_portal_target.dart';
import 'package:v_flutter_core/src/widgets/size_reporter.dart';

class PortalDialog extends HookWidget {
  const PortalDialog({
    super.key,
    required this.builder,
    required this.portalFollower,
    this.barrierDecoration,
    this.anchor,
    this.barrierDismissible = true,
    this.visible = false,
    this.hideWhenPressed = const [
      SingleActivator(LogicalKeyboardKey.escape),
      SingleActivator(LogicalKeyboardKey.tab),
      SingleActivator(LogicalKeyboardKey.enter),
      SingleActivator(LogicalKeyboardKey.space),
    ],
  }) : _wrapInCard = false;

  const PortalDialog.card({
    super.key,
    required this.builder,
    required this.portalFollower,
    this.barrierDecoration,
    this.anchor,
    this.barrierDismissible = true,
    this.visible = false,
    this.hideWhenPressed = const [
      SingleActivator(LogicalKeyboardKey.escape),
      SingleActivator(LogicalKeyboardKey.tab),
      SingleActivator(LogicalKeyboardKey.enter),
      SingleActivator(LogicalKeyboardKey.space),
    ],
  }) : _wrapInCard = true;

  final bool _wrapInCard;
  final Widget portalFollower;
  final bool visible;
  final List<SingleActivator> hideWhenPressed;
  final bool barrierDismissible;
  final Anchor? anchor;
  final BoxDecoration? barrierDecoration;
  final Widget Function(BuildContext context, bool isOpen, void Function(bool) setIsOpen) builder;

  @override
  Widget build(BuildContext context) {
    final globalKey = useState(GlobalKey());
    final isMenuOpen = useState(false);
    useValueListener(visible, () {
      isMenuOpen.value = visible;
    });

    final effectiveAnchor = () {
      if (anchor != null) {
        return anchor!;
      }

      final quadrantAlignment = globalKey.value.getQuadrantAlignment(MediaQuery.of(context).size);
      return _getAligned(quadrantAlignment);
    }();

    return DismissiblePortalTarget(
      barrierDecoration: barrierDecoration,
      portalFollower: Builder(
        builder: (context) {
          return _KeepWithinViewport(
            child: CallbackShortcuts(
              bindings: Map.fromEntries(hideWhenPressed.map((e) => MapEntry(e, () => isMenuOpen.value = false))),
              child: Stack(
                children: [
                  Focus(
                    onKey: (node, event) {
                      final hideKeyPressed = hideWhenPressed //
                          .map((e) => e.accepts(event, RawKeyboard.instance))
                          .any((it) => it);
                      return hideKeyPressed ? KeyEventResult.ignored : KeyEventResult.handled;
                    },
                    autofocus: true,
                    child: const SizedBox(width: 1, height: 1),
                  ),
                  Builder(
                    builder: (context) {
                      if (!_wrapInCard) {
                        return portalFollower;
                      }

                      return HookBuilder(
                        builder: (context) {
                          final animationController = useAnimationController(
                            duration: const Duration(milliseconds: 1000),
                          );
                          usePlainEffectOnce(() {
                            animationController.forward();
                          });

                          return SizeTransition(
                            sizeFactor: const AlwaysStoppedAnimation(0.17),
                            child: Card(
                              child: portalFollower,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      visible: isMenuOpen.value,
      onOutsideClick: () => isMenuOpen.value = false,
      onOutsideScroll: () => isMenuOpen.value = false,
      anchor: effectiveAnchor,
      child: Builder(
        key: globalKey.value,
        builder: (context) {
          return builder(
            context,
            isMenuOpen.value,
            (bool value) => isMenuOpen.value = value,
          );
        },
      ),
    );
  }
}

class _KeepWithinViewport extends StatelessWidget {
  const _KeepWithinViewport({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizeReporter.builder(
      builder: (size, offset) {
        final viewportSize = MediaQuery.sizeOf(context);
        final viewportWidth = viewportSize.width;
        final viewportHeight = viewportSize.height;

        final effectiveYOffset = () {
          final yOffset = offset?.dy ?? 0;

          if (yOffset < 0) {
            final negativeVerticalOverflow = yOffset / size.height;
            return negativeVerticalOverflow * -1;
          }
          if (yOffset + size.height > viewportHeight) {
            final positiveVerticalOverflow = yOffset + size.height - viewportHeight;
            return (positiveVerticalOverflow / size.height) * -1;
          }

          return 0;
        }();
        final effectiveXOffset = () {
          final xOffset = offset?.dx ?? 0;

          if (xOffset < 0) {
            final negativeHorizontalOverflow = xOffset / size.width;
            return negativeHorizontalOverflow * -1;
          }
          if (xOffset + size.width > viewportWidth) {
            final positiveHorizontalOverflow = xOffset + size.width - viewportWidth;
            return (positiveHorizontalOverflow / size.width) * -1;
          }

          return 0;
        }();

        return AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuint,
          offset: Offset(effectiveXOffset.toDouble(), effectiveYOffset.toDouble()),
          child: child,
        );
      },
    );
  }
}

Aligned _getAligned(Alignment alignment) {
  if (alignment == Alignment.topLeft) {
    return const Aligned(
      follower: Alignment.topLeft,
      target: Alignment.bottomLeft,
    );
  }
  if (alignment == Alignment.topRight) {
    return const Aligned(
      follower: Alignment.topRight,
      target: Alignment.bottomRight,
    );
  }
  if (alignment == Alignment.bottomLeft) {
    return const Aligned(
      follower: Alignment.bottomLeft,
      target: Alignment.topLeft,
    );
  }
  if (alignment == Alignment.bottomRight) {
    return const Aligned(
      follower: Alignment.bottomRight,
      target: Alignment.topRight,
    );
  }

  return Aligned(
    follower: alignment,
    target: alignment,
  );
}

extension on GlobalKey {
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

  Point get centerPoint {
    if (offset == null) {
      return const Point(0, 0);
    }

    final centerX = offset!.dx + (size.width / 2);
    final centerY = offset!.dy + (size.height / 2);

    return Point(centerX, centerY);
  }

  Alignment getQuadrantAlignment(Size referenceRect) {
    final halfWidth = referenceRect.width / 2;
    final halfHeight = referenceRect.height / 2;

    if (centerPoint.x < halfWidth && centerPoint.y < halfHeight) {
      return Alignment.topLeft;
    } else if (centerPoint.x >= halfWidth && centerPoint.y < halfHeight) {
      return Alignment.topRight;
    } else if (centerPoint.x < halfWidth && centerPoint.y >= halfHeight) {
      return Alignment.bottomLeft;
    } else {
      return Alignment.bottomRight;
    }
  }
}
