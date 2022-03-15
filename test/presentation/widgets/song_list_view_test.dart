import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/application/audio_player/audio_player_cubit.dart';
import 'package:itunes_search_api_example/domain/song.dart';
import 'package:itunes_search_api_example/presentation/widgets/song_list_view.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayerCubit extends MockCubit<AudioPlayerState>
    implements AudioPlayerCubit {}

void main() {
  late AudioPlayerCubit mockAudioPlayerCubit;

  setUp(() {
    mockAudioPlayerCubit = MockAudioPlayerCubit();
  });

  group(
    '[SongListView Widget Test]',
    () {
      testWidgets(
        'find the artistName, collectionName, trackName, invoke seekToIndex() once when tap the card',
        (widgetTester) async {
          // Arrange
          const playList = [
            Song(
              artistName: 'x',
              collectionName: 'x',
              trackName: 'x',
              artworkUrl100: 'x',
              previewUrl: 'x',
            ),
            Song(
              artistName: 'x',
              collectionName: 'x',
              trackName: 'x',
              artworkUrl100: 'x',
              previewUrl: 'x',
            ),
          ];
          when(() => mockAudioPlayerCubit.state).thenReturn(
              AudioPlayerState.initial().copyWith(playList: playList));

          when(() => mockAudioPlayerCubit.seekToIndex(
              index: 0, playList: playList)).thenAnswer((_) async {});

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: SongListView(
                    songs: playList,
                  ),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byType(Card), findsNWidgets(playList.length));

          for (Song song in playList) {
            expect(find.text(song.artistName!), findsOneWidget);
            expect(find.text(song.collectionName!), findsOneWidget);
            expect(find.text(song.trackName!), findsOneWidget);
          }

          await widgetTester.tap(find.text(playList[0].artistName!));

          verify(() => mockAudioPlayerCubit.seekToIndex(
              index: 0, playList: playList)).called(1);
        },
      );
    },
  );
}
