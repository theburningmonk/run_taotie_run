part of run_taotie_run;

class TutorialScreen extends Sprite {
  ResourceManager _resourceManager;
  Completer _completer = new Completer();

  Bitmap _background;
  List<Bitmap> _tutorials;
  int _index = 0;
  Button _nextButton;

  TutorialScreen(this._resourceManager) {
    _tutorials =
      [
        new Bitmap(_resourceManager.getBitmapData("tutorial_1")),
        new Bitmap(_resourceManager.getBitmapData("tutorial_2")),
        new Bitmap(_resourceManager.getBitmapData("tutorial_3"))
      ];
  }

  Future show() {
    _background = _tutorials[0];
    this.addChild(_background);

    var next = new Bitmap(_resourceManager.getBitmapData("next"));
    var nextHover = new Bitmap(_resourceManager.getBitmapData("next_hover"));
    _nextButton = new Button(next, nextHover, nextHover)
      ..x = 700
      ..y = 455
      ..addTo(this);

    _nextButton.onMouseDown.listen(_onNext);

    return _completer.future;
  }

  _onNext(_) {
    _index++;
    removeChild(_background);

    if (_index < _tutorials.length) {
      _background = _tutorials[_index];
      addChildAt(_background, 0);
    } else {
      _completer.complete(this);
    }
  }
}