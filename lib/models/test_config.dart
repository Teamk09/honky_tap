// lib/models/test_config.dart
enum TestMode {
  time,
  wordCount,
}

class TestConfig {
  final TestMode mode;
  final int value;

  TestConfig(this.mode, this.value);
}