import 'dart:ffi';
import 'package:alan_voice/alan_voice.dart';
import 'package:ai_radio/models/radio.dart';
import 'package:ai_radio/utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  Color _selecetedColor;
  bool _isPlaying = false;
  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Void initState() {
    super.initState();
    setupAlan();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "7b2b629de3af567ee12a4445eb129ea72e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playMusic(_selectedRadio.url);
        break;

      case "play_channel":
        final id = response["id"];
        // _audioPlayer.pause();
        MyRadio newRadio = radios.firstWhere((element) => element.id == id);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        _playMusic(newRadio.url);
        break;

      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;

      case "prev":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        _playMusic(newRadio.url);
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    print(radios);
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selecetedColor ?? AIColors.primaryColor2,
          child: radios != null
              ? [
                  100.heightBox,
                  "All Channels".text.xl.white.semiBold.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: radios
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: "${e.name} FM".text.white.make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  ).expand()
                ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(LinearGradient(colors: [
                AIColors.primaryColor2,
                _selecetedColor ?? AIColors.primaryColor1,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight))
              .make(),
          AppBar(
            title: "Chillax"
                .text
                .xl4
                .bold
                .white
                .make()
                .shimmer(primaryColor: Vx.purple300, secondaryColor: Vx.white),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100).p16(),
          radios != null
              ? VxSwiper.builder(
                  itemCount: radios.length,
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    _selectedRadio = radios[index];
                    final colorHex = radios[index].color;
                    _selecetedColor = Color(int.tryParse(colorHex));
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final rad = radios[index];

                    return VxBox(
                      child: ZStack(
                        [
                          Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: VxBox(
                                      child: rad.category.text.uppercase.white
                                          .make()
                                          .px16())
                                  .height(40)
                                  .black
                                  .alignCenter
                                  .withRounded(value: 13)
                                  .make()),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.white.bold.make(),
                                5.heightBox,
                                rad.tagline.text.sm.white.semiBold.make(),
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: [
                              Icon(
                                CupertinoIcons.play_circle,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "DOUBLE TAP TO PLAY".text.gray300.make()
                            ].vStack(),
                          )
                        ],
                      ),
                    )
                        .clip(Clip.antiAlias)
                        .bgImage(
                          DecorationImage(
                            image: NetworkImage(rad.image),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black12.withOpacity(0.3),
                                BlendMode.darken),
                          ),
                        )
                        .border(color: Colors.black12, width: 4.0)
                        .withRounded(value: 60.0)
                        .make()
                        .onInkDoubleTap(() {
                      _playMusic(rad.url);
                    }).p16();
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "Playing now - ${_selectedRadio.name} FM "
                    .text
                    .white
                    .makeCentered(),
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                if (_isPlaying) {
                  _audioPlayer.stop();
                } else {
                  _playMusic(_selectedRadio.url);
                }
              })
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
