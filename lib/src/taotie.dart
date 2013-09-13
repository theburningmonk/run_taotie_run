part of run_taotie_run;

class Taotie extends Sprite {
  static StreamController<HitEvent> _onHitController = new StreamController<HitEvent>.broadcast();

  ResourceManager _resourceManager;
  bool isBoss;

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
    var hitStarium = stariums.firstWhere((starium) => starium.hitTestObject(this), orElse : () => null);

    if (hitStarium != null) {
      _onHitController.add(new HitEvent(this, hitStarium));
    }
  }
}