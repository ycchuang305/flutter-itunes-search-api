part of 'song_cubit.dart';

@freezed
class SongState with _$SongState {
  const SongState._();
  const factory SongState({
    required SongStatus status,
    @Default([]) List<Song> songs,
  }) = _SongState;

  factory SongState.initial() => const SongState(
        status: SongStatus.initial(),
        songs: <Song>[],
      );
}

@freezed
class SongStatus with _$SongStatus {
  const factory SongStatus.initial() = _Initial;
  const factory SongStatus.loading() = _Loading;
  const factory SongStatus.success() = _Success;
  const factory SongStatus.failure() = _Failure;
}
