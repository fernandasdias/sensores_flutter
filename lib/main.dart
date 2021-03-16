// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

import 'snake.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  List<double> _accelerometerValues;
  List<int> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  int _countUpDown = 0;
  String _position = "";

  void counterUp() {
    if (_position != 'Up') {
      _countUpDown++;
    }
  }

  void counterDown() {
    if (_position != 'Down') {
      _countUpDown++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues != null
        ? _userAccelerometerValues.map((int v) => v.toStringAsFixed(1)).toList()
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
              child: SizedBox(
                height: _snakeRows * _snakeCellSize,
                width: _snakeColumns * _snakeCellSize,
                child: Snake(
                  rows: _snakeRows,
                  columns: _snakeColumns,
                  cellSize: _snakeCellSize,
                ),
              ),
            ),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(onPressed: () => start(), child: Text('Start')),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(onPressed: () => stop(), child: Text('Stop')),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  static int mult = 100000;
  @override
  void initState() {
    super.initState();
  }

  void stop() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void start() {
    bool isArmElevated = false;
    int count = 0;
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        if (event.y > 4) {
          isArmElevated = true;
          print('arm up');
        } else if (event.y < -4) {
          print('arm down');
          isArmElevated = true;
        } else
          isArmElevated = false;

        _accelerometerValues = <double>[event.x, event.y, event.z];
        if (event.y >= 0) {
          counterUp();
          _position = "Up";
          print('Count: $_countUpDown, Position: $_position');
        } else {
          counterDown();
          _position = 'Down';
          print('Count: $_countUpDown, Position: $_position');
        }
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      double accelResults =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      setState(() {
        // print(accelResults.toStringAsFixed(2));
        if (accelResults >= 4 && isArmElevated) {
          print('play sound');
          count++;
          print(count);
          // var audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
          // AudioPlayer.logEnabled = true;
          // AudioCache player = new AudioCache();
          // await audioPlayer.play('assets/correct_sound.mp3');
        }
        _userAccelerometerValues = <int>[
          (event.x * mult).truncate(),
          (event.y * mult).truncate(),
          (event.z * mult).truncate()
        ];
      });
      milliseconds.add(DateTime.now().millisecond);

      new_time = DateTime.now().millisecond - old; //difference

      old = new_time;
    }));
  }

  int old = DateTime.now().millisecond;
  int new_time = 0;
  int difference = 0;
  static List<int> milliseconds = new List<int>();
  printData() {
    // print(
    //     '\n old time  ' + old.toString() + '  new time ' + new_time.toString());
    // print(_userAccelerometerValues);
  }
}
