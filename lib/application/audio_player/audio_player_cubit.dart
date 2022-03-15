import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/domain/song.dart';
import 'package:just_audio/just_audio.dart';

part 'audio_player_state.dart';
part 'audio_player_cubit.freezed.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  final SongCubit songCubit;
  StreamSubscription? _audioStatusSub;
  StreamSubscription? _indexSub;
  StreamSubscription? _songStateSub;

  bool _canReloadPlayList = false;
  set canReloadPlayList(bool value) => _canReloadPlayList = value;

  bool get hasPrevious => _audioPlayer.hasPrevious;

  bool get hasNext => _audioPlayer.hasNext;

  AudioPlayerCubit({
    AudioPlayer? audioPlayer,
    required this.songCubit,
  })  : _audioPlayer = audioPlayer ?? AudioPlayer(),
        super(AudioPlayerState.initial());

  void init() {
    _audioStatusSub?.cancel();
    _audioStatusSub = _audioPlayer.playerStateStream.listen(
      (playerState) {
        final ProcessingState processingState = playerState.processingState;
        switch (processingState) {
          case ProcessingState.idle:
            emit(state.copyWith(status: const AudioPlayerStatus.idle()));
            break;
          case ProcessingState.loading:
            emit(state.copyWith(status: const AudioPlayerStatus.loading()));
            break;
          case ProcessingState.buffering:
            emit(state.copyWith(status: const AudioPlayerStatus.buffering()));
            break;
          case ProcessingState.ready:
            playerState.playing
                ? emit(
                    state.copyWith(status: const AudioPlayerStatus.playing()))
                : emit(state.copyWith(status: const AudioPlayerStatus.ready()));
            break;
          case ProcessingState.completed:
            emit(state.copyWith(status: const AudioPlayerStatus.completed()));
            break;
          default:
            emit(state.copyWith(status: const AudioPlayerStatus.idle()));
            break;
        }
      },
    );

    _indexSub?.cancel();
    _indexSub = _audioPlayer.currentIndexStream.listen(
      (index) {
        if (index != null) {
          emit(state.copyWith(currentIndex: index));
        }
      },
    );

    _songStateSub?.cancel();
    _songStateSub = songCubit.stream.listen(
      (songState) {
        songState.status.maybeWhen(
          success: () async {
            if (state.playList.isEmpty) {
              await loadPlayList(playList: songState.songs);
              emit(state.copyWith(playList: songState.songs));
              _canReloadPlayList = false;
            } else {
              _canReloadPlayList = true;
            }
            return;
          },
          orElse: () {},
        );
      },
    );
  }

  Future<void> loadPlayList({
    required List<Song> playList,
    int index = 0,
  }) async {
    try {
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: playList
              .map((song) => AudioSource.uri(Uri.parse(song.previewUrl)))
              .toList(),
        ),
        initialIndex: index,
      );
    } catch (_) {
      emit(state.copyWith(status: const AudioPlayerStatus.failure()));
    }
    return;
  }

  Future<void> play() async {
    return await _audioPlayer.play();
  }

  Future<void> pause() async {
    return await _audioPlayer.pause();
  }

  Future<void> seekToNext() async {
    if (_audioPlayer.hasNext) {
      return await _audioPlayer.seekToNext();
    }
  }

  Future<void> seekToPrevious() async {
    if (_audioPlayer.hasPrevious) {
      return await _audioPlayer.seekToPrevious();
    }
  }

  Future<void> seekToStart() async {
    return await _audioPlayer.seek(Duration.zero,
        index: _audioPlayer.effectiveIndices?.first);
  }

  Future<void> seekToIndex({
    required int index,
    List<Song> playList = const [],
  }) async {
    if (playList.isNotEmpty && _canReloadPlayList) {
      // reload new playlist and play the song@index
      emit(state.copyWith(playList: playList));
      await loadPlayList(playList: playList, index: index);
      await _audioPlayer.play();
    } else {
      // seek to a particular song@index with zero duration, and then play it
      await _audioPlayer.seek(Duration.zero, index: index);
      await _audioPlayer.play();
    }
    return;
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    _audioStatusSub?.cancel();
    _indexSub?.cancel();
    _songStateSub?.cancel();
    return super.close();
  }
}
