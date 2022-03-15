import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:itunes_search_api_example/infrastructure/song_dto.dart';
import 'package:itunes_search_api_example/infrastructure/song_remote_service.dart';
import 'package:mocktail/mocktail.dart';

import '../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  late http.Client mockHttpClient;
  late SongRemoteService songRemoteService;

  setUp(
    () {
      mockHttpClient = MockHttpClient();
      songRemoteService = SongRemoteService(httpClient: mockHttpClient);
    },
  );

  group(
    '[SongRemoteService]',
    () {
      const query = 'yellow';
      var uri = Uri.https(
        'itunes.apple.com',
        'search',
        <String, String>{
          'term': query,
          'media': 'music',
          'attribute': 'artistTerm',
          'limit': '5',
        },
      );
      test(
        'constructor does not require an httpClient',
        () {
          expect(SongRemoteService(), isNotNull);
        },
      );

      test(
        'make a correct http request',
        () async {
          // arrange
          var response = MockResponse();
          var body = fixture('empty_body.json');
          when(() => response.statusCode).thenReturn(200);
          when(() => response.body).thenReturn(body);
          when(() => mockHttpClient.get(uri)).thenAnswer((_) async => response);

          // act
          await songRemoteService.fetchSongs(query);

          // assert
          verify(
            () => mockHttpClient.get(uri),
          ).called(1);
        },
      );

      test(
        'throws a SongRequestException on non-200 response',
        () async {
          // arrange
          var response = MockResponse();
          when(() => response.statusCode).thenReturn(400);
          when(() => mockHttpClient.get(uri)).thenAnswer((_) async => response);

          // act and assert
          expect(
            () async => await songRemoteService.fetchSongs(query),
            throwsA(isA<SongRequestException>()),
          );
        },
      );

      test(
        'returns an empty List<SongDTO> if the results in response is empty',
        () async {
          // arrange
          var response = MockResponse();
          var body = fixture('empty_body.json');
          when(() => response.statusCode).thenReturn(200);
          when(() => response.body).thenReturn(body);
          when(() => mockHttpClient.get(uri)).thenAnswer((_) async => response);

          // act
          final actual = await songRemoteService.fetchSongs(query);

          // assert
          expect(
            actual,
            isA<List<SongDTO>>()
                .having((songs) => songs.isEmpty, 'empty songs', true),
          );
        },
      );

      test(
        'returns a List<SongDTO> if the results in response has value',
        () async {
          // arrange
          var response = MockResponse();
          var body = fixture('valid_body.json');
          var json = jsonDecode(body) as Map<String, dynamic>;
          final List<dynamic> results = json['results'];
          var songs = results.map((json) => SongDTO.fromJson(json)).toList();
          when(() => response.statusCode).thenReturn(200);
          when(() => response.body).thenReturn(body);
          when(() => mockHttpClient.get(uri)).thenAnswer((_) async => response);

          // act
          final actual = await songRemoteService.fetchSongs(query);

          // assert
          expect(
            actual,
            songs,
          );
        },
      );
    },
  );
}
