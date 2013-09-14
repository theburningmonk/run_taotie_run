part of run_taotie_run;

class Cherry extends Sprite {
  ResourceManager _resourceManager;
  int score;

  Cherry(this._resourceManager, this.score) {
    new Bitmap(_resourceManager.getBitmapData("cherry"))
      ..addTo(this);
  }
}