part of run_taotie_run;

class Taotie extends Sprite {
  static StreamController<HitEvent> _onHitController = new StreamController<HitEvent>.broadcast();

  ResourceManager _resourceManager;
  bool isBoss;
  static Point _hitCenter = new Point(38, 38);
  static int _hitRadius = 28;

  Taotie(this._resourceManager, [ bool this.isBoss = false ]) {
    new Bitmap(_resourceManager.getBitmapData(Characters.TAOTIE))
      ..addTo(this);

    if (isBoss) {
      new Bitmap(_resourceManager.getBitmapData("${Characters.BOSS}_overlay"))
        ..addTo(this);
    }
  }

  static Stream<HitEvent> get onHit => _onHitController.stream;

  void hitTest(List<Starium> stariums) {
    var hitStarium = stariums.firstWhere((starium) => this.hitTestObject(starium), orElse : () => null);

    if (hitStarium != null) {
      _onHitController.add(new HitEvent(this, hitStarium));
    }
  }

  /// override the hitTestObject to use a circle in the middle for hit test purposes
  bool hitTestObject(DisplayObject other) {
    if (other.stage == null) return false;

    var otherBounds = other.getBounds(stage);

    if (otherBounds.left   <= x &&
        otherBounds.top    <= y &&
        otherBounds.right  >= x + width  &&
        otherBounds.bottom >= y + height) {
      return true;
    }

    var center = new Point(x, y).add(_hitCenter);
    bool isHit (Point p) => p.distanceTo(center) <= _hitRadius;

    return isHit(otherBounds.topLeft) ||
           isHit(otherBounds.bottomRight) ||
           isHit(otherBounds.topLeft.add(new Point(0, otherBounds.height))) ||
           isHit(otherBounds.bottomRight.subtract(new Point(0, otherBounds.height)));
  }
}