final class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  Position translated({int dx = 0, int dy = 0}) => Position(x + dx, y + dy);

  @override
  bool operator ==(Object other) {
    return other is Position && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Position(x: $x, y: $y)';
}
