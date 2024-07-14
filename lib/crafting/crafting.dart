import 'package:factorio_oop/resource.dart';

abstract class Crafting extends Resource {
  final Duration produceDuration;

  Crafting(this.produceDuration);

  Stream<Resource?> produce();
}
