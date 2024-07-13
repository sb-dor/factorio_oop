import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/resources/resource.dart';

class Slot {
  // every slot can place only 100 items inside
  ArrayGeneric<Resource> resources = ArrayGeneric<Resource>(100);
}
