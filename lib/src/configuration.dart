part of run_taotie_run;

class Configuration {
  static const int    NUM_OF_TAOTIES        = 5;
  static const double INIT_MIN_STARIUM_TIME = 5.0;
  static const double INIT_MAX_STARIUM_TIME = 8.0;

  static const int    TAOTIE_MOVE_DELAY     = 100;
  static const int    STARIUM_SPAWN_FREQ    = 3;  // how frequently (seconds) to spawn new starium
  static const int    STARIUM_SHOWER_FREQ   = 8;  // how frequently (seconds) a new shower starts
  static const int    STARIUM_SPEED_UP_FREQ = 12; // how frequently (seconds) stariums speed up
}