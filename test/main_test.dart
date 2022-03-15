import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/main.dart';
import 'package:itunes_search_api_example/presentation/song_page.dart';
import 'package:mocktail/mocktail.dart';

class MockSongCubit extends MockCubit<SongState> implements SongCubit {}

void main() {
  late SongCubit mockSongCubit;

  setUp(() {
    mockSongCubit = MockSongCubit();
  });
  testWidgets(
    '[MyApp Widget Test] find a SongPage',
    (widgetTester) async {
      // Arrange
      when(() => mockSongCubit.state).thenReturn(SongState.initial());

      // Build the widget
      await widgetTester.pumpWidget(MyApp(songCubit: mockSongCubit));

      // Assert
      expect(find.byType(SongPage), findsOneWidget);
    },
  );
}
