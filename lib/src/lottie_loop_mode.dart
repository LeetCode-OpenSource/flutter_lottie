enum LottieLoopMode {
  PlayOnce,
  AutoReverse,
  Loop,
  Repeat,
  RepeatBackwards,
}

String decodeLottieLoopMode(LottieLoopMode mode) {
  switch (mode) {
    case LottieLoopMode.PlayOnce:
      return 'playOnce';
    case LottieLoopMode.AutoReverse:
      return 'autoReverse';
    case LottieLoopMode.Loop:
      return 'loop';
    case LottieLoopMode.Repeat:
      return 'repeat';
    case LottieLoopMode.RepeatBackwards:
      return 'repeatBackwards';
    default:
      return 'playOnce';
  }
}