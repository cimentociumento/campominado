const int kGridRows = 12;
const int kGridCols = 12;
const int kTotalMines = 20;

// Override with --dart-define=REAL_SHUTDOWN=false to use mock during development
const bool kUseRealShutdown =
    bool.fromEnvironment('REAL_SHUTDOWN', defaultValue: true);
