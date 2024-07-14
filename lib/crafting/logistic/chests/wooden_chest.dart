import 'package:factorio_oop/crafting/logistic/chests/chest.dart';
import 'package:factorio_oop/exceptions/array_length_exception.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/inventory/slots/slot.dart';
import 'package:factorio_oop/resource.dart';
import 'package:factorio_oop/resources/trees/wood.dart';

// the wooden chest has about 16 slots inside
final class WoodenChest extends Chest {
  WoodenChest()
      : super(
          Duration(seconds: 2),
          slots: ArrayGeneric<Slot>(16),
          ingredients: ArrayGeneric<Wood>(2),
        );

  @override
  Stream<Resource?> produce() async* {
    yield* super.produce();
    await Future.delayed(produceDuration);
    yield WoodenChest();
  }
}
