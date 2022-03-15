import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/domain/song.dart';
import 'package:itunes_search_api_example/domain/song_failure.dart';
import 'package:itunes_search_api_example/infrastructure/song_remote_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSongRemoteRepository extends Mock implements SongRemoteRepository {}

void main() {
  late MockSongRemoteRepository mockSongRemoteRepository;
  late SongCubit songCubit;

  setUp(() {
    mockSongRemoteRepository = MockSongRemoteRepository();
    songCubit = SongCubit(mockSongRemoteRepository);
  });

  group(
    '[SongCubit]',
    () {
      const fakeSong = Song(
        artistName: 'artistName',
        collectionName: 'collectionName',
        trackName: 'trackName',
        artworkUrl100: 'artworkUrl',
        previewUrl: 'previewUrl',
      );
      test('initial state is correct', () {
        expect(songCubit.state, SongState.initial());
      });

      blocTest<SongCubit, SongState>(
        'emits nothing when song is null',
        build: () => songCubit,
        act: (cubit) => cubit.fetchSongs(null),
        expect: () => <SongState>[],
      );

      blocTest<SongCubit, SongState>(
        'emits nothing when song is empty',
        build: () => songCubit,
        act: (cubit) => cubit.fetchSongs(''),
        expect: () => <SongState>[],
      );

      blocTest<SongCubit, SongState>(
        'emit [loading, failure] when songSearch throws',
        setUp: () {
          when(() => mockSongRemoteRepository.fetchSongs(any()))
              .thenAnswer((_) async => left(const SongFailure.api('oops')));
        },
        build: () => songCubit,
        act: (cubit) => cubit.fetchSongs('Test'),
        expect: () => <SongState>[
          const SongState(status: SongStatus.loading()),
          const SongState(status: SongStatus.failure()),
        ],
      );

      blocTest<SongCubit, SongState>(
        'emit [loading, success] when songSearch returns',
        setUp: () {
          when(() => mockSongRemoteRepository.fetchSongs(any())).thenAnswer(
            (_) async => right(
              [fakeSong],
            ),
          );
        },
        build: () => songCubit,
        act: (cubit) => cubit.fetchSongs('Test'),
        expect: () => <dynamic>[
          const SongState(status: SongStatus.loading()),
          const SongState(status: SongStatus.success(), songs: [fakeSong]),
        ],
      );
    },
  );
}
