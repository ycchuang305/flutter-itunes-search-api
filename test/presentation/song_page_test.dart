import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/application/audio_player/audio_player_cubit.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/domain/song.dart';
import 'package:itunes_search_api_example/presentation/song_page.dart';
import 'package:itunes_search_api_example/presentation/widgets/audio_player_buttons.dart';
import 'package:itunes_search_api_example/presentation/widgets/search_bar.dart';
import 'package:itunes_search_api_example/presentation/widgets/song_list_view.dart';
import 'package:mocktail/mocktail.dart';

class MockSongCubit extends MockCubit<SongState> implements SongCubit {}

class MockAudioPlayerCubit extends MockCubit<AudioPlayerState>
    implements AudioPlayerCubit {}

void main() {
  late SongCubit mockSongCubit;
  late AudioPlayerCubit mockAudioPlayerCubit;

  setUp(() {
    mockSongCubit = MockSongCubit();
    mockAudioPlayerCubit = MockAudioPlayerCubit();

    when(() => mockAudioPlayerCubit.state)
        .thenReturn(AudioPlayerState.initial());
  });

  group(
    '[SongPage Widget Test]',
    () {
      testWidgets(
        'render an initial empty page when SongState is initial',
        (widgetTester) async {
          // arrange
          when(() => mockSongCubit.state).thenReturn(SongState.initial());

          // act
          await widgetTester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => mockSongCubit,
                ),
                BlocProvider(
                  create: (_) => mockAudioPlayerCubit,
                )
              ],
              child: const MaterialApp(
                home: SongPage(),
              ),
            ),
          );

          // assert
          expect(find.byType(SearchBar), findsOneWidget);
          expect(find.byKey(const Key('__initial__')), findsOneWidget);
          expect(find.byType(AudioPlayerButtons), findsOneWidget);
        },
      );

      testWidgets(
        'render a circular progress indicator when SongState is loading',
        (widgetTester) async {
          // arrange
          when(() => mockSongCubit.state)
              .thenReturn(const SongState(status: SongStatus.loading()));

          // act
          await widgetTester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => mockSongCubit,
                ),
                BlocProvider(
                  create: (_) => mockAudioPlayerCubit,
                )
              ],
              child: const MaterialApp(
                home: SongPage(),
              ),
            ),
          );

          // assert
          expect(find.byType(SearchBar), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.byType(AudioPlayerButtons), findsOneWidget);
        },
      );

      testWidgets(
        'render an empty page with no result when SongState is success with an empty songs',
        (widgetTester) async {
          // arrange
          when(() => mockSongCubit.state).thenReturn(
              const SongState(status: SongStatus.success(), songs: []));

          // act
          await widgetTester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => mockSongCubit,
                ),
                BlocProvider(
                  create: (_) => mockAudioPlayerCubit,
                )
              ],
              child: const MaterialApp(
                home: SongPage(),
              ),
            ),
          );

          // assert
          expect(find.byType(SearchBar), findsOneWidget);
          expect(find.byKey(const Key('__noResult__')), findsOneWidget);
          expect(find.byType(AudioPlayerButtons), findsOneWidget);
        },
      );

      testWidgets(
        'render a SongListView when SongState is success with valid songs',
        (widgetTester) async {
          // arrange
          const fakeSong = Song(previewUrl: '');
          when(() => mockSongCubit.state).thenReturn(
              const SongState(status: SongStatus.success(), songs: [fakeSong]));

          // act
          await widgetTester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => mockSongCubit,
                ),
                BlocProvider(
                  create: (_) => mockAudioPlayerCubit,
                )
              ],
              child: const MaterialApp(
                home: SongPage(),
              ),
            ),
          );

          // assert
          expect(find.byType(SearchBar), findsOneWidget);
          expect(find.byType(SongListView), findsOneWidget);
          expect(find.byType(AudioPlayerButtons), findsOneWidget);
        },
      );

      testWidgets(
        'render a failed result page when SongState is failure',
        (widgetTester) async {
          // arrange
          when(() => mockSongCubit.state)
              .thenReturn(const SongState(status: SongStatus.failure()));

          // act
          await widgetTester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => mockSongCubit,
                ),
                BlocProvider(
                  create: (_) => mockAudioPlayerCubit,
                )
              ],
              child: const MaterialApp(
                home: SongPage(),
              ),
            ),
          );

          // assert
          expect(find.byType(SearchBar), findsOneWidget);
          expect(find.byKey(const Key('__searchFailed__')), findsOneWidget);
          expect(find.byType(AudioPlayerButtons), findsOneWidget);
        },
      );
    },
  );
}
