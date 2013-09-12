part of run_taotie_run;

class Starium extends Sprite {
  static StreamController<Starium> _onDisposedController = new StreamController<Starium>.broadcast(sync : true);

  ResourceManager _resourceManager;
  Random _random   = new Random();
  bool _isDisposed = false;

  Bitmap _background;
  num _speed;
  num _startX;
  num _destinationX;
  Tween _animation;

  /// speed = number of seconds it takes to traverse the height of the screen
  Starium(this._resourceManager, this._speed) {
    _background = new Bitmap(_resourceManager.getBitmapData("starium"))
      ..addTo(this);
  }

  static Stream<Starium> get onDisposed => _onDisposedController.stream;

  void start() {
    _startX = _random.nextInt(stage.width.toInt());
    x       = _startX;
    y       = -_background.height;

    // the starium has to travel at least 1/4 the length of the screen
    var minDistance = stage.width / 4;
    do {
      _destinationX = _random.nextInt(stage.width.toInt());
    } while ((_startX - _destinationX).abs() < minDistance);

    // flip the image if we're going from right to left
    if (_startX > _destinationX) _background.scaleX = -1;

    _animation = stage.juggler.tween(this, _speed)
                    ..animate.x.to(_destinationX)
                    ..animate.y.to(stage.height)
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