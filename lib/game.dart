library run_taotie_run;

import 'dart:async';
import 'dart:html' as html;
import 'dart:math';
import 'package:stagexl/stagexl.dart';
import 'package:stream_ext/stream_ext.dart';

part "src/button.dart";
part "src/characters.dart";
part "src/cherry.dart";
part "src/configuration.dart";
part "src/dialog.dart";
part "src/dialog_window.dart";
part "src/events.dart";
part "src/mixins.dart";
part "src/score_board.dart";
part "src/score_zone.dart";
part "src/starium.dart";
part "src/taotie.dart";

class Game extends Sprite {
  ResourceManager _resourceManager;
  StreamSubscription  _enterFrameSubscription;
  Random _random = new Random();

  num _stageWidth, _stageHeight;

  int _numOfTaoties       = Configuration.NUM_OF_TAOTIES;
  double _minStariumTime  = Configuration.INIT_MIN_STARIUM_TIME;
  double _maxStariumTime  = Configuration.INIT_MAX_STARIUM_TIME;
  List<Taotie> _taoties   = new List<Taotie>();
  List<StreamSubscription> _taotieStreams = new List<StreamSubscription>();
  List<Starium> _stariums = new List<Starium>();
  List<Cherry> _cherries  = new List<Cherry>();
  List<Timer> _timers     = new List<Timer>();

  Sound _taotieBreakSound, _stariumSound, _eatCherrySound;

  bool _playSound = false;

  Game(this._resourceManager) {
    new Bitmap(_resourceManager.getBitmapData("background"))
      ..addTo(this);

    new DialogWindow(_resourceManager)
      ..x = 8
      ..y = 300
      ..addTo(this);

    new ScoreBoard(_resourceManager, 0, 0)
      ..addTo(this);

    _taotieBreakSound = _resourceManager.getSound("${Characters.TAOTIE}_break");
    _stariumSound     = _resourceManager.getSound("starium_spawn");
    _eatCherrySound   = _resourceManager.getSound("eat_cherry");

    onAddedToStage.listen((_) => _start());
  }

  _start() {
    _stageWidth  = stage.width;
    _stageHeight = stage.height;

    _showIntro()
      .then((_) => Configuration.SCORE_ZONES.forEach(addChild))
      .then((_) => _setupTaoties())
      .then((_) => _setupStariums())
      .then((_) => Mouse.hide())
      .then((_) => _enterFrameSubscription = onEnterFrame.listen(_onEnterFrame))
      .then((_) => _setupCherrys());
  }

  Future _showIntro() {
    var introDialogs = [
      new Dialog(Characters.BOSS,
                 [ "Lads, here we are, the promised land!"]),
      new Dialog(Characters.TAOTIE,
                 [ "erm..",
                   "..Boss..",
                   "..looks like someone cleaned this place up pretty good.." ]),
      new Dialog(Characters.BOSS,
                 [ "Darn!"]),
      new Dialog(Characters.TAOTIE,
                 [ "erm..",
                   "..Boss..",
                   "..not to stress you out or anything.."
                   "..but it looks like we have a STARIUM shower inbound.." ]),
      new Dialog(Characters.BOSS,
                 [ "Don't get hit by them STARIUMs or you'll CRACK!!",
                   "Follow me lads, I have a cunning plan..",
                   "...",
                   "RUN!!" ])];
    return DialogWindow.Singleton
              .showDialogs(introDialogs)
              .catchError((err) => print("Error playing the intro dialogs : $err"));
  }

  _setupTaoties() {
    var mousePos         = mousePosition;
    var mouseMove        = html.document.onMouseMove;
    var taotieBackground = _resourceManager.getBitmapData(Characters.TAOTIE);

    var maxX = _stageWidth - taotieBackground.width;
    var maxY = _stageHeight - taotieBackground.height;

    void setPosition (Taotie taotie, int index, num baseX, num baseY) {
      taotie
        ..x = min(maxX, baseX + index * taotie.width / 2)
        ..y = min(maxY, baseY);
    }

    for (var i = _numOfTaoties-1; i >= 0; i--) {
      // the first taotie is the boss
      var taotie = new Taotie(_resourceManager, i == 0)
        ..addTo(this);
      setPosition(taotie, i, mousePos.x, mousePos.y);
      _taoties.add(taotie);

      var streamSub = StreamExt
                        .delay(mouseMove, new Duration(milliseconds : i * Configuration.TAOTIE_MOVE_DELAY))
                        .listen((evt) => setPosition(taotie, i, evt.offset.x, evt.offset.y));
      _taotieStreams.add(streamSub);
    }

    Taotie.onHit.listen((HitEvent evt) {
      evt.starium.explode();

      removeChild(evt.taotie);
      _taoties.remove(evt.taotie);

      if (_playSound) _taotieBreakSound.play(false);

      if (evt.taotie.isBoss) {
        _gameOver();
      } else {
        // once the taotie object's removed, let's play the taotie break flipbook in its place to show
        // taotie breaking!
        var textureAtlas = _resourceManager.getTextureAtlas("${Characters.TAOTIE}_break_atlas");
        var bitmapDatas = textureAtlas.getBitmapDatas("BREAK");
        var flipBook = new FlipBook(bitmapDatas, 3)
          ..x = evt.taotie.x
          ..y = evt.taotie.y
          ..loop = false
          ..addTo(this)
          ..play();

        stage.juggler.add(flipBook);
        flipBook.onComplete.listen((_) {
          removeChild(flipBook);
          stage.juggler.remove(flipBook);
        });
      }
    });
  }

