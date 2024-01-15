import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:universal_html/html.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

const _visibilityChangeEventName = 'visibilitychange';

enum TabVisibilityChangeEvent { hidden, visible }

extension TabVisibilityChangeEventFromString on String {
  TabVisibilityChangeEvent toTabVisibilityChangeEvent() {
    switch (this) {
      case 'hidden':
        return TabVisibilityChangeEvent.hidden;
      case 'visible':
        return TabVisibilityChangeEvent.visible;
      default:
        throw Exception('Unknown TabVisibilityChangeEvent: $this');
    }
  }
}

/// > "This event fires with a `visibilityState` of `hidden` when a user navigates to a new page,
/// switches tabs, closes the tab, minimizes or closes the browser,
/// or, on mobile, switches from the browser to a different app."
///
/// quoted from: https://developer.mozilla.org/en-US/docs/Web/API/Document/visibilitychange_event
class TabVisibilityChangeRecognizer extends HookWidget {
  const TabVisibilityChangeRecognizer({
    required this.child,
    required this.onVisibilityChange,
    super.key,
  });

  final Widget child;
  final void Function(TabVisibilityChangeEvent) onVisibilityChange;

  void _internalOnVisibilityChange(Event _) {
    try {
      final event = document.visibilityState.toTabVisibilityChangeEvent();
      onVisibilityChange(event);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    useEffectOnce(() {
      document.addEventListener(_visibilityChangeEventName, _internalOnVisibilityChange);

      return () => document.removeEventListener(_visibilityChangeEventName, _internalOnVisibilityChange);
    });

    return child;
  }
}
