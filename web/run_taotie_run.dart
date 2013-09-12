import 'dart:html' as html;
import 'dart:math';
import 'package:stagexl/stagexl.dart';
import '../lib/game.dart';

Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;

Bitmap _loadingBitmap;
Tween _loadingBitmapTween;
TextField _loadingTextField;

void main() {
  stage = new Stage("Stage", html.query('#stage'));
  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  BitmapData.load("images/LOADING.png").then((bitmapData) {

    _loadingBitmap = new Bitmap(bitmapData)
      ..pivotX = 20
      ..pivotY = 20
      ..x      = 400
      ..y      = 270;
    stage.addChild(_loadingBitmap);

    _loadingTextField = new TextField()
      ..defaultTextFormat = new TextFormat("Arial", 20, 0xA0A0A0, bold:true)
      ..width  = 240
      ..height = 40
      ..text   = "... loading ...";
    _loadingTextField
      ..x      = 400 - _loadingTextField.textWidth / 2
      ..y      = 320
      ..mouseEnabled = false;
    stage.addChild(_loadingTextField);

    _loadingBitmapTween = new Tween(_loadingBitmap, 100, TransitionFunction.linear)
      ..animate.rotation.to(100.0 * 2.0 * PI);
    renderLoop.juggler.add(_loadingBitmapTween);

    loadResources();
  });
}

void loadResources() {
  var taotie = Characters.TAOTIE;
  var boss   = Characters.BOSS;

  resourceManager = new ResourceManager()
    // ui elements
    ..addBitmapData("dialog",             "images/DIALOG.png")
    ..addBitmapData("ok_button",          "images/OK_BUTTON.png")
    ..addBitmapData("ok_button_hover",    "images/OK_BUTTON_HOVER.png")
    ..addBitmapData("background",         "images/BACKGROUND.png")

    ..addBitmapData("starium",            "images/STARIUM.png")
    ..addBitmapData("trap",               "images/SPIRIT_TABLET.png")
    ..addBitmapData(taotie,               "images/TAOTIE.png")
    ..addBitmapData("${taotie}_dialog",   "images/TAOTIE_DIALOG.png")
    ..addBitmapData("${taotie}_name_tag", "images/TAOTIE_NAME_TAG.png")
    ..addBitmapData(boss,                 "images/TAOTIE.png")
    ..addBitmapData("${boss}_overlay",    "images/BOSS_OVERLAY.png")
    ..addBitmapData("${boss}_dialog",     "images/TAOTIE_DIALOG.png")
    ..addBitmapData("${boss}_name_tag",   "images/BOSS_NAME_TAG.png")
    ..addBitmapData("end_game",           "images/END_GAME.png");

  resourceManager.load().then((_) {

    stage.removeChild(_loadingBitmap);
    stage.removeChild(_loadingTextField);
    renderLoop.juggler.remove(_loadingBitmapTween);

    stage.addChild(new Game(resourceManager));
  }).catchError((error) {
    for(var resource in resourceManager.failedResources) {
      print("Loading resouce failed: ${resource.kind}.${resource.name} - ${resource.error}");
    }
  });
}