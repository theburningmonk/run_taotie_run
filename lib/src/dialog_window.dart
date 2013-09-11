part of run_taotie_run;

class DialogWindow extends Sprite {
  ResourceManager _resourceManager;

  Bitmap _background;
  Button _ok;
  TextField _textField;
  Bitmap _character;
  Bitmap _nameTag;

  static DialogWindow Singleton;

  factory DialogWindow(resourceManager) {
    return Singleton != null ? Singleton : new DialogWindow._internal(resourceManager);
  }

  DialogWindow._internal(this._resourceManager) {
    _background = new Bitmap(_resourceManager.getBitmapData("dialog"));
    addChild(_background);

    var okButton      = new Bitmap(_resourceManager.getBitmapData("ok_button"));
    var okButtonHover = new Bitmap(_resourceManager.getBitmapData("ok_button_hover"));

    _ok = new Button(okButton, okButtonHover, okButtonHover)
      ..x = 603
      ..y = 179;
    addChild(_ok);

    _textField = new TextField("", new TextFormat("Calibri", 28, Color.Black, bold : true))
      ..x = 263
      ..y = 54
      ..width = 500
      ..wordWrap = true;
    addChild(_textField);

    visible = false;

    Singleton = this;
  }

  Future showDialog(Dialog dialog, { bool autoHide }) {
    if (autoHide == null) {
      autoHide = true;
    }

    if (dialog.Texts.length == 0) {
      return new Future.value();
    }

    _character = new Bitmap(_resourceManager.getBitmapData("${dialog.Character}_dialog"))
      ..x = 11
      ..y = 30;
    addChild(_character);

    _nameTag = new Bitmap(_resourceManager.getBitmapData("${dialog.Character}_name_tag"))
      ..x = 235
      ..y = -30;
    addChild(_nameTag);

    visible = true;

    Completer completer = new Completer();

    int messageIdx = 0;
    _textField.text = dialog.Texts[messageIdx];

    void nextMessage(_) {
      messageIdx++;
      if (messageIdx >= dialog.Texts.length) {
        _textField.text = "";
        removeChild(_character);
        removeChild(_nameTag);

        if (autoHide) {
          visible = false;
        }

        completer.complete();
      }
      else {
        _textField.text = dialog.Texts[messageIdx];
      }
    };

    var okClickSub = _ok.onMouseDown.listen(nextMessage);
    var keyUpSub   = onKeyUp.listen((evt) {
      if (evt.keyCode == html.KeyCode.ENTER || evt.keyCode == html.KeyCode.SPACE) {
        nextMessage(evt);
      }
    });

    return completer.future.then((_) {
      okClickSub.cancel();
      keyUpSub.cancel();
    });
  }

  Future showDialogs(List<Dialog> dialogs) {
    stage.focus = this;

    Future future = new Future.sync(() {});
    for (var i = 0; i < dialogs.length; i++) {
      future = future.then((_) => showDialog(dialogs[i], autoHide : false));
    }

    return future.then((_) => visible = false);
  }
}