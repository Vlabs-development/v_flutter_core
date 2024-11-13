// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mutation_provider_with_live_list_test.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$apiCommentListHash() => r'1eac9635f120c3c105666519ccd5462fe19fc87c';

/// See also [apiCommentList].
@ProviderFor(apiCommentList)
final apiCommentListPod = AutoDisposeStreamProvider<List<Comment>>.internal(
  apiCommentList,
  name: r'apiCommentListPod',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$apiCommentListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApiCommentListRef = AutoDisposeStreamProviderRef<List<Comment>>;
String _$commentLiveListHash() => r'477b3712d4281c8c948860bb283b653123e2587f';

/// See also [commentLiveList].
@ProviderFor(commentLiveList)
final commentLiveListPod =
    AutoDisposeProvider<LiveList<String, Comment>>.internal(
  commentLiveList,
  name: r'commentLiveListPod',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commentLiveListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommentLiveListRef = AutoDisposeProviderRef<LiveList<String, Comment>>;
String _$commentListHash() => r'66a9ea47723c0f4c19eca796e5e66cd0d24584ac';

/// See also [commentList].
@ProviderFor(commentList)
final commentListPod = AutoDisposeStreamProvider<List<Comment>>.internal(
  commentList,
  name: r'commentListPod',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$commentListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommentListRef = AutoDisposeStreamProviderRef<List<Comment>>;
String _$mutableCommentHash() => r'3ad3d98e129b43cbe07ac2626066dbaa8d9a6e87';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MutableComment
    extends BuildlessAutoDisposeStreamNotifier<MPS<CommentMutation, Comment>> {
  late final String id;

  Stream<MPS<CommentMutation, Comment>> build({
    required String id,
  });
}

/// See also [MutableComment].
@ProviderFor(MutableComment)
const mutableCommentPod = MutableCommentFamily();

/// See also [MutableComment].
class MutableCommentFamily
    extends Family<AsyncValue<MPS<CommentMutation, Comment>>> {
  /// See also [MutableComment].
  const MutableCommentFamily();

  /// See also [MutableComment].
  MutableCommentProvider call({
    required String id,
  }) {
    return MutableCommentProvider(
      id: id,
    );
  }

  @override
  MutableCommentProvider getProviderOverride(
    covariant MutableCommentProvider provider,
  ) {
    return call(
      id: provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mutableCommentPod';
}

/// See also [MutableComment].
class MutableCommentProvider extends AutoDisposeStreamNotifierProviderImpl<
    MutableComment, MPS<CommentMutation, Comment>> {
  /// See also [MutableComment].
  MutableCommentProvider({
    required String id,
  }) : this._internal(
          () => MutableComment()..id = id,
          from: mutableCommentPod,
          name: r'mutableCommentPod',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mutableCommentHash,
          dependencies: MutableCommentFamily._dependencies,
          allTransitiveDependencies:
              MutableCommentFamily._allTransitiveDependencies,
          id: id,
        );

  MutableCommentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Stream<MPS<CommentMutation, Comment>> runNotifierBuild(
    covariant MutableComment notifier,
  ) {
    return notifier.build(
      id: id,
    );
  }

  @override
  Override overrideWith(MutableComment Function() create) {
    return ProviderOverride(
      origin: this,
      override: MutableCommentProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<MutableComment,
      MPS<CommentMutation, Comment>> createElement() {
    return _MutableCommentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MutableCommentProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MutableCommentRef
    on AutoDisposeStreamNotifierProviderRef<MPS<CommentMutation, Comment>> {
  /// The parameter `id` of this provider.
  String get id;
}

class _MutableCommentProviderElement
    extends AutoDisposeStreamNotifierProviderElement<MutableComment,
        MPS<CommentMutation, Comment>> with MutableCommentRef {
  _MutableCommentProviderElement(super.provider);

  @override
  String get id => (origin as MutableCommentProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
