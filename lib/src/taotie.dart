part of run_taotie_run;

class Taotie extends Sprite {
  ResourceManager _resourceManager;

  Taotie(this._resourceManager, [ bool isBoss = false ]) {
    new Bitmap(_resourceManager.getBitmapData(Characters.TAOTIE))
      ..addTo(this);

    if (isBoss) {
      new Bitmap(_resourceManager.getBitmapData("${Characters.BOSS}_overlay"))
        ..addTo(this);
    }
  }
}