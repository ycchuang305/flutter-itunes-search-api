import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/presentation/widgets/audio_player_buttons.dart';
import 'package:itunes_search_api_example/presentation/widgets/empty_widget.dart';
import 'package:itunes_search_api_example/presentation/widgets/search_bar.dart';
import 'package:itunes_search_api_example/presentation/widgets/song_list_view.dart';

class SongPage extends StatelessWidget {
  const SongPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Music Search',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SearchBar(),
              Expanded(
                child: BlocBuilder<SongCubit, SongState>(
                  builder: (context, state) => state.status.when(
                    initial: () => const EmptyWidget(
                      key: Key('__initial__'),
                      text: 'Start a search',
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.black45,
                      ),
                    ),
                    success: () => state.songs.isNotEmpty
                        ? SongListView(songs: state.songs)
                        : const EmptyWidget(
                            key: Key('__noResult__'),
                            text: 'No result',
                          ),
                    failure: () => const EmptyWidget(
                      key: Key('__searchFailed__'),
                      text: 'Something went wrong!',
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: AudioPlayerButtons(),
              )
            ],
          )
        ],
      ),
    );
  }
}
