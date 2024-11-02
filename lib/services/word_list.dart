// lib/services/word_list.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class WordList {
  static List<String> _words = [];
  static bool _isInitialized = false;
  static String _currentList = 'english_1k';
  static const List<String> availableLists = ['english_1k', 'english_5k'];

  static Future<void> initialize() async {
    if (_isInitialized) return;
    await loadWordList(_currentList);
  }

  static Future<void> loadWordList(String listName) async {
    try {
      String fileName = listName == 'english_1k' ? 'words_1k.json' : 'words_5k.json';
      print('Loading word list: $fileName');

      final String jsonString = await rootBundle.loadString('assets/$fileName');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      if (jsonMap['name'] == listName) {
        final List<dynamic> wordList = jsonMap['words'];
        _words = wordList.map((word) => word.toString()).toList();
        _currentList = listName;
        _isInitialized = true;
        print('Successfully loaded ${_words.length} words');
        print('Sample words: ${_words.take(5)}');
      }
    } catch (e) {
      print('Error loading words: $e');
      _words = ['the', 'be', 'to', 'of', 'and'];
    }
  }

  static String getCurrentList() {
    return _currentList;
  }

  static String getRandomWord() {
    if (_words.isEmpty) return 'error';
    String word = _words[Random().nextInt(_words.length)];
    return word;
  }
}