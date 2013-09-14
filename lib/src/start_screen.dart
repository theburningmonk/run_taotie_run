part of run_taotie_run;

class StartScreen extends Sprite {
  ResourceManager _resourceManager;
  Completer _completer = new Completer();

  StartScreen(this._resourceManager) {
    var background = new Bitmap(_resourceManager.getBitmapData("start_screen"));
    addChild(background);

    var start       = new Bitmap(_resourceManager.getBitmapData("start"));
    var startHover  = new Bitmap(_resourceManager.getBitmapData("start_hover"));

    Button startButton = new Button(start, startHover, startHover)
      ..x = 50
      ..y = 400
      ..addTo(this);

    var howToPlay       = new Bitmap(_resourceManager.getBitmapData("how_to_play"));
    var howToPlayHover  = new Bitmap(_resourceManager.getBitmapData("how_to_play_hover"));

    var howToPlayButton = new Button(howToPlay, howToPlayHover, howToPlayHover)
      ..x = 50
      ..y = 460
      ..addTo(this);

    startButton.onMouseClick.listen((_) => _completer.complete(this));
    howToPlayButton.onMouseClick.listen((_) {
      var tutorialScreen = new TutorialScreen(_resourceManager)
        ..x = 5
        ..addTo(this);
      tutorialScreen.show()
        .then((_) => removeChild(tutorialScreen));
    });

    var hbmLogo = new Bitmap(_resourceManager.getBitmapData("hbm_logo"));
    new Button(hbmLogo, hbmLogo, hbmLogo)
      ..x = 590
      ..y = 535
      ..addTo(this)
      ..onMouseClick.listen((_) => html.window.open("http://apps.facebook.com/herebemonsters", "Here Be Monsters game"));

    var me = new Bitmap(_resourceManager.getBitmapData("me"));
    new Button(me, me, me)
      ..x = 602
      ..y = 489
      ..addTo(this)
      ..onMouseClick.listen((_) => html.window.open("https://twitter.com/theburningmonk", "Twitter"));
  }

  Future show() {
    return _completer.future;
  }
}