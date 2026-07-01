// lib/services/voice_service.dart

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _recognizedText = '';
  String _error = '';

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get recognizedText => _recognizedText;
  String get error => _error;

  VoiceService() {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('🎤 Speech Status: $status');
          if (status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('🎤 Speech Error: $error');
          _error = error.toString();
          _isListening = false;
          notifyListeners();
        },
      );

      if (_isAvailable) {
        debugPrint('🎤 Speech recognition initialized successfully');
      } else {
        debugPrint('🎤 Speech recognition not available');
        _error = 'Speech recognition not available on this device';
      }

      notifyListeners();
    } catch (e) {
      debugPrint('🎤 Initialization error: $e');
      _error = e.toString();
      _isAvailable = false;
      notifyListeners();
    }
  }

  Future<bool> checkPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Open app settings to enable permission
      await openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> startListening({
    VoidCallback? onResult,
    VoidCallback? onError,
  }) async {
    if (!_isAvailable) {
      _error = 'Speech recognition not available';
      notifyListeners();
      if (onError != null) onError();
      return;
    }

    final hasPermission = await checkPermission();
    if (!hasPermission) {
      _error = 'Microphone permission denied';
      notifyListeners();
      if (onError != null) onError();
      return;
    }

    try {
      _recognizedText = '';
      _isListening = true;
      _error = '';
      notifyListeners();

      await _speech.listen(
        onResult: (result) {
          debugPrint('🎤 Result: ${result.recognizedWords}');
          _recognizedText = result.recognizedWords;
          notifyListeners();
          if (onResult != null) onResult();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        // ignore: deprecated_member_use
        partialResults: true,
        onSoundLevelChange: (level) {
          // Sound level feedback (0-1)
        },
      );
    } catch (e) {
      debugPrint('🎤 Start listening error: $e');
      _error = e.toString();
      _isListening = false;
      notifyListeners();
      if (onError != null) onError();
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  void cancelListening() {
    if (_isListening) {
      _speech.cancel();
      _isListening = false;
      _recognizedText = '';
      notifyListeners();
    }
  }

  void reset() {
    _recognizedText = '';
    _error = '';
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
