// ignore_for_file: sort_constructors_first

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:v_flutter_core/src/utils/disposable/disposable_map_group.dart';
import 'package:v_flutter_core/v_flutter_core.dart';

const getTriggerDefinitionsRequiresGetItem = 'Must define fetchItem for getTriggerDefinitions to work.';
const listDependenciesRequiresFetchItem = 'Must define fetchItem for listDependency to work.';
const unusedFetchItem = 'fetchItem is unused if neither getItemTriggerStream nor getItemDependencyStreams are defined.';

class DependencyCollection<ID> {
  DependencyCollection();

  final BehaviorSubject<ID> _triggerSubject = BehaviorSubject<ID>(sync: true);
  Stream<ID> get triggerStream => _triggerSubject;

  final _disposableMapGroup = DisposableMapGroup<ID, String>();

  void dispose() {
    _disposableMapGroup.dispose();
  }

  void removeByKey(ID id) {
    _disposableMapGroup.removeByKey(id);
  }

  void reflectDependencyChanges(ID itemId, TriggerMap triggerMap) {
    final noLongerDependingOn = _removeOutdatedDependencies(itemId, triggerMap);
    _warnAboutSharedDependencies(itemId, triggerMap);
    final newlyDependingOn = _createNewDependencyStreams(itemId, triggerMap);
    _updateSubscriptions(itemId, noLongerDependingOn, newlyDependingOn);
  }

  List<String> _removeOutdatedDependencies(ID itemId, TriggerMap triggerMap) {
    final existingDependencyKeys = _disposableMapGroup.getSubKeys(itemId);
    final noLongerDependingOn = existingDependencyKeys.where((key) => !triggerMap.containsKey(key)).toList();

    for (final dependencyKey in noLongerDependingOn) {
      _disposableMapGroup.removeByKeys(itemId, dependencyKey);
    }

    return noLongerDependingOn;
  }

  void _warnAboutSharedDependencies(ID itemId, TriggerMap triggerMap) {
    final otherDependencyKeys = _disposableMapGroup
        .filterWithKey((key, _) => key != itemId)
        .values
        .map((map) => map.keys)
        .expand((keyList) => keyList);

    final keysThatOtherItemsAlsoDependOn = triggerMap.filterWithKey((key, _) => otherDependencyKeys.contains(key)).keys;

    if (keysThatOtherItemsAlsoDependOn.isNotEmpty) {
      debugPrint(
        '⚠️⚠️ Some other item is already depending on $keysThatOtherItemsAlsoDependOn. '
        'In this case consider using [listDependency] instead. '
        'Which is only listening for a mutual stream once.',
      );
    }
  }

  Map<String, Stream<String>> _createNewDependencyStreams(ID itemId, TriggerMap triggerMap) {
    final newlyDependingOn = triggerMap
        .filterWithKey((key, _) => !_disposableMapGroup.containsKeys(itemId, key))
        .map((key, getDependencyStream) => MapEntry(key, getDependencyStream(key)))
        .mapValue((stream) => stream.map((event) => itemId))
        .map((key, stream) => MapEntry(key, stream.map((_) => key)));

    return newlyDependingOn;
  }

  void _updateSubscriptions(
    ID itemId,
    List<String> noLongerDependingOn,
    Map<String, Stream<String>> newlyDependingOn,
  ) {
    if (noLongerDependingOn.isEmpty && newlyDependingOn.isEmpty) return;

    _removeOldSubscriptions(itemId, noLongerDependingOn);
    _addNewSubscriptions(itemId, newlyDependingOn);
  }

  void _removeOldSubscriptions(ID itemId, List<String> noLongerDependingOn) {
    for (final key in noLongerDependingOn) {
      _disposableMapGroup.removeByKeys(itemId, key);
    }
  }

  void _addNewSubscriptions(ID itemId, Map<String, Stream<String>> newlyDependingOn) {
    for (final entry in newlyDependingOn.entries) {
      final key = entry.key;
      final stream = entry.value;

      _disposableMapGroup.addOrReplaceStreamSubscription(
        itemId,
        key,
        stream.listen((item) => _triggerSubject.add(itemId)),
      );
    }
  }
}
