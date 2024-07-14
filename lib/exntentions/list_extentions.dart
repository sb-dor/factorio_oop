extension ListExtentions on List {
  List<T?> castAsType<T>() {
    return map((e) => e as T).toList();
  }
}
