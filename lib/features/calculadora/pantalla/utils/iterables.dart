T? firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final x in items) {
    if (test(x)) return x;
  }
  return null;
}