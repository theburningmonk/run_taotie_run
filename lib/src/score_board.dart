part of run_taotie_run;

class ScoreBoard {
  ResourceManager _resourceManager;

  ScoreBoard(this._resourceManager) {
    var background = new Bitmap(_resourceManager.getBitmapData("score_board"));
  }


}