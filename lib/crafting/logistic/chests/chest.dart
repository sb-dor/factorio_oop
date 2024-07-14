import 'package:factorio_oop/crafting/crafting.dart';
import 'package:factorio_oop/exceptions/array_length_exception.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/inventory/slots/slot.dart';
import 'package:factorio_oop/resource.dart';

abstract base class Chest extends Crafting {
  // how many item can hold this chest
  final ArrayGeneric<Slot> slots;

  final ArrayGeneric<Resource> ingredients;

  Chest(
    super.produceDuration, {
    required this.slots,
    required this.ingredients,
  });

  @override
  Stream<Resource?> produce() async* {
    if (ingredients.listLength != ingredients.length) {
      throw ArrayLengthException("Not enough ingredients to create $runtimeType chest");
    }
  }
}