  _spawnStarium() {
    var speed = _random.nextDouble() * (_maxStariumTime - _minStariumTime) + _minStariumTime;
    var starium = new Starium(_resourceManager, _stageWidth, _stageHeight, speed)
      ..addTo(this)
      ..start();

    if (_playSound) _stariumSound.play(false);

    _stariums.add(starium);
  }

  _setupStariums() {
    Duration getSpawnFreq () => new Duration(seconds : _random.nextInt(Configuration.STARIUM_SPAWN_FREQ) + 1);
    var showerFreq = new Duration(seconds : Configuration.STARIUM_SHOWER_FREQ);

    _timers.add(new Timer.periodic(getSpawnFreq(), (_) => _spawnStarium()));

    // every couple of seconds add another shower that spawns stariums regularly
    var showerTimer = new Timer.periodic(showerFreq, (_) {
      _timers.add(new Timer.periodic(getSpawnFreq(), (_) => _spawnStarium()));
    });
    _timers.add(showerTimer);

    // every 12 seconds speed up the stariums
    var speedUpFreq  = new Duration(seconds : Configuration.STARIUM_SPEED_UP_FREQ);
    var speedUpTimer = new Timer.periodic(speedUpFreq, (_) {
      _minStariumTime = max(1.0, _minStariumTime - 1.0);
      _maxStariumTime = max(2.0, _maxStariumTime - 1.0);
    });
    _timers.add(speedUpTimer);

    Starium.onDisposed.listen((starium) {
      _stariums.remove(starium);
      removeChild(starium);
    });
  }

  _removeCherry(Cherry cherry, [ bool eat = false ]) {
    if (_cherries.contains(cherry)) {
      removeChild(cherry);
      _cherries.remove(cherry);

      if (eat) {
        _eatCherrySound.play(false);
        ScoreBoard.Singleton.addScore(Configuration.FRUIT_SCORE);
      }
    }
  }

  _spawnCherry() {
    var cherry = new Cherry(_resourceManager, Configuration.FRUIT_SCORE);
    cherry
      ..x = _random.nextInt((_stageWidth - cherry.width).toInt())
      ..y = _random.nextInt((_stageHeight - cherry.height).toInt());
    addChildAt(cherry, 1);
    _cherries.add(cherry);

    stage.juggler.delayCall(() => _removeCherry(cherry), Configuration.FRUIT_DURATION);
  }

  Future _setupCherrys() {
    int getDelay () => Configuration.MIN_FRUIT_TIME + _random.nextInt(Configuration.MAX_FRUIT_TIME - Configuration.MIN_FRUIT_TIME);

    return new Future.delayed(new Duration(seconds : getDelay()), _spawnCherry)
                .then((_) => _setupCherrys());
  }

  _score(Taotie taotie) {
    var scoreZone = Configuration.SCORE_ZONES.firstWhere((x) => taotie.hitTestObject(x), orElse : () => null);
    return scoreZone.score;
  }

  _onEnterFrame(_) {
    _taoties.forEach((taotie) => taotie.hitTest(_stariums));

    new List.from(_cherries)
          .where((cherry) => _taoties.any((taotie) => taotie.hitTestObject(cherry)))
          .forEach((cherry) => _removeCherry(cherry, true));

    var newScore = _taoties.map(_score).reduce((acc, elem) => acc + elem);
    ScoreBoard.Singleton.addScore(newScore);
  }

  _gameOver() {
    _enterFrameSubscription.cancel();

    _timers.forEach((t) => t.cancel());
    _taotieStreams.forEach((sub) => sub.cancel());

    Mouse.show();

    var outroDialogs = new List<Dialog>();
    outroDialogs.add(new Dialog(Characters.BOSS, [ "ARRRGGGHHH..." ]));

    if (_taoties.length > 1) {
      outroDialogs.add(new Dialog(Characters.TAOTIE, ["BBBOOOOOSSSSSSSS!!!!"]));
    }

    DialogWindow.Singleton
      .showDialogs(outroDialogs)
      .then((_) {
        var overlay = new Bitmap(_resourceManager.getBitmapData("game_over"));
        addChild(overlay);
      });
  }
}