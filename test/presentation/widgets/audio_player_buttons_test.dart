import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/application/audio_player/audio_player_cubit.dart';
import 'package:itunes_search_api_example/domain/song.dart';
import 'package:itunes_search_api_example/presentation/widgets/audio_player_buttons.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayerCubit extends MockCubit<AudioPlayerState>
    implements AudioPlayerCubit {}

void main() {
  late AudioPlayerCubit mockAudioPlayerCubit;

  setUp(() {
    mockAudioPlayerCubit = MockAudioPlayerCubit();
  });

  group(
    '[AudioPlayerButtons Widget Test]',
    () {
      testWidgets(
        'find empty widget(SizedBox) when there is no playlist in the state',
        (widgetTester) async {
          // Arrange
          when(() => mockAudioPlayerCubit.state)
              .thenReturn(AudioPlayerState.initial());

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: AudioPlayerButtons(),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byType(SizedBox), findsOneWidget);
        },
      );

      testWidgets(
        'find LoadingWidget on buffering status',
        (widgetTester) async {
          // Arrange
          const playList = [Song(previewUrl: 'foo')];
          when(() => mockAudioPlayerCubit.state).thenReturn(
            const AudioPlayerState(
              currentIndex: 0,
              playList: playList,
              status: AudioPlayerStatus.buffering(),
            ),
          );

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: AudioPlayerButtons(),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byType(LoadingWidget), findsOneWidget);
        },
      );

      testWidgets(
        'find LoadingWidget on loading status',
        (widgetTester) async {
          // Arrange
          const playList = [Song(previewUrl: 'foo')];
          when(() => mockAudioPlayerCubit.state).thenReturn(
            const AudioPlayerState(
              currentIndex: 0,
              playList: playList,
              status: AudioPlayerStatus.loading(),
            ),
          );

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: AudioPlayerButtons(),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byType(LoadingWidget), findsOneWidget);
        },
      );

      testWidgets(
        'find play icon on ready status, invoke play() once by tap it',
        (widgetTester) async {
          // Arrange
          const playList = [Song(previewUrl: 'foo')];
          when(() => mockAudioPlayerCubit.state).thenReturn(
            const AudioPlayerState(
              currentIndex: 0,
              playList: playList,
              status: AudioPlayerStatus.ready(),
            ),
          );
          when(mockAudioPlayerCubit.play).thenAnswer((_) async {});

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: AudioPlayerButtons(),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byIcon(Icons.play_arrow), findsOneWidget);

          // Tap the play button
          await widgetTester.tap(find.byIcon(Icons.play_arrow));
          verify(mockAudioPlayerCubit.play).called(1);
        },
      );

      testWidgets(
        'find pause icon on playing status, invoke pause() once by tap it',
        (widgetTester) async {
          // Arrange
          const playList = [Song(previewUrl: 'foo')];
          when(() => mockAudioPlayerCubit.state).thenReturn(
            const AudioPlayerState(
              currentIndex: 0,
              playList: playList,
              status: AudioPlayerStatus.playing(),
            ),
          );
          when(mockAudioPlayerCubit.pause).thenAnswer((_) async {});

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: AudioPlayerButtons(),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byIcon(Icons.pause), findsOneWidget);

          // Tap the pause button
          await widgetTester.tap(find.byIcon(Icons.pause));
          verify(mockAudioPlayerCubit.pause).called(1);
        },
      );

      testWidgets(
        'find replay icon on completed status, invoke seekToStart() once by tap it',
        (widgetTester) async {
          // Arrange
          const playList = [Song(previewUrl: 'foo')];
          when(() => mockAudioPlayerCubit.state).thenReturn(
            const AudioPlayerState(
              currentIndex: 0,
              playList: playList,
              status: AudioPlayerStatus.completed(),
            ),
          );
          when(mockAudioPlayerCubit.seekToStart).thenAnswer((_) async {});

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: AudioPlayerButtons(),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byIcon(Icons.replay), findsOneWidget);

          // Tap the replay button
          await widgetTester.tap(find.byIcon(Icons.replay));
          verify(mockAudioPlayerCubit.seekToStart).called(1);
        },
      );

      testWidgets(
        'invoke seekToPrevious() once by tap the skip_previous button, and invoke seekToPrevious() once by tap the skip_next button',
        (widgetTester) async {
          // Arrange
          const playList = [Song(previewUrl: 'foo')];
          when(() => mockAudioPlayerCubit.state).thenReturn(
            const AudioPlayerState(
              currentIndex: 0,
              playList: playList,
              status: AudioPlayerStatus.completed(),
            ),
          );
          when(mockAudioPlayerCubit.seekToPrevious).thenAnswer((_) async {});
          when(mockAudioPlayerCubit.seekToNext).thenAnswer((_) async {});
          when(() => mockAudioPlayerCubit.hasPrevious).thenReturn(true);
          when(() => mockAudioPlayerCubit.hasNext).thenReturn(true);

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockAudioPlayerCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: AudioPlayerButtons(),
                ),
              ),
            ),
          );

          // Assert
          expect(find.byIcon(Icons.skip_previous), findsOneWidget);
          expect(find.byIcon(Icons.skip_next), findsOneWidget);

          // Tap the skip_previous button
          await widgetTester.tap(find.byIcon(Icons.skip_previous));
          verify(mockAudioPlayerCubit.seekToPrevious).called(1);

          // Tap the skip_next button
          await widgetTester.tap(find.byIcon(Icons.skip_next));
          verify(mockAudioPlayerCubit.seekToNext).called(1);
        },
      );
    },
  );
}
