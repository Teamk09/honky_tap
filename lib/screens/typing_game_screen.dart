import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/test_config.dart';
import '../models/wpm_point.dart';
import '../services/word_list.dart';
import '../widgets/typing_test_results.dart';
import '../widgets/typing_area.dart';
import '../widgets/test_controls.dart';
import '../widgets/settings_menu.dart';

class TypingGameScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final ThemeMode themeMode;
  final double fontSize;
  final Function(double) onFontSizeChanged;
  final String fontFamily;
  final Function(String) onFontFamilyChanged;

  const TypingGameScreen({
    required this.onThemeModeChanged,
    required this.themeMode,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.fontFamily,
    required this.onFontFamilyChanged,
    super.key,
  });

  @override
  State<TypingGameScreen> createState() => _TypingGameScreenState();
}

class _TypingGameScreenState extends State<TypingGameScreen> with WidgetsBindingObserver {
  String _targetText = "";
  String _typedText = "";
  int _currentIndex = 0;
  Timer? _timer;
  double _secondsElapsed = 0;
  int _secondsRemaining = 0;
  bool _isGameActive = false;
  TestConfig? _currentTest;
  List<WPMPoint> _wpmPoints = [];
  bool _showResults = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _customValueController = TextEditingController();
  TestMode _customTestMode = TestMode.time;
  int _correctChars = 0;
  int _totalChars = 0;
  LogicalKeyboardKey _resetKey = LogicalKeyboardKey.tab;
  Timer? _wpmTimer;

  final List<TestConfig> _presetTests = [
    TestConfig(TestMode.time, 15),
    TestConfig(TestMode.time, 30),
    TestConfig(TestMode.time, 60),
    TestConfig(TestMode.wordCount, 10),
    TestConfig(TestMode.wordCount, 50),
    TestConfig(TestMode.wordCount, 100),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();
    // Start with 15 second test by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTest(_presetTests[0]);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    _customValueController.dispose();
    _wpmTimer?.cancel();
    super.dispose();
  }

  double _calculateCurrentWPM() {
    if (_secondsElapsed == 0) return 0;
    // Convert seconds to minutes for WPM calculation
    double minutes = _secondsElapsed / 60;
    // Use correct characters for "net" WPM
    return (_correctChars / 5) / minutes;
  }

  double _calculateAccuracy() {
    if (_totalChars == 0) return 0;
    double accuracy = (_correctChars) / (_totalChars) * 100.0;
    return accuracy;
  }

  String _generateText(int wordCount) {
    final words = List.generate(wordCount, (index) => WordList.getRandomWord());
    return words.join(' ');
  }

