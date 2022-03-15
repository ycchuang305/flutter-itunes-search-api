import 'package:freezed_annotation/freezed_annotation.dart';

part 'song_failure.freezed.dart';

@freezed
class SongFailure with _$SongFailure {
  const SongFailure._();
  const factory SongFailure.api(String? errorMessage) = _Api;
}
