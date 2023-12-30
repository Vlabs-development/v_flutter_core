import 'package:example/modules/input/showcase_field/showcase_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:v_flutter_core/v_flutter_core.dart';
import 'package:collection/collection.dart';

final timeValues = {
  CompositeValue(key: '15:15', value: const TimeOfDay(hour: 15, minute: 15)),
  CompositeValue(key: '15:30', value: const TimeOfDay(hour: 15, minute: 30)),
  CompositeValue(key: '15:45', value: const TimeOfDay(hour: 15, minute: 45)),
  CompositeValue(key: '16:00', value: const TimeOfDay(hour: 16, minute: 00)),
  CompositeValue(key: '16:15', value: const TimeOfDay(hour: 16, minute: 15)),
  CompositeValue(key: '16:30', value: const TimeOfDay(hour: 16, minute: 30)),
  CompositeValue(key: '16:45', value: const TimeOfDay(hour: 16, minute: 45)),
};

class AutocompletePage extends HookWidget {
  const AutocompletePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const GapColumn(
      gap: 16,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldRow(clearBehavior: CompositeNodeFieldClearBehavior.none),
        FieldRow(clearBehavior: CompositeNodeFieldClearBehavior.empty),
        FieldRow(clearBehavior: CompositeNodeFieldClearBehavior.changed),
      ],
    );
  }
}

class FieldRow extends StatelessWidget {
  const FieldRow({
    super.key,
    required this.clearBehavior,
  });

  final CompositeNodeFieldClearBehavior clearBehavior;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(
      builder: (context) {
        final selectedKey = useState<String?>('15:30');
        final focusNode = useFocusNode();

        useIsFocusedFor(
          focusNode,
          const Duration(seconds: 3),
          () {
            debugPrint('Setting value to 16:30');
            selectedKey.value = '16:30';
          },
        );

        return GapRow(
          gap: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => selectedKey.value = '16:00',
              child: const Text('✍️ 16:00'),
            ),
            ElevatedButton(
              onPressed: () => selectedKey.value = 'INVALID',
              child: const Text('✍️ INVALID'),
            ),
            Expanded(
              child: ShowcaseAutocompleteField<String, TimeOfDay>(
                clearBehavior: clearBehavior,
                focusNode: focusNode,
                maxDropdownHeight: 300,
                displayStringForOption: (timeOfDay) => timeOfDay != null ? formatTimeOfDay(timeOfDay) : '',
                valueBuilder: (node, isSelected, isHighlighted, select) {
                  return _valueBuilder(select, isHighlighted, node, isSelected);
                },
                options: CompositeGroup.root(nodes: timeValues),
                onSelected: (value) {
                  selectedKey.value = value;
                  final rangeKey = timeValues.firstWhereOrNull((e) => e.key == value)?.value;
                  if (rangeKey != null) {
                    debugPrint("✅ onChanged $value");
                  } else {
                    debugPrint("❌ $value cannot be found");
                  }
                },
                label: "${selectedKey.value ?? ''} - $clearBehavior",
                selectedKey: selectedKey.value,
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _valueBuilder(
  void Function() select,
  bool isHighlighted,
  DepthCompositeValue<String, TimeOfDay> node,
  bool isSelected,
) {
  return InkWell(
    onTap: select,
    child: Container(
      decoration: BoxDecoration(color: isHighlighted ? Colors.grey.shade200 : Colors.grey.shade50),
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                formatTimeOfDay(node.value.value),
                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
