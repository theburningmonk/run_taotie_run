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
part "src/taotie.dart";

class Game extends Sprite {
  ResourceManager _resourceManager;
  int _numOfTaoties = 5;
  List<Taotie> _taoties = new List<Taotie>();

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
    _showIntro()
      .then((_) => _play());
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
      new Dialog(Characters.TAOTIE,
                 [ "Don't worry lads, I have a cunning plan..",
                   "...",
                   "RUN!!" ])];
    return DialogWindow.Singleton
              .showDialogs(introDialogs)
              .catchError((err) => print("Error playing the intro dialogs : $err"));
  }

  Future _play() {
    var mousePos         = mousePosition;
    var mouseMove        = html.document.onMouseMove;

    void setPosition (Taotie taotie, int index, num baseX, num baseY) {
      var maxX = stage.width - taotie.width;
      var maxY = stage.height - taotie.height;

      taotie
        ..x = min(maxX, baseX + index * (taotie.width + 5))
        ..y = min(maxY, baseY);
    }

    for (var i = _numOfTaoties-1; i >= 0; i--) {
      // the first taotie is the boss
      var taotie = new Taotie(_resourceManager, i == 0)
        ..addTo(this);
      setPosition(taotie, i, mousePos.x, mousePos.y);
      _taoties.add(taotie);

      StreamExt.delay(mouseMove, new Duration(milliseconds : i * 150))
        ..listen((evt) => setPosition(taotie, i, evt.offset.x, evt.offset.y));
    }
  }
}