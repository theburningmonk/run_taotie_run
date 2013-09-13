part of run_taotie_run;

class Starium extends Sprite {
  static StreamController<Starium> _onDisposedController = new StreamController<Starium>.broadcast(sync : true);

  ResourceManager _resourceManager;
  Random _random   = new Random();
  bool _isDisposed = false;

  Bitmap _background;
  num _seconds;
  num _startX;
  num _destinationX;
  num _stageWidth;
  num _stageHeight;
  Tween _animation;

  Starium(this._resourceManager, this._stageWidth, this._stageHeight, this._seconds) {
    _background = new Bitmap(_resourceManager.getBitmapData("starium"))
      ..addTo(this);
  }

  static Stream<Starium> get onDisposed => _onDisposedController.stream;

  void start() {
    _startX = _random.nextInt(_stageWidth.toInt() * 2) - _stageWidth / 2;
    x       = _startX;
    y       = -_background.height;

    // the starium has to travel at least 1/4 the length of the screen
    var minDistance = _stageWidth / 4;
    do {
      _destinationX = _random.nextInt(_stageWidth.toInt() * 2) - _stageWidth / 2;
    } while ((_startX - _destinationX).abs() < minDistance);

    // flip the image if we're going from right to left
    if (_startX > _destinationX) _background.scaleX = -1;

    _animation = stage.juggler.tween(this, _seconds)
                    ..animate.x.to(_destinationX)
                    ..animate.y.to(_stageHeight)
                    ..onComplete = _dispose;
  }

  void explode() {
    _dispose();
  }

  _dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;

    if (!_animation.isComplete) {
      _animation.complete();
    }

    _onDisposedController.add(this);
  }
}