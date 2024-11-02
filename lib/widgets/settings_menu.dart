import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/word_list.dart';

class SettingsMenu extends StatefulWidget {
  final LogicalKeyboardKey resetKey;
  final Function(LogicalKeyboardKey) onResetKeyChanged;
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeModeChanged;
  final VoidCallback onWordListChanged;
  final double fontSize;
  final Function(double) onFontSizeChanged;
  final String fontFamily;
  final Function(String) onFontFamilyChanged;

  const SettingsMenu({
    required this.resetKey,
    required this.onResetKeyChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onWordListChanged,
    required this.fontSize,
    required this.onFontSizeChanged,
    required this.fontFamily,
    required this.onFontFamilyChanged,
    super.key,
  });

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool _listeningForKey = false;
  String _selectedWordList = WordList.getCurrentList();

  final List<String> _availableFonts = [
    'Roboto Mono',
    'Courier New',
    'Fira Code',
    'Source Code Pro',
  ];

  void _startListeningForKey() {
    setState(() {
      _listeningForKey = true;
    });
  }

  Widget buildDialog() {
    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reset Key Setting
          const Text('Reset Test Key:', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text(_listeningForKey
              ? 'Press any key...'
              : widget.resetKey.keyLabel),
            onTap: _startListeningForKey,
          ),

          const SizedBox(height: 16),

          // Word List Setting
          const Text('Word List:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedWordList,
            items: WordList.availableLists.map((list) {
              String label = list == 'english_1k' ? 'English 1K words' : 'English 5K words';
              return DropdownMenuItem(
                value: list,
                child: Text(label),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                await WordList.loadWordList(value);
                setState(() {
                  _selectedWordList = value;
                });
                widget.onWordListChanged();
              }
            },
          ),

          const SizedBox(height: 16),

          // Theme Setting
          const Text('Theme:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<ThemeMode>(
            value: widget.themeMode,
            items: ThemeMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onThemeModeChanged(value);
              }
            },
          ),

          const SizedBox(height: 16),

          // Font Size Setting
          const Text('Font Size:', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: widget.fontSize,
                  min: 16,
                  max: 96,
                  divisions: 16,
                  label: widget.fontSize.round().toString(),
                  onChanged: widget.onFontSizeChanged,
                ),
              ),
              Text('${widget.fontSize.round()}px'),
            ],
          ),

          const SizedBox(height: 16),

          // Font Family Setting
          const Text('Font:', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: widget.fontFamily,
            items: _availableFonts.map((font) {
              return DropdownMenuItem(
                value: font,
                child: Text(font, style: TextStyle(fontFamily: font)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                widget.onFontFamilyChanged(value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (_listeningForKey && event is KeyDownEvent) {
          widget.onResetKeyChanged(event.logicalKey);
          setState(() {
            _listeningForKey = false;
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: buildDialog(),
    );
  }
}
