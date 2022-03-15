import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';

@freezed
class Song with _$Song {
  const Song._();
  const factory Song({
    String? artistName,
    String? collectionName,
    String? trackName,
    String? artworkUrl100,
    required String previewUrl,
  }) = _Song;
}
