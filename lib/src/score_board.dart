part of run_taotie_run;

class ScoreBoard extends Sprite {
  ResourceManager _resourceManager;
  int _labelY = 10;
  int _scoreY = 30;
  TextFormat _textFormat = new TextFormat("Calibri", 25, Color.Black, bold : true);
  TextField _scoreTextField;
  TextField _hiScoreTextField;
  TextField _globalHiScoreTextField;

  int score;
  int highScore;
  int globalHighScore;

  static ScoreBoard Singleton;

  factory ScoreBoard(resourceManager, highScore, globalHighScore) {
    return Singleton != null
            ? Singleton
            : new ScoreBoard._internal(resourceManager, highScore, globalHighScore);
  }

  ScoreBoard._internal(this._resourceManager, this.highScore, this.globalHighScore) {
    score = 0;
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
    }
  }

  _addScoreLabels() {
    new TextField()
    ..x = 100
    ..y = _labelY
    ..text = "SCORE"
    ..autoSize = TextFieldAutoSize.CENTER
    ..defaultTextFormat = _textFormat
    ..addTo(this);

    new TextField()
      ..x = 300
      ..y = _labelY
      ..text = "HI-SCORE"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);

    new TextField()
      ..x = 500
      ..y = _labelY
      ..text = "GLOBAL HI-SCORE"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);
  }

  _addScores() {
    _scoreTextField = new TextField()
      ..x = 100
      ..y = _scoreY
      ..text = "$score"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);

    _hiScoreTextField = new TextField()
      ..x = 300
      ..y = _scoreY
      ..text = "$highScore"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);

    _globalHiScoreTextField = new TextField()
      ..x = 500
      ..y = _scoreY
      ..text = "$globalHighScore"
      ..autoSize = TextFieldAutoSize.CENTER
      ..defaultTextFormat = _textFormat
      ..addTo(this);
  }
}