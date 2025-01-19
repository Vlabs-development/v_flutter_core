extension ScopingFunctionExtensions<T> on T {
  R let<R>(R Function(T it) block) {
    return block(this);
  }

  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  T apply(void Function(T self) block) {
    block(this);
    return this;
  }

  R run<R>(R Function(T self) block) {
    return block(this);
  }
}

extension NullSafeScopingFunctionExtensions<T> on T? {
  R? maybeLet<R>(R Function(T it) block) {
    final value = this;
    return value != null ? block(value) : null;
  }
}
