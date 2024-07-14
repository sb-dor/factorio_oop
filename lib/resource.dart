// abstract class can be "extended" and "implemented"
// but "base" classes only for extend
// "interface" class for implementation
abstract class Resource {
  @override
  String toString() {
    return "Resource is -> $runtimeType";
  }
}
