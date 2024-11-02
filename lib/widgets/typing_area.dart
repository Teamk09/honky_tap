// lib/widgets/typing_area.dart
import 'package:flutter/material.dart';

class TypingArea extends StatelessWidget {
  final String targetText;
  final int currentIndex;
  final String typedText;
  final double fontSize;
  final String fontFamily;

  const TypingArea({
    required this.targetText,
    required this.currentIndex,
    required this.typedText,
    required this.fontSize,
    required this.fontFamily,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: fontSize * 0.5,
            children: targetText.split(' ').asMap().entries.map((entry) {
              int wordIndex = entry.key;
              String word = entry.value;

              // Calculate the character range for this word
              int startIndex = targetText.split(' ')
                  .take(wordIndex)
                  .join(' ')
                  .length + (wordIndex > 0 ? 1 : 0);

              // Create a row of characters for this word
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...word.split('').asMap().entries.map((charEntry) {
                    int charIndex = startIndex + charEntry.key;
                    String char = charEntry.value;

                    Color charColor;
                    if (charIndex < currentIndex) {
                      // Character has been typed
                      charColor = charIndex < typedText.length &&
                                typedText[charIndex] == char
                          ? Colors.green
                          : Colors.red;
                    } else if (charIndex == currentIndex) {
                      // Current character
                      charColor = Colors.white;
                    } else {
                      // Not yet reached
                      charColor = Colors.grey;
                    }

                    return Text(
                      char,
                      style: TextStyle(
                        color: charColor,
                        fontSize: fontSize,
                        fontFamily: fontFamily,
                      ),
                    );
                  }),
                  // Add space after word
                  Text(
                    ' ',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}