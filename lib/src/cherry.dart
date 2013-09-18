part of run_taotie_run;

class Cherry extends Sprite {
  ResourceManager _resourceManager;
  int score;

  static Rectangle _hitArea = new Rectangle(0, 22, 48, 51);

  Cherry(this._resourceManager, this.score) {
    new Bitmap(_resourceManager.getBitmapData("cherry"))
      ..addTo(this);
  }

  // use a rectangular bound to cover just the cherry meat
  Rectangle getBounds(DisplayObject targetSpace) {
    var rect = new Rectangle.from(_hitArea);
    rect.offset(x, y);

    return rect;
  }
}