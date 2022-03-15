import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/presentation/widgets/search_bar.dart';
import 'package:mocktail/mocktail.dart';

class MockSongCubit extends MockCubit<SongState> implements SongCubit {}

void main() {
  late SongCubit mockSongCubit;

  setUp(() {
    mockSongCubit = MockSongCubit();
  });

  group(
    '[SearchBar Widget Test]',
    () {
      testWidgets(
        'invoke fechSongs method once after tap the search button with valid text',
        (widgetTester) async {
          // Arrange
          const searchTerm = 'foo';
          when(() => mockSongCubit.state).thenReturn(SongState.initial());
          when(() => mockSongCubit.fetchSongs(searchTerm))
              .thenAnswer((_) async {});

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockSongCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: SearchBar(),
                ),
              ),
            ),
          );

          // Enter text into the TextField.
          await widgetTester.enterText(
            find.byKey(const Key('__searchTextField__')),
            searchTerm,
          );

          // Tap the search button.
          await widgetTester.tap(
            find.byKey(
              const Key('__searchButton__'),
            ),
          );

          // Assert
          verify(() => mockSongCubit.fetchSongs(searchTerm)).called(1);
        },
      );

      testWidgets(
        'invoke fechSongs method once onEditingComplete is being invoked with valid text',
        (widgetTester) async {
          // Arrange
          const searchTerm = 'foo';
          when(() => mockSongCubit.state).thenReturn(SongState.initial());
          when(() => mockSongCubit.fetchSongs(searchTerm))
              .thenAnswer((_) async {});

          // Build the widget
          await widgetTester.pumpWidget(
            BlocProvider(
              create: (_) => mockSongCubit,
              child: const MaterialApp(
                home: Scaffold(
                  body: SearchBar(),
                ),
              ),
            ),
          );

          // Enter text into the TextField.
          await widgetTester.enterText(
            find.byKey(const Key('__searchTextField__')),
            searchTerm,
          );

          final TextField textFieldWidget =
              widgetTester.widget(find.byKey(const Key('__searchTextField__')));

          textFieldWidget.onEditingComplete!.call();

          // Assert
          verify(() => mockSongCubit.fetchSongs(searchTerm)).called(1);
        },
      );
    },
  );
}
