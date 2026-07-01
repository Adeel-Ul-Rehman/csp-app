import 'package:flutter/material.dart';
import 'package:css_mastery_app/models/chat/chat_message_model.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/services/export_service.dart';
import 'package:css_mastery_app/utils/file_helper.dart';

class ExportProvider extends ChangeNotifier {
  bool _isExporting = false;
  String? _error;

  bool get isExporting => _isExporting;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<String?> exportChatHistory({
    required List<ChatMessage> messages,
    required String format,
  }) async {
    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      if (messages.isEmpty) {
        throw Exception('No messages to export');
      }

      String content;
      String extension;
      
      switch (format.toLowerCase()) {
        case 'json':
          content = await ExportService.exportChatAsJson(messages);
          extension = 'json';
          break;
        case 'markdown':
        case 'md':
          content = await ExportService.exportChatAsMarkdown(messages);
          extension = 'md';
          break;
        case 'txt':
        default:
          content = await ExportService.exportChatAsTxt(messages);
          extension = 'txt';
          break;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'css_chat_history_$timestamp.$extension';
      
      // Save and share using web-compatible file helper
      final path = await saveAndShare(
        content: content,
        fileName: fileName,
        shareSubject: 'CSS Tutor Chat History',
      );

      _isExporting = false;
      notifyListeners();
      return path;
    } catch (e) {
      _error = e.toString();
      _isExporting = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> generateProgressReport({
    required ProgressModel progress,
    required List<DayModel> days,
    required String userName,
    required Function(String path) onSuccess,
  }) async {
    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      final bytes = await ExportService.generateProgressReportPdf(
        progress: progress,
        days: days,
        userName: userName,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'css_progress_report_$timestamp.pdf';
      
      // Save and share report using web-compatible file helper
      final path = await saveAndShare(
        bytes: bytes,
        fileName: fileName,
        shareSubject: 'CSS Mastery Progress Report',
      );

      _isExporting = false;
      notifyListeners();
      onSuccess(path);
    } catch (e) {
      _error = e.toString();
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<void> shareProgress({
    required ProgressModel progress,
    required List<DayModel> days,
    required String userName,
  }) async {
    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      await ExportService.shareProgress(
        progress: progress,
        days: days,
        userName: userName,
      );
      _isExporting = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isExporting = false;
      notifyListeners();
    }
  }
}
