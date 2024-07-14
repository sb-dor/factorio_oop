import 'package:factorio_oop/crafting/logistic/chests/wooden_chest.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/resources/trees/green_tree.dart';
import 'package:factorio_oop/resources/trees/tree.dart';
import 'package:factorio_oop/resources/trees/wood.dart';

void main(List<String> arguments) {
  final woods = List.generate(2, (e) => Wood());
  final WoodenChest woodenChest = WoodenChest();

  woodenChest.ingredients.addAll(woods);

  woodenChest.produce().listen((e) {
    print(e);
  });
}