  void _startTest(TestConfig config) {
    _timer?.cancel();
    _currentTest = config;
    setState(() {
      _isGameActive = false;
      _currentIndex = 0;
      _typedText = "";
      _secondsElapsed = 0;
      _correctChars = 0;
      _totalChars = 0;
      _wpmPoints = [];
      _showResults = false;

      if (config.mode == TestMode.wordCount) {
        _targetText = _generateText(config.value);
        _secondsRemaining = 0;
      } else {
        _targetText = _generateText(100);
        _secondsRemaining = config.value;
      }
    });
    _focusNode.requestFocus();
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _secondsElapsed = 0;
      _wpmPoints = [];
    });

    // Main timer for game duration
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }

      // Update time without triggering rebuild
      _secondsElapsed += 0.1;

      // Only rebuild if we need to update the UI (when seconds change)
      if (_currentTest?.mode == TestMode.time) {
        setState(() {
          _secondsRemaining = (_currentTest!.value - _secondsElapsed).ceil();
          if (_secondsRemaining <= 0) {
            _endGame();
          }
        });
      }
    });

    // WPM calculation timer
    _wpmTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!_isGameActive) {
        timer.cancel();
        return;
      }

      _wpmPoints.add(WPMPoint(
        double.parse(_secondsElapsed.toStringAsFixed(2)),
        double.parse(_calculateCurrentWPM().toStringAsFixed(2)),
        _calculateAccuracy(),
      ));
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isGameActive = false;
      _showResults = true;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Handle reset key
      if (event.logicalKey == _resetKey) {
        _startTest(_currentTest!);
        return;
      }

      // Handle Tab key for restart
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        _startTest(_currentTest!);
        return;
      }

      // Start game if not started
      if (!_isGameActive && _currentIndex == 0) {
        _startGame();
      }

      if (!_isGameActive) return;

      setState(() {
        if (event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_currentIndex > 0) {
            _currentIndex--;
            if (_typedText.isNotEmpty) {
              _typedText = _typedText.substring(0, _typedText.length - 1);
            }
            if (_totalChars > 0) {
              _totalChars--;
              // Only decrease correct chars if the deleted character was correct
              if (_correctChars > 0 &&
                  _currentIndex < _targetText.length &&
                  _typedText.length >= _currentIndex &&
                  _typedText.isNotEmpty &&
                  _currentIndex < _typedText.length &&
                  _targetText[_currentIndex] == _typedText[_currentIndex]) {
                _correctChars--;
              }
            }
          }
        } else if (event.character != null &&
                   event.character!.length == 1 &&
                   RegExp(r'[ a-zA-Z]').hasMatch(event.character!)) {
          if (_currentIndex < _targetText.length) {
            _typedText += event.character!;
            _totalChars++;
            if (event.character! == _targetText[_currentIndex]) {
              _correctChars++;
            }
            _currentIndex++;

            if (_currentTest?.mode == TestMode.wordCount &&
                _currentIndex == _targetText.length) {
              _endGame();
            }
          }
        }
      });
    }
  }

  void _showCustomTestDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Custom Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<TestMode>(
                value: _customTestMode,
                items: TestMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode == TestMode.time ? 'Time (seconds)' : 'Word Count'),
                  );
                }).toList(),
                onChanged: (TestMode? newValue) {
                  setDialogState(() {
                    _customTestMode = newValue ?? TestMode.time;
                  });
                },
              ),
              TextField(
                controller: _customValueController,
                decoration: const InputDecoration(
                  hintText: 'Enter value',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(_customValueController.text);
                if (value != null && value > 0) {
                  Navigator.pop(context);
                  setState(() {
                    _customTestMode = _customTestMode; // Update the parent state
                  });
                  _startTest(TestConfig(_customTestMode, value));
                }
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu() {
    showDialog(
      context: context,
      builder: (context) => SettingsMenu(
        resetKey: _resetKey,
        onResetKeyChanged: (key) {
          setState(() {
            _resetKey = key;
          });
        },
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        onWordListChanged: () {
          _startTest(_currentTest!);
        },
        fontSize: widget.fontSize,
        onFontSizeChanged: widget.onFontSizeChanged,
        fontFamily: widget.fontFamily,
        onFontFamilyChanged: widget.onFontFamilyChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return Scaffold(
        body: TypingTestResults(
          wpmPoints: _wpmPoints,
          secondsElapsed: _secondsElapsed,
          onRetry: () => _startTest(_currentTest!),
          onNewTest: () => _startTest(_presetTests[0]),
          resetKey: _resetKey,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsMenu,
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TestControls(
                presetTests: _presetTests,
                onTestSelected: _startTest,
                onCustomTest: _showCustomTestDialog,
              ),
              const SizedBox(height: 20),
              if (_currentTest?.mode == TestMode.time && _secondsRemaining > 0)
                Text(
                  'Time remaining: $_secondsRemaining seconds',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 20),
              TypingArea(
                targetText: _targetText,
                currentIndex: _currentIndex,
                typedText: _typedText,
                fontSize: widget.fontSize,
                fontFamily: widget.fontFamily,
              ),
              const SizedBox(height: 20),
              Text(
                'WPM: ${_calculateCurrentWPM().toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 24),
              ),
              const Text(
                'Press Tab to restart test',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
