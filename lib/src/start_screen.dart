part of run_taotie_run;

class StartScreen extends Sprite {
  ResourceManager _resourceManager;
  Completer _completer = new Completer();

  StartScreen(this._resourceManager) {
    var background = new Bitmap(_resourceManager.getBitmapData("start_screen"));
    addChild(background);
  }

  Future show() {
    return _completer.future;
  }
}