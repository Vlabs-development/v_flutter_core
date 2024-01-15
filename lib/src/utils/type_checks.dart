// ignore_for_file: avoid_catching_errors

bool isStringType<T>() => typesEqual<String, T>();
bool isDynamic<T>() => typesEqual<dynamic, T>();
bool isNullableStringType<T>() => typesEqual<String?, T>() || typesEqual<String, T>();

bool isString(dynamic value) => value is String || tryCast<String>(value) != null;

bool isJsonMapType<T>() => typesEqual<Map<String, dynamic>, T>();
bool isJsonMap(dynamic value) => value is Map<String, dynamic> || tryCast<Map<dynamic, dynamic>>(value) != null;

bool isJsonListType<T>() => typesEqual<List<dynamic>, T>();
bool isJsonList(dynamic value) => value is List<dynamic> || tryCast<List<dynamic>>(value) != null;

T? tryCast<T>(dynamic value, {T? fallback}) {
  try {
    return value as T;
  } on TypeError catch (_) {
    return fallback;
  }
}

bool typesEqual<T1, T2>() => T1 == T2;

bool isVoid<T>() => typesEqual<void, T>();
bool isNullable<T>() => null is T;
