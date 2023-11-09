import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

VoidCallback useRebuild() {
  final state = useState(DateTime.now().millisecondsSinceEpoch);
  return useCallback(() => state.value = DateTime.now().millisecondsSinceEpoch);
}
