// lib/utils/file_helper_stub.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<String> saveAndShare({
  required String fileName,
  required String shareSubject,
  String? content,
  Uint8List? bytes,
}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  if (bytes != null) {
    await file.writeAsBytes(bytes);
  } else if (content != null) {
    await file.writeAsString(content);
  } else {
    throw ArgumentError('Either content or bytes must be provided');
  }
  await Share.shareXFiles(
    [XFile(file.path)],
    text: '📚 $shareSubject\n\nExported from CSS Mastery App',
    subject: shareSubject,
  );
  return file.path;
}
