// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class CountButton extends StatefulWidget {
  @override
  _CountButtonState createState() => _CountButtonState();
}

class _CountButtonState extends State<CountButton> {
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text('Counter $counter'),
      onPressed: () {
        setState(() {
          counter += 1;
        });
      },
    );
  }
}

void main() {
  test('Test pump on LiveWidgetController', () async {
    runApp(MaterialApp(home: Center(child: CountButton())));

    await SchedulerBinding.instance.endOfFrame;
    final WidgetController controller =
        LiveWidgetController(WidgetsBinding.instance);
    await controller.tap(find.text('Counter 0'));
    expect(find.text('Counter 0'), findsOneWidget);
    expect(find.text('Counter 1'), findsNothing);
    await controller.pump();
    expect(find.text('Counter 0'), findsNothing);
    expect(find.text('Counter 1'), findsOneWidget);
  });

  test('Input event array on LiveWidgetController', () async {
    final List<String> logs = <String>[];
    runApp(
      MaterialApp(
        home: Listener(
          onPointerDown: (PointerDownEvent event) => logs.add('down ${event.buttons}'),
          onPointerMove: (PointerMoveEvent event) => logs.add('move ${event.buttons}'),
          onPointerUp: (PointerUpEvent event) => logs.add('up ${event.buttons}'),
          child: const Text('test'),
        ),
      ),
    );
    await SchedulerBinding.instance.endOfFrame;
    final WidgetController controller =
        LiveWidgetController(WidgetsBinding.instance);

    final Offset location = controller.getCenter(find.text('test'));
    final List<PointerEventRecord> records = <PointerEventRecord>[
      PointerEventRecord(Duration.zero, <PointerEvent>[
        // Typically PointerAddedEvent is not used in testers, but for records
        // captured on a device it is usually what start a gesture.
        PointerAddedEvent(
          timeStamp: Duration.zero,
          position: location,
        ),
        PointerDownEvent(
          timeStamp: Duration.zero,
          position: location,
          buttons: kSecondaryMouseButton,
          pointer: 1,
        ),
      ]),
      ...<PointerEventRecord>[
        for (Duration t = const Duration(milliseconds: 5);
            t < const Duration(milliseconds: 80);
            t += const Duration(milliseconds: 16))
          PointerEventRecord(t, <PointerEvent>[
            PointerMoveEvent(
              timeStamp: t - const Duration(milliseconds: 1),
              position: location,
              buttons: kSecondaryMouseButton,
              pointer: 1,
            )
          ])
      ],
      PointerEventRecord(const Duration(milliseconds: 80), <PointerEvent>[
        PointerUpEvent(
          timeStamp: const Duration(milliseconds: 79),
          position: location,
          buttons: kSecondaryMouseButton,
          pointer: 1,
        )
      ])
    ];
    final List<Duration> timeDiffs =
        await controller.handlePointerEventRecord(records);

    expect(timeDiffs.length, records.length);
    for (final Duration diff in timeDiffs) {
      // Allow some freedom of time delay in real world.
      assert(diff.inMilliseconds > -1);
    }

    const String b = '$kSecondaryMouseButton';
    expect(logs.first, 'down $b');
    for (int i = 1; i < logs.length - 1; i++) {
      expect(logs[i], 'move $b');
    }
    expect(logs.last, 'up $b');
  });
}
