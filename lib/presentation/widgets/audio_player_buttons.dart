import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itunes_search_api_example/application/audio_player/audio_player_cubit.dart';

class AudioPlayerButtons extends StatelessWidget {
  const AudioPlayerButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state.playList.isNotEmpty &&
            (state.currentIndex <= state.playList.length)) {
          return ClipRRect(
            child: SizedBox(
              height: 70,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: ListTile(
                  tileColor: Colors.grey.withOpacity(0.2),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: state.playList[state.currentIndex].artworkUrl100 !=
                              null
                          ? Image.network(
                              state.playList[state.currentIndex].artworkUrl100!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/no_artwork_available.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  title: Text(
                    state.playList[state.currentIndex].trackName ??
                        'Unknown Track',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          color: Colors.black,
                          onPressed: () async =>
                              context.read<AudioPlayerCubit>().hasPrevious
                                  ? await context
                                      .read<AudioPlayerCubit>()
                                      .seekToPrevious()
                                  : null,
                        ),
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: Center(
                            child: state.status.maybeWhen(
                              buffering: () => const LoadingWidget(),
                              loading: () => const LoadingWidget(),
                              ready: () => IconButton(
                                icon: const Icon(Icons.play_arrow),
                                splashColor: Colors.transparent,
                                color: Colors.black,
                                onPressed: () async => await context
                                    .read<AudioPlayerCubit>()
                                    .play(),
                              ),
                              completed: () => IconButton(
                                icon: const Icon(Icons.replay),
                                splashColor: Colors.transparent,
                                color: Colors.black,
                                onPressed: () async => await context
                                    .read<AudioPlayerCubit>()
                                    .seekToStart(),
                              ),
                              playing: () => IconButton(
                                icon: const Icon(Icons.pause),
                                splashColor: Colors.transparent,
                                color: Colors.black,
                                onPressed: () async => await context
                                    .read<AudioPlayerCubit>()
                                    .pause(),
                              ),
                              orElse: () => const IconButton(
                                icon: Icon(Icons.play_arrow),
                                splashColor: Colors.transparent,
                                color: Colors.black,
                                onPressed: null,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          color: Colors.black,
                          onPressed: () async =>
                              context.read<AudioPlayerCubit>().hasNext
                                  ? await context
                                      .read<AudioPlayerCubit>()
                                      .seekToNext()
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.black54,
        ),
      ),
    );
  }
}
