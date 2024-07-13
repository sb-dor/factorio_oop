import 'dart:collection';

import 'package:factorio_oop/exceptions/array_length_exception.dart';

class ArrayGeneric<T> {
  // length of the list that can hold items
  final int _length;

  int get length => _length;

  final List<T?> _currentList = [];

  UnmodifiableListView<T?> get currentList => UnmodifiableListView(_currentList);

  void add(T? resource) {
    _currentList.add(resource);

    if (_currentList.length > _length) {
      throw ArrayLengthException("List stack overflow exception");
    }
  }

  ArrayGeneric(this._length);
}
