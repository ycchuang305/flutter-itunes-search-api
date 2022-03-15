import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/application/audio_player/audio_player_cubit.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/domain/song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockSongCubit extends MockCubit<SongState> implements SongCubit {}

class MockConcatenatingAudioSource extends Fake
    implements ConcatenatingAudioSource {}

void main() {
  late MockAudioPlayer mockAudioPlayer;
  late MockSongCubit mockSongCubit;
  late AudioPlayerCubit audioPlayerCubit;

  const fakeSong = Song(
    artistName: 'artistName',
    collectionName: 'collectionName',
    trackName: 'trackName',
    artworkUrl100: 'artworkUrl',
    previewUrl: 'https://foo.com/bar.mp3',
  );

  setUpAll(() {
    registerFallbackValue(MockConcatenatingAudioSource());
  });

  setUp(
    () {
      mockAudioPlayer = MockAudioPlayer();
      mockSongCubit = MockSongCubit();
      audioPlayerCubit = AudioPlayerCubit(
        audioPlayer: mockAudioPlayer,
        songCubit: mockSongCubit,
      );
      when(() => mockAudioPlayer.dispose()).thenAnswer((_) async => {});
    },
  );

  group(
    '[AudioPlayerCubit] stream subscription@init:',
    () {
      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'emits the state with same audioplayer status from playerStateStream',
        setUp: () {
          when(() => mockAudioPlayer.playerStateStream).thenAnswer(
            (_) => Stream.fromIterable([
              PlayerState(false, ProcessingState.idle),
              PlayerState(false, ProcessingState.loading),
              PlayerState(false, ProcessingState.buffering),
              PlayerState(false, ProcessingState.ready),
              PlayerState(true, ProcessingState.ready),
              PlayerState(false, ProcessingState.completed),
            ]),
          );
          when(() => mockAudioPlayer.currentIndexStream).thenAnswer(
            (_) => Stream.value(null),
          );
          whenListen(mockSongCubit, Stream.value(SongState.initial()));
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.init(),
        expect: () => [
          AudioPlayerState.initial(),
          AudioPlayerState.initial()
              .copyWith(status: const AudioPlayerStatus.loading()),
          AudioPlayerState.initial()
              .copyWith(status: const AudioPlayerStatus.buffering()),
          AudioPlayerState.initial()
              .copyWith(status: const AudioPlayerStatus.ready()),
          AudioPlayerState.initial()
              .copyWith(status: const AudioPlayerStatus.playing()),
          AudioPlayerState.initial()
              .copyWith(status: const AudioPlayerStatus.completed()),
        ],
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'emits the state with currentIndex from currentIndexStream',
        setUp: () {
          when(() => mockAudioPlayer.playerStateStream).thenAnswer(
            (_) => Stream.value(
              PlayerState(false, ProcessingState.idle),
            ),
          );
          when(() => mockAudioPlayer.currentIndexStream).thenAnswer(
            (_) => Stream.value(1),
          );
          whenListen(mockSongCubit, Stream.value(SongState.initial()));
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.init(),
        expect: () => [
          AudioPlayerState.initial(),
          AudioPlayerState.initial().copyWith(currentIndex: 1),
        ],
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'emits the state with playList from songCubit when it fetched songs',
        setUp: () {
          var playList = [fakeSong];
          when(() => mockAudioPlayer.playerStateStream).thenAnswer(
            (_) => Stream.value(
              PlayerState(false, ProcessingState.idle),
            ),
          );
          when(() => mockAudioPlayer.currentIndexStream).thenAnswer(
            (_) => Stream.value(null),
          );
          whenListen(
            mockSongCubit,
            Stream.value(
              SongState(status: const SongStatus.success(), songs: playList),
            ),
          );
          when(
            () => mockAudioPlayer.setAudioSource(
              any(),
              initialIndex: 0,
            ),
          ).thenAnswer((_) async => const Duration());
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.init(),
        expect: () => [
          AudioPlayerState.initial(),
          AudioPlayerState.initial().copyWith(playList: [fakeSong]),
        ],
      );
    },
  );

  group(
    '[AudioPlayerCubit] player actions:',
    () {
      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'invoke audioPlayer.play() once',
        setUp: () {
          when(mockAudioPlayer.play).thenAnswer((_) async {});
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.play(),
        verify: (_) {
          verify(mockAudioPlayer.play).called(1);
        },
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'invoke audioPlayer.pause() once',
        setUp: () {
          when(mockAudioPlayer.pause).thenAnswer((_) async {});
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.pause(),
        verify: (_) {
          verify(mockAudioPlayer.pause).called(1);
        },
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'invoke audioPlayer.seekToNext() once',
        setUp: () {
          when(() => mockAudioPlayer.hasNext).thenReturn(true);
          when(mockAudioPlayer.seekToNext).thenAnswer((_) async {});
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.seekToNext(),
        verify: (_) {
          verify(mockAudioPlayer.seekToNext).called(1);
        },
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'invoke audioPlayer.seekToPrevious() once',
        setUp: () {
          when(() => mockAudioPlayer.hasPrevious).thenReturn(true);
          when(mockAudioPlayer.seekToPrevious).thenAnswer((_) async {});
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.seekToPrevious(),
        verify: (_) {
          verify(mockAudioPlayer.seekToPrevious).called(1);
        },
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'invoke audioPlayer.seek() once with zero duration',
        setUp: () {
          when(() => mockAudioPlayer.seek(Duration.zero))
              .thenAnswer((_) async {});
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.seekToStart(),
        verify: (_) {
          verify(() => mockAudioPlayer.seek(Duration.zero)).called(1);
        },
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'seek to a particular song@index with zero duration, and then play it',
        setUp: () {
          when(() => mockAudioPlayer.seek(Duration.zero, index: 1))
              .thenAnswer((_) async {});
          when(mockAudioPlayer.play).thenAnswer((_) async {});
        },
        build: () => audioPlayerCubit,
        act: (cubit) => cubit.seekToIndex(index: 1),
        verify: (_) {
          verify(() => mockAudioPlayer.seek(Duration.zero, index: 1)).called(1);
          verify(mockAudioPlayer.play).called(1);
        },
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'reload new playlist and play the song@index',
        setUp: () {
          when(() => mockAudioPlayer.seek(Duration.zero, index: 1))
              .thenAnswer((_) async {});
          when(mockAudioPlayer.play).thenAnswer((_) async {});
          when(
            () => mockAudioPlayer.setAudioSource(
              any(),
              initialIndex: 1,
            ),
          ).thenAnswer((_) async => const Duration());
        },
        build: () => audioPlayerCubit,
        act: (cubit) {
          cubit.canReloadPlayList = true;
          cubit.seekToIndex(index: 1, playList: [fakeSong]);
        },
        verify: (_) {
          verify(
            () => mockAudioPlayer.setAudioSource(
              any(),
              initialIndex: 1,
            ),
          ).called(1);
          verify(mockAudioPlayer.play).called(1);
        },
      );

      blocTest<AudioPlayerCubit, AudioPlayerState>(
        'emit failure status on load failed',
        setUp: () {
          when(() => mockAudioPlayer.seek(Duration.zero, index: 1))
              .thenAnswer((_) async {});
          when(mockAudioPlayer.play).thenAnswer((_) async {});
          when(
            () => mockAudioPlayer.setAudioSource(
              any(),
              initialIndex: 1,
            ),
          ).thenThrow(Exception('oops'));
        },
        build: () => audioPlayerCubit,
        act: (cubit) {
          cubit.canReloadPlayList = true;
          cubit.seekToIndex(index: 1, playList: [fakeSong]);
        },
        verify: (_) {
          verify(
            () => mockAudioPlayer.setAudioSource(
              any(),
              initialIndex: 1,
            ),
          ).called(1);
          verify(mockAudioPlayer.play).called(1);
        },
        expect: () => [
          AudioPlayerState.initial().copyWith(playList: [fakeSong]),
          AudioPlayerState.initial().copyWith(
            status: const AudioPlayerStatus.failure(),
            playList: [fakeSong],
          ),
        ],
      );
    },
  );
}
