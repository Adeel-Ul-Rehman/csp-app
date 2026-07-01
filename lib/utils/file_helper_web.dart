// lib/utils/file_helper_web.dart
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

Future<String> saveAndShare({
  required String fileName,
  required String shareSubject,
  String? content,
  Uint8List? bytes,
}) async {
  List<int> fileData;
  String mimeType;
  
  if (bytes != null) {
    fileData = bytes;
    mimeType = fileName.endsWith('.pdf') ? 'application/pdf' : 'application/octet-stream';
  } else if (content != null) {
    fileData = utf8.encode(content);
    mimeType = 'text/plain';
  } else {
    throw ArgumentError('Either content or bytes must be provided');
  }

  final blob = html.Blob([fileData], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
  return 'downloaded://$fileName';
}
