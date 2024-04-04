import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

class PortalDialog extends HookWidget {
  const PortalDialog({
    super.key,
    required this.builder,
    required this.portalFollowerBuilder,
    this.barrierDecoration,
    this.anchor,
    this.barrierDismissible = true,
    this.direction,
  });

  final Widget Function(bool isOpen, void Function(bool) setIsOpen) portalFollowerBuilder;
  final bool barrierDismissible;
  final Anchor? anchor;
  final BoxDecoration? barrierDecoration;
  final TextDirection? direction;
  final Widget Function(BuildContext context, bool isOpen, void Function(bool) setIsOpen) builder;

  @override
  Widget build(BuildContext context) {
    final globalKey = useGlobalKey<State<StatefulWidget>>();
    final isMenuOpen = useState(false);

    final effectiveAnchor = () {
      if (anchor != null) {
        return anchor!;
      }

      final maybeSize = MediaQuery.maybeSizeOf(context);
      if (maybeSize == null) {
        return Aligned.center;
      }

      return globalKey.getQuadrantAlignment(maybeSize).asAligned(direction);
    }();

    return DismissiblePortalTarget(
      barrierDecoration: barrierDecoration,
      portalFollower: Builder(
        builder: (context) => portalFollowerBuilder(
          isMenuOpen.value,
          (bool value) => isMenuOpen.value = value,
        ),
      ),
      visible: isMenuOpen.value,
      onOutsideClick: () => isMenuOpen.value = false,
      onOutsideScroll: () => isMenuOpen.value = false,
      anchor: effectiveAnchor,
      child: Builder(
        key: globalKey,
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
