import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_music_player/data/store/app_state.dart';
import 'package:simple_music_player/resources/colors.dart';
import 'package:simple_music_player/resources/sizes.dart';
import 'package:simple_music_player/widgets/song_row.dart';

class Songs extends StatefulWidget {
  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: background,
              title: Text(
                'Songs',
                style: TextStyle(color: accentText),
              ),
              pinned: true,
              floating: true,
              forceElevated: true,
              bottom: TabBar(
                labelStyle: TextStyle(
                    fontSize: AppFont.sm, fontWeight: FontWeight.w700),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
                labelColor: secondaryText,
                controller: tabController,
                indicatorColor: secondaryText,
                tabs: <Widget>[
                  Tab(
                    text: "Tracks",
                  ),
                  Tab(
                    text: "Playlist",
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: <Widget>[
            Tracks(),
            Playlists(),
          ],
          controller: tabController,
        ),
      ),
    );
  }
}

class Tracks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, model, child) {
      if (model.songsLoading && model.songs == null)
        return CircularProgressIndicator();
      return ListView.builder(
        itemCount: model.songs.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => InkWell(
              onTap: () {
                if (model.playerState == PlayerState.playing && model.currentSongIndex == index) {
                  return model.pause();
                }
                if (model.playerState != PlayerState.stopped) model.stop();
                model.play(index);
              },
              child: SongRow(
                title: model.songs[index].title,
                number: index + 1,
                artist: model.songs[index].artist,
                isActive: model.currentSongIndex == index,
              ),
            ),
      );
    });
  }
}

class Playlists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1,
      physics: BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) => InkWell(
            onTap: () {},
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: AppSpace.md),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.playlist_add,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: AppSpace.sm,
                  ),
                  Text(
                    'New Playlist',
                    style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
    );
  }
}