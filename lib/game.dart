library run_taotie_run;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'package:stream_ext/stream_ext.dart';

part "src/button.dart";
part "src/characters.dart";
part "src/dialog.dart";
part "src/dialog_window.dart";

class Game extends Sprite {
  ResourceManager _resourceManager;
  int taoties = 8;

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
    var taotieBitmapData = _resourceManager.getBitmapData(Characters.TAOTIE);
    var mousePos         = mousePosition;
    var mouseMove        = html.document.onMouseMove;

    for (var i = 0; i < taoties; i++) {
      var taotie = new Bitmap(taotieBitmapData)
        ..x = mousePos.x + i * (taotieBitmapData.width + 10)
        ..y = mousePos.y
        ..addTo(this);

      StreamExt.delay(mouseMove, new Duration(milliseconds : i * 200), sync : true)
        ..listen((evt) {
          taotie
            ..x = evt.offset.x + i * (taotieBitmapData.width + 10)
            ..y = evt.offset.y;
        });
    }
  }
}