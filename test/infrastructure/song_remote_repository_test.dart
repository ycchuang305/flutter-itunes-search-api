import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/domain/song.dart';
import 'package:itunes_search_api_example/domain/song_failure.dart';
import 'package:itunes_search_api_example/infrastructure/song_dto.dart';
import 'package:itunes_search_api_example/infrastructure/song_remote_repository.dart';
import 'package:itunes_search_api_example/infrastructure/song_remote_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockSongRemoteService extends Mock implements SongRemoteService {}

void main() {
  late MockSongRemoteService mockSongRemoteService;
  late SongRemoteRepository songRemoteRepository;

  setUp(() {
    mockSongRemoteService = MockSongRemoteService();
    songRemoteRepository = SongRemoteRepository(mockSongRemoteService);
  });

  group(
    '[SongRemoteRepository]',
    () {
      const query = 'foo';
      test(
        'return a SongFailure on fetchSongs failed',
        () async {
          // arrange
          var exception = Exception('oops');
          when(() => mockSongRemoteService.fetchSongs(query))
              .thenThrow(exception);
          // act
          final result = await songRemoteRepository.fetchSongs(query);
          // assert
          expect(result.isLeft(), true);
          // id -> a function that returns its own parameter
          expect(
            result.fold(id, id),
            isA<SongFailure>(),
          );
        },
      );

      test(
        'returns correct songs on fetchSongs succeed',
        () async {
          when(() => mockSongRemoteService.fetchSongs(query)).thenAnswer(
            (_) async => const [
              SongDTO(
                artistName: 'Eminem',
                collectionName: 'The Marshall Mathers LP2 (Deluxe)',
                trackName: 'Rap God',
                artworkUrl100:
                    'https://is5-ssl.mzstatic.com/image/thumb/Music118/v4/45/14/f2/4514f2fe-7b1d-fc12-b9bc-bafe6a877ff3/source/100x100bb.jpg',
                previewUrl:
                    'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview128/v4/7e/de/52/7ede5258-4a12-50c1-d4f0-7f58defe02b0/mzaf_2628383916915879028.plus.aac.p.m4a',
              ),
            ],
          );
          final result = await songRemoteRepository.fetchSongs(query);
          expect(result.isRight(), true);
          expect(
            result.fold(id, id),
            const [
              Song(
                artistName: 'Eminem',
                collectionName: 'The Marshall Mathers LP2 (Deluxe)',
                trackName: 'Rap God',
                artworkUrl100:
                    'https://is5-ssl.mzstatic.com/image/thumb/Music118/v4/45/14/f2/4514f2fe-7b1d-fc12-b9bc-bafe6a877ff3/source/100x100bb.jpg',
                previewUrl:
                    'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview128/v4/7e/de/52/7ede5258-4a12-50c1-d4f0-7f58defe02b0/mzaf_2628383916915879028.plus.aac.p.m4a',
              ),
            ],
          );
        },
      );
    },
  );
}
