import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itunes_search_api_example/application/audio_player/audio_player_cubit.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';
import 'package:itunes_search_api_example/infrastructure/song_remote_repository.dart';
import 'package:itunes_search_api_example/infrastructure/song_remote_service.dart';
import 'package:itunes_search_api_example/presentation/song_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      songCubit: SongCubit(
        SongRemoteRepository(
          SongRemoteService(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.songCubit,
  }) : super(key: key);
  final SongCubit songCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => songCubit,
        ),
        BlocProvider(
          create: (_) => AudioPlayerCubit(songCubit: songCubit)..init(),
        )
      ],
      child: const MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: SongPage(),
      ),
    );
  }
}
