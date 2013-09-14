part of run_taotie_run;

class ScoreZone extends Sprite {
  int score;

  int _width, _height;

  ScoreZone(this.score, this._width, this._height, int color) {
    Shape shape = new Shape()
      ..width = _width
      ..height = _height;
    addChild(shape);

    shape.graphics
      ..rect(0, 0, _width, _height)
      ..fillColor(color);

    visible = false;
  }
}