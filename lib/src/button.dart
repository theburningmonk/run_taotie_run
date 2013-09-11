part of run_taotie_run;

class Button extends Sprite {
  Bitmap _normal;
  Bitmap _hover;
  Bitmap _down;

  Button(this._normal, this._hover, this._down) {
    onMouseOver.listen(_onMouseOver);
    onMouseOut.listen(_onMouseOut);
    onMouseDown.listen(_onMouseDown);

    addChild(_normal);
  }

  _onMouseOver(_) {
    removeChildren(0);
    addChild(_hover);

    Mouse.cursor = MouseCursor.BUTTON;
  }

  _onMouseOut(_) {
    removeChildren(0);
    addChild(_normal);

    Mouse.cursor = MouseCursor.AUTO;
  }

  _onMouseDown(_) {
    removeChildren(0);
    addChild(_down);
  }
}