import 'package:flutter/material.dart';
import '../models/test_config.dart';

class TestControls extends StatelessWidget {
  final List<TestConfig> presetTests;
  final Function(TestConfig) onTestSelected;
  final VoidCallback onCustomTest;

  const TestControls({
    required this.presetTests,
    required this.onTestSelected,
    required this.onCustomTest,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...presetTests.map((config) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            onPressed: () => onTestSelected(config),
            child: Text(
              config.mode == TestMode.time
                  ? '${config.value}s'
                  : '${config.value} words'
            ),
          ),
        )),
        ElevatedButton(
          onPressed: onCustomTest,
          child: const Text('Custom'),
        ),
      ],
    );
  }
}