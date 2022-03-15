import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itunes_search_api_example/application/song/song_cubit.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 9,
            child: TextField(
              key: const Key('__searchTextField__'),
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Enter an artist name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textEditingController.clear();
                  },
                ),
              ),
              textInputAction: TextInputAction.done,
              onEditingComplete: () async {
                if (_textEditingController.text.isNotEmpty) {
                  final song = _textEditingController.text;
                  await context.read<SongCubit>().fetchSongs(song);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              key: const Key('__searchButton__'),
              icon: const Icon(Icons.search),
              onPressed: () async {
                if (_textEditingController.text.isNotEmpty) {
                  final song = _textEditingController.text;
                  await context.read<SongCubit>().fetchSongs(song);
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
