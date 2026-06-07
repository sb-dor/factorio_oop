enum Direction {
  north,
  east,
  south,
  west;

  PositionOffset get offset {
    return switch (this) {
      Direction.north => const PositionOffset(0, -1),
      Direction.east => const PositionOffset(1, 0),
      Direction.south => const PositionOffset(0, 1),
      Direction.west => const PositionOffset(-1, 0),
    };
  }
}

final class PositionOffset {
  final int dx;
  final int dy;

  const PositionOffset(this.dx, this.dy);
}
