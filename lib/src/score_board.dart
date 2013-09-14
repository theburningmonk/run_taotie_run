part of run_taotie_run;

class ScoreBoard extends Sprite {
  ResourceManager _resourceManager;
  int _labelY = 10;
  int _scoreY = 30;
  TextFormat _textFormat = new TextFormat("Calibri", 25, Color.Black, bold : true);
  TextField _scoreTextField;
  TextField _hiScoreTextField;
  TextField _globalHiScoreTextField;

  int score, highScore;
  String hiScoreKey = "hi-score";

  static ScoreBoard Singleton;

  factory ScoreBoard(resourceManager) {
    return Singleton != null
            ? Singleton
            : new ScoreBoard._internal(resourceManager);
  }

  ScoreBoard._internal(this._resourceManager) {
    score = 0;
    highScore = int.parse(html.window.localStorage.putIfAbsent(hiScoreKey, () => "0"));

    Singleton = this;

    _addScoreLabels();
    _addScores();
  }

  void addScore(int increment) {
    score += increment;
    _scoreTextField.text = "$score";

    if (score > highScore) {
      highScore = score;
      _hiScoreTextField.text = "$highScore";

      html.window.localStorage[hiScoreKey] = "$highScore";
    }
  }

  _addScoreLabels() {
    new TextField()
    ..x = 150
    ..y = _labelY
    ..text = "SCORE"
    ..autoSize = TextFieldAutoSize.CENTER
    ..defaultTextFormat = _textFormat
    ..addTo(this);

    new TextField()
      ..x = 500
      ..y = _labelY
      ..text = "HI-SCORE"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);
  }

  _addScores() {
    _scoreTextField = new TextField()
      ..x = 150
      ..y = _scoreY
      ..text = "$score"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);

    _hiScoreTextField = new TextField()
      ..x = 500
      ..y = _scoreY
      ..text = "$highScore"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);
  }
}