import 'package:factorio_oop/constants/constants.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/resource.dart';

class Slot {
  // every slot can place only 100 items inside
  ArrayGeneric<Resource> resources = ArrayGeneric<Resource>(Constants.resourcesLength);
}
