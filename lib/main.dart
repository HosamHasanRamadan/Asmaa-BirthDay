import 'dart:async';
import 'dart:ui';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

T call<T>(T Function() fun) => fun();

final birthDayOne = DateTime(birthYear, birthMonth, dayOne);
final birthDayTwo = DateTime(birthYear, birthMonth, dayTwo);

final player = AudioPlayer();

const birthYear = 2000;
const birthMonth = 2;
const dayOne = 5;
const dayTwo = 12;

DateTime get now => DateTime.now();

bool get isBirthDayPeriodOne {
  final day = DateTime(
    now.year,
    birthMonth,
    dayOne,
  );
  final diff = day.difference(now);
  return diff.isNegative && diff.abs() < const Duration(hours: 24);
}

bool get isBirthDayPeriodTwo {
  final day = DateTime(
    now.year,
    birthMonth,
    dayTwo,
  );
  final diff = day.difference(now);
  return diff.isNegative && diff.abs() < const Duration(hours: 24);
}

final nextBirthDayOne = call(() {
  final day = DateTime(
    now.year,
    birthMonth,
    dayOne,
  );
  if (now.isAfter(day)) return day.copyWith(year: day.year + 1);
  return day;
});

final nextBirthDayTwo = call(() {
  final day = DateTime(
    now.year,
    birthMonth,
    dayTwo,
  );
  if (now.isAfter(day)) return day.copyWith(year: day.year + 1);
  return day;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Timer timer;
  var remainingFormattedDurationOne = formatDuration(
    nextBirthDayOne.difference(now),
  );

  var remainingFormattedDurationTwo = formatDuration(
    nextBirthDayTwo.difference(now),
  );
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            remainingFormattedDurationOne = formatDuration(
              nextBirthDayOne.difference(now),
            );

            remainingFormattedDurationTwo = formatDuration(
              nextBirthDayTwo.difference(now),
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFD3E0EE),
        body: Center(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/blossom.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ColoredBox(
                    color: const Color(0xFFFFDCDC).withOpacity(.2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Expanded(
                      flex: 20,
                      child: isBirthDayPeriodOne
                          ? celebrationView()
                          : timeView(remainingFormattedDurationOne),
                    ),
                    Expanded(
                      flex: 5,
                      child: Visibility(
                        visible: isBirthDayPeriodOne || isBirthDayPeriodTwo,
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: StreamBuilder(
                            stream: player.onPlayerStateChanged,
                            builder: (context, snapshot) {
                              final idle = IconButton(
                                icon: const Icon(Icons.music_note),
                                onPressed: () {
                                  player.setReleaseMode(ReleaseMode.loop);
                                  player
                                      .play(AssetSource('audio/birthday.mp3'));
                                },
                              );

                              final playing = InkWell(
                                onTap: () => player.stop(),
                                child: const AnimatedEmoji(
                                  AnimatedEmojis.musicalNotes,
                                ),
                              );
                              if (snapshot.hasData == false) return idle;
                              switch (snapshot.requireData) {
                                case PlayerState.playing:
                                  return playing;
                                case PlayerState.stopped:
                                case PlayerState.completed:
                                case PlayerState.paused:
                                  return idle;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: isBirthDayPeriodTwo
                          ? celebrationView2()
                          : timeView(remainingFormattedDurationTwo),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget celebrationView() {
    return CelebrationView(
      age: birthDayOne.difference(now).inYears.abs().toString(),
    );
  }

  Widget celebrationView2() {
    return CelebrationView(
      age: birthDayOne.difference(now).inYears.abs().toString() + '+2',
    );
  }

  Widget timeView(ExplodedDuration duration) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          sectionWidget(
            value: duration.days,
            title: 'Days',
            padSize: null,
          ),
          const Text('  '),
          sectionWidget(
            value: duration.hours,
            title: 'Hours',
          ),
          const Text('  '),
          sectionWidget(
            value: duration.minutes,
            title: 'Minutes',
          ),
          const Text('  '),
          sectionWidget(
            value: duration.seconds,
            title: 'Seconds',
          ),
        ],
      ),
    );
  }

  Widget sectionWidget({
    required int value,
    required String title,
    int? padSize = 2,
  }) {
    final val =
        padSize == null ? value : value.toString().padLeft(padSize, '0');

    return AnimatedSwitcher(
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      duration: const Duration(milliseconds: 500),
      child: Text(
        key: ValueKey(value),
        '$val\n$title',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFD3E0EE),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    player.dispose();
    super.dispose();
  }
}

typedef ExplodedDuration = ({
  int days,
  int hours,
  int minutes,
  int seconds,
});
ExplodedDuration formatDuration(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours % 24;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;

  return (
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
  );
}

class CelebrationView extends StatefulWidget {
  final String age;
  const CelebrationView({
    Key? key,
    required this.age,
  }) : super(key: key);

  @override
  State<CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<CelebrationView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: AnimatedEmoji(
                      AnimatedEmojis.partyPopper,
                    ),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: AnimatedEmoji(
                      AnimatedEmojis.partyingFace,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: AnimatedEmoji(
                    AnimatedEmojis.birthdayCake,
                  ),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(widget.age.toString()),
                        WavyAnimatedText(widget.age.toString()),
                      ],
                      isRepeatingAnimation: true,
                      repeatForever: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    player.stop();
    super.dispose();
  }
}

extension on Duration {
  int get inYears {
    return (inDays / daysInYear).ceil();
  }
}

const daysInYear = 365.242199;

extension on Widget {
  Widget get debugBorder {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
      ),
      child: this,
    );
  }
}
