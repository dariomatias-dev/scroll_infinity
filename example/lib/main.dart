import 'package:flutter/material.dart';

class ScrollInfinityExample extends StatefulWidget {
  const ScrollInfinityExample({super.key});

  @override
  State<ScrollInfinityExample> createState() => _ScrollInfinityExampleState();
}

class _ScrollInfinityExampleState extends State<ScrollInfinityExample> {
  static final _enableTitles = <String>[
    'Header',
    'Interval',
    'Initial Items',
    'Loader',
  ];
  final _enables = List.filled(_enableTitles.length, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Text(
                  'Enable:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(),
              ...List.generate(
                _enableTitles.length,
                (index) {
                  return SwitchListTile(
                    onChanged: (value) {
                      setState(() {
                        _enables[index] = value;
                      });
                    },
                    value: _enables[index],
                    title: Text(
                      _enableTitles[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Access'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
