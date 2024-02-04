import 'dart:async';
import 'dart:ui';

import 'package:animated_emoji/animated_emoji.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';

T call<T>(T Function() fun) => fun();

final birthDayOne = DateTime(birthYear, birthMonth, dayOne);
final birthDayTwo = DateTime(birthYear, birthMonth, dayTwo);

const birthYear = 2000;
const birthMonth = 2;
const dayOne = 10;
const dayTwo = 12;

DateTime get now => DateTime.now();

final nextBirthDayOne = call(() {
  final day = DateTime(
    now.year,
    birthMonth,
    dayOne,
  );
  if (now.isAfter(day)) return day.copyWith(year: day.year + 1);
  return day;
});

bool isBirthDayOne = call(() {
  final day = DateTime(
    now.year,
    birthMonth,
    dayOne,
  );
  final diff = now.difference(day);
  return diff.isNegative && diff.inHours <= 24;
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

bool isBirthDayTwo = call(() {
  final day = DateTime(
    now.year,
    birthMonth,
    dayTwo,
  );
  final diff = now.difference(day);
  return diff.isNegative && diff.inHours <= 24;
});

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Timer timer;
  late AudioPlayer player;
  var remainingFormattedDurationOne = formatDuration(
    nextBirthDayOne.difference(
      DateTime.now(),
    ),
  );

  var remainingFormattedDurationTwo = formatDuration(
    nextBirthDayTwo.difference(
      DateTime.now(),
    ),
  );
  @override
  void initState() {
    player = AudioPlayer();

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
                    // GestureDetector(
                    //   onTap: () {
                    //     player.play(AssetSource('audio/birthday.mp3'));
                    //   },
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       AnimatedEmoji(
                    //         AnimatedEmojis.partyPopper,
                    //         size: 100,
                    //       ),
                    //       AnimatedEmoji(
                    //         AnimatedEmojis.partyingFace,
                    //         size: 100,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // AnimatedEmoji(
                    //   AnimatedEmojis.birthdayCake,
                    //   size: 100,
                    // ),
                    Expanded(
                      child: timeView(remainingFormattedDurationOne),
                    ),
                    Expanded(
                      child: timeView(remainingFormattedDurationTwo),
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
