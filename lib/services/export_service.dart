import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:css_mastery_app/models/chat/chat_message_model.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  // ============================================================
  // 1. EXPORT CHAT HISTORY
  // ============================================================

  // Export as JSON
  static Future<String> exportChatAsJson(List<ChatMessage> messages) async {
    try {
      final jsonData = messages
          .map((msg) => {
                'id': msg.id,
                'text': msg.text,
                'isUser': msg.isUser,
                'timestamp': msg.timestamp.toIso8601String(),
                'topic': msg.topic,
                'hasCode': msg.hasCode,
                'codeContent': msg.codeContent,
                'codeLanguage': msg.codeLanguage,
              })
          .toList();

      return const JsonEncoder.withIndent('  ').convert({
        'exportDate': DateTime.now().toIso8601String(),
        'totalMessages': messages.length,
        'userMessages': messages.where((m) => m.isUser).length,
        'aiMessages': messages.where((m) => !m.isUser).length,
        'messages': jsonData,
      });
    } catch (e) {
      throw Exception('Failed to export chat as JSON: $e');
    }
  }

  // Export as TXT (Readable format)
  static Future<String> exportChatAsTxt(List<ChatMessage> messages) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('=' * 60);
      buffer.writeln('CSS MASTERY - CHAT HISTORY');
      buffer.writeln('=' * 60);
      buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
      buffer.writeln('Total Messages: ${messages.length}');
      buffer.writeln('-' * 60);
      buffer.writeln();

      for (var msg in messages) {
        final prefix = msg.isUser ? '🧑‍🎓 You' : '🤖 AI Tutor';
        final time = DateFormat('HH:mm').format(msg.timestamp);
        buffer.writeln('[$time] $prefix:');
        buffer.writeln(msg.text);
        if (msg.topic != null) {
          buffer.writeln('  📌 ${msg.topic}');
        }
        if (msg.hasCode && msg.codeContent != null) {
          buffer.writeln('  📝 Code (${msg.codeLanguage ?? 'text'}):');
          buffer.writeln('  ```');
          buffer.writeln(msg.codeContent!);
          buffer.writeln('  ```');
        }
        buffer.writeln();
      }

      buffer.writeln('-' * 60);
      buffer.writeln('End of chat history');
      buffer.writeln('=' * 60);

      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to export chat as TXT: $e');
    }
  }

  // Export as Markdown
  static Future<String> exportChatAsMarkdown(List<ChatMessage> messages) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('# CSS Mastery - Chat History');
      buffer.writeln();
      buffer.writeln('**Exported:** ${DateTime.now().toIso8601String()}');
      buffer.writeln('**Total Messages:** ${messages.length}');
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();

      for (var msg in messages) {
        final prefix = msg.isUser ? '**🧑‍🎓 You**' : '**🤖 AI Tutor**';
        final time = DateFormat('HH:mm').format(msg.timestamp);
        buffer.writeln('### $time - $prefix');
        buffer.writeln();
        buffer.writeln(msg.text);
        buffer.writeln();
        if (msg.topic != null) {
          buffer.writeln('> 📌 ${msg.topic}');
        }
        if (msg.hasCode && msg.codeContent != null) {
          buffer.writeln('```${msg.codeLanguage ?? 'text'}');
          buffer.writeln(msg.codeContent!);
          buffer.writeln('```');
        }
        buffer.writeln('---');
        buffer.writeln();
      }

      return buffer.toString();
    } catch (e) {
      throw Exception('Failed to export chat as Markdown: $e');
    }
  }



  // ============================================================
  // 3. SHARE PROGRESS
  // ============================================================

  static Future<void> shareProgress({
    required ProgressModel progress,
    required List<DayModel> days,
    required String userName,
  }) async {
    try {
      final totalDays = days.length;
      final completedDays =
          days.where((d) => d.status == DayStatus.completed).length;
      final completionRate = totalDays > 0 ? completedDays / totalDays : 0;

      final message = '''
📊 CSS Mastery - Progress Report

👤 $userName
📈 ${(completionRate * 100).toStringAsFixed(0)}% Complete
✅ $completedDays/$totalDays Days Completed
🔥 ${progress.streak} Day Streak
💪 ${(progress.consistency * 100).toStringAsFixed(0)}% Consistency

Keep learning! 💪
#CSSMastery #Learning #WebDevelopment
''';

      await Share.share(message);
    } catch (e) {
      throw Exception('Failed to share progress: $e');
    }
  }

  // ============================================================
  // 4. HELPER METHODS
  // ============================================================

  static List<Map<String, dynamic>> _getWeeklyBreakdown(List<DayModel> days) {
    final weeks = <Map<String, dynamic>>[];
    var currentWeek = 1;
    var weekDays = <DayModel>[];

    for (var day in days) {
      weekDays.add(day);
      if (weekDays.length == 7) {
        weeks.add({
          'weekNumber': currentWeek,
          'total': weekDays.length,
          'completed':
              weekDays.where((d) => d.status == DayStatus.completed).length,
          'percentage':
              ((weekDays.where((d) => d.status == DayStatus.completed).length /
                          weekDays.length) *
                      100)
                  .toStringAsFixed(0),
        });
        weekDays = [];
        currentWeek++;
      }
    }

    // Add remaining days as last week
    if (weekDays.isNotEmpty) {
      weeks.add({
        'weekNumber': currentWeek,
        'total': weekDays.length,
        'completed':
            weekDays.where((d) => d.status == DayStatus.completed).length,
        'percentage':
            ((weekDays.where((d) => d.status == DayStatus.completed).length /
                        weekDays.length) *
                    100)
                .toStringAsFixed(0),
      });
    }

    return weeks;
  }

  static List<Map<String, dynamic>> _getTopicBreakdown(List<DayModel> days) {
    final topicStats = <String, Map<String, int>>{};

    for (var day in days) {
      for (var topic in day.topics) {
        if (!topicStats.containsKey(topic.title)) {
          topicStats[topic.title] = {
            'total': 0,
            'completed': 0,
          };
        }
        topicStats[topic.title]!['total'] =
            (topicStats[topic.title]!['total'] ?? 0) + 1;
        if (day.completedTopics.any((t) => t.title == topic.title)) {
          topicStats[topic.title]!['completed'] =
              (topicStats[topic.title]!['completed'] ?? 0) + 1;
        }
      }
    }

    return topicStats.entries.map((entry) {
      final total = entry.value['total'] ?? 0;
      final completed = entry.value['completed'] ?? 0;
      return {
        'name': entry.key,
        'total': total,
        'completed': completed,
        'percentage':
            total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0',
      };
    }).toList();
  }

  // ============================================================
  // 5. GENERATE PROGRESS REPORT (PDF)
  // ============================================================

  static Future<Uint8List> generateProgressReportPdf({
    required ProgressModel progress,
    required List<DayModel> days,
    required String userName,
  }) async {
    final pdf = pw.Document();

    final totalDays = days.length;
    final completedDays =
        days.where((d) => d.status == DayStatus.completed).length;
    final pendingDays = days
        .where((d) =>
            d.status == DayStatus.pending || d.status == DayStatus.inProgress)
        .length;
    final offDays = days.where((d) => d.status == DayStatus.offDay).length;
    final completionRate = totalDays > 0 ? completedDays / totalDays : 0.0;

    final primaryColor = PdfColor.fromHex('#1A73E8');
    final secondaryColor = PdfColor.fromHex('#F8F9FA');
    final textColor = PdfColor.fromHex('#202124');
    final subTextColor = PdfColor.fromHex('#5F6368');
    final borderLight = PdfColor.fromHex('#DADCE0');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CSS Mastery Progress Report',
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Personal Learning Journey Status',
                      style: pw.TextStyle(
                        color: subTextColor,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(color: subTextColor, fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Learner: $userName',
                      style: pw.TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 15),

            // Overview Section
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Progress Circle Card
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: secondaryColor,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                      border: pw.Border.all(color: borderLight, width: 0.5),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Overall Completion',
                          style: pw.TextStyle(
                            color: subTextColor,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        // Beautiful visual progress circle
                        pw.Container(
                          width: 80,
                          height: 80,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.white,
                            border: pw.Border.all(
                              color: primaryColor,
                              width: 6,
                            ),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            '${(completionRate * 100).toStringAsFixed(0)}%',
                            style: pw.TextStyle(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          '$completedDays / $totalDays days completed',
                          style: pw.TextStyle(
                            color: textColor,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                // Overview Stats Card
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    height: 140,
                    decoration: pw.BoxDecoration(
                      color: secondaryColor,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                      border: pw.Border.all(color: borderLight, width: 0.5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Learning Stats',
                          style: pw.TextStyle(
                            color: subTextColor,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPdfStatItem('Current Streak', '${progress.streak} days', primaryColor),
                            _buildPdfStatItem('Consistency', '${(progress.consistency * 100).toStringAsFixed(0)}%', PdfColors.orange),
                          ],
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPdfStatItem('In Progress', '$pendingDays days', PdfColors.blueGrey),
                            _buildPdfStatItem('Rest / Off Days', '$offDays days', PdfColors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Weekly breakdown Header
            pw.Text(
              'Weekly Progress Breakdown',
              style: pw.TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            // Weekly progress table
            _buildWeeklyPdfTable(days, primaryColor, textColor, subTextColor, secondaryColor),
            pw.SizedBox(height: 20),

            // Topic Mastery Header
            pw.Text(
              'Topic Mastery Breakdown',
              style: pw.TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),

            // Topic Breakdown Table
            _buildTopicPdfTable(days, primaryColor, textColor, subTextColor, secondaryColor),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfStatItem(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildWeeklyPdfTable(
    List<DayModel> days,
    PdfColor primaryColor,
    PdfColor textColor,
    PdfColor subTextColor,
    PdfColor headerColor,
  ) {
    final weeks = _getWeeklyBreakdown(days);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(3),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Week', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Completed Days', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Completion Rate', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            ),
          ],
        ),
        // Table rows
        ...weeks.map((week) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('Week ${week['weekNumber']}', style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('${week['completed']} / ${week['total']} days', style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('${week['percentage']}%', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTopicPdfTable(
    List<DayModel> days,
    PdfColor primaryColor,
    PdfColor textColor,
    PdfColor subTextColor,
    PdfColor headerColor,
  ) {
    final topics = _getTopicBreakdown(days);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerColor),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('CSS Topic', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Completed Days', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Mastery Percentage', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
            ),
          ],
        ),
        // Table rows
        ...topics.map((topic) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(topic['name'] as String, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('${topic['completed']} / ${topic['total']}', style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('${topic['percentage']}%', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              ),
            ],
          );
        }),
      ],
    );
  }
}
