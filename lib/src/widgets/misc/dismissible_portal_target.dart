import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:v_core/src/hooks/use_scroll_notification_observer.dart';
import 'package:v_core/src/widgets/misc/always_scrollbar.dart';

class DismissiblePortalTarget extends HookWidget {
  const DismissiblePortalTarget({
    super.key,
    required this.child,
    required this.portalFollower,
    required this.visible,
    this.onOutsideClick,
    this.onOutsideScroll,
    this.portalCandidateLabels = const [PortalLabel.main],
    this.barrierDecoration,
    this.anchor = const Filled(),
    this.barrierDismissible = true,
  });

  final Widget child;
  final Widget portalFollower;
  final bool visible;
  final bool barrierDismissible;
  final Anchor anchor;
  final VoidCallback? onOutsideClick;
  final VoidCallback? onOutsideScroll;
  final BoxDecoration? barrierDecoration;
  final List<PortalLabel<dynamic>> portalCandidateLabels;

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      portalCandidateLabels: portalCandidateLabels,
      visible: visible,
      portalFollower: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Entry.opacity(
          duration: const Duration(milliseconds: 500),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: barrierDecoration ?? BoxDecoration(color: Colors.black.withOpacity(0.1)),
                ),
              ),
              NeverScrollbar(
                child: HookBuilder(
                  builder: (context) {
                    final controller = useScrollController(initialScrollOffset: 50);
                    return SingleChildScrollView(
                      controller: controller,
                      child: HookBuilder(
                        builder: (context) {
                          useScrollNotificationObserver(context, handler: (notification) {
                            if (notification is UserScrollNotification) {
                              onOutsideScroll?.call();
                            }
                          });
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height + 100,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          if (barrierDismissible) {
            onOutsideClick?.call();
          }
        },
      ),
      child: PortalTarget(
        visible: visible,
        anchor: anchor,
        portalFollower: Entry.opacity(child: portalFollower),
        child: child,
      ),
    );
  }
}
