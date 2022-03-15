part of 'audio_player_cubit.dart';

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const AudioPlayerState._();
  const factory AudioPlayerState({
    required AudioPlayerStatus status,
    required List<Song> playList,
    required int currentIndex,
  }) = _AudioPlayerState;

  factory AudioPlayerState.initial() => const AudioPlayerState(
        status: AudioPlayerStatus.idle(),
        playList: <Song>[],
        currentIndex: 0,
      );

  bool get isPlaying => status == const AudioPlayerStatus.playing();
}

@freezed
class AudioPlayerStatus with _$AudioPlayerStatus {
  const factory AudioPlayerStatus.idle() = _Idle;
  const factory AudioPlayerStatus.loading() = _Loading;
  const factory AudioPlayerStatus.buffering() = _Buffering;
  const factory AudioPlayerStatus.ready() = _Ready;
  const factory AudioPlayerStatus.playing() = _Playing;
  const factory AudioPlayerStatus.completed() = _Completed;
  const factory AudioPlayerStatus.failure() = _Failure;
}
