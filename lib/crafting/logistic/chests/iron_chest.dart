import 'package:factorio_oop/exceptions/array_length_exception.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/inventory/slots/slot.dart';
import 'package:factorio_oop/resource.dart';
import 'package:factorio_oop/resources/plates/iron_plate.dart';

import 'chest.dart';

// the iron chest has about 32 slots inside
final class IronChest extends Chest {
  IronChest()
      : super(
          Duration(seconds: 4),
          slots: ArrayGeneric<Slot>(32),
          ingredients: ArrayGeneric<IronPlate>(8),
        );

  @override
  Stream<Resource?> produce() async* {
    yield* super.produce();
    await Future.delayed(produceDuration, () async* {
      yield IronChest();
    });
  }
}
