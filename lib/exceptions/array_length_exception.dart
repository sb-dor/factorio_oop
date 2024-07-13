class ArrayLengthException implements Exception {
  final String message;

  ArrayLengthException(this.message);

  void call() {
    throw ArrayLengthException(message);
  }

  // create this toString function in order to show the error message
  // that you created
  @override
  String toString() {
    return message;
  }
}
