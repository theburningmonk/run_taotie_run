library run_taotie_run;

import 'dart:async';
import 'dart:html' as html;
import 'dart:math';
import 'package:stagexl/stagexl.dart';
import 'package:stream_ext/stream_ext.dart';

part "src/button.dart";
part "src/characters.dart";
part "src/dialog.dart";
part "src/dialog_window.dart";
part "src/events.dart";
part "src/mixins.dart";
part "src/starium.dart";
part "src/taotie.dart";

class Game extends Sprite {
  ResourceManager _resourceManager;
  Random _random = new Random();

  num _stageWidth;
  num _stageHeight;

  int _numOfTaoties       = 5;
  double _minStariumTime  = 8.0;
  double _maxStariumTime  = 5.0;
  List<Taotie> _taoties   = new List<Taotie>();
  List<StreamSubscription> _taotieStreams = new List<StreamSubscription>();
  List<Starium> _stariums = new List<Starium>();

  List<Timer> _timers = new List<Timer>();

  Game(this._resourceManager) {
    new Bitmap(_resourceManager.getBitmapData("background"))
      ..addTo(this);

    var dialogWindow = new DialogWindow(_resourceManager)
      ..x = 8
      ..y = 300
      ..addTo(this);

    onAddedToStage.listen((_) => _start());
  }

  _start() {
    _stageWidth  = stage.width;
    _stageHeight = stage.height;

    _showIntro()
      .then((_) => _setupTaoties())
      .then((_) => _setupStariums())
      .then((_) => Mouse.hide());
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
                        .delay(mouseMove, new Duration(milliseconds : i * 100))
                        .listen((evt) => setPosition(taotie, i, evt.offset.x, evt.offset.y));
      _taotieStreams.add(streamSub);
    }

    Taotie.onHit.listen((HitEvent evt) {
      evt.starium.explode();

      removeChild(evt.taotie);

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

  _setupStariums() {
    _timers.add(new Timer.periodic(new Duration(seconds : 3), (_) => _spawnStarium()));

    // every 8 seconds add another second that spawns a starium every 1-3 seconds
    var launcherTimer = new Timer.periodic(new Duration(seconds : 8), (_) {
      var timer = new Timer.periodic(new Duration(seconds : _random.nextInt(3) + 1), (_) => _spawnStarium());
      _timers.add(timer);
    });
    _timers.add(launcherTimer);

    // every 12 seconds speed up the stariums
    var speedUpTimer = new Timer.periodic(new Duration(seconds : 12), (_) {
      _minStariumTime = max(1.0, _minStariumTime - 1.0);
      _maxStariumTime = max(2.0, _maxStariumTime - 1.0);
    });
    _timers.add(speedUpTimer);

    Starium.onDisposed.listen((starium) {
      _stariums.remove(starium);
      removeChild(starium);
    });

    onEnterFrame.listen((_) => _taoties.forEach((taotie) => taotie.hitTest(_stariums)));
  }

  _spawnStarium() {
    var speed = _random.nextDouble() * (_minStariumTime - _maxStariumTime) + _maxStariumTime;
    var starium = new Starium(_resourceManager, _stageWidth, _stageHeight, speed)
      ..addTo(this)
      ..start();

    _stariums.add(starium);
  }

  _gameOver() {
    _timers.forEach((t) => t.cancel());
    _taotieStreams.forEach((sub) => sub.cancel());

    Mouse.show();

    var outroDialogs = [
      new Dialog(Characters.BOSS,
                 [ "GRRRRR..." ]) ];

    DialogWindow.Singleton
      .showDialogs(outroDialogs)
      .then((_) => print("Game Over"));
  }
}