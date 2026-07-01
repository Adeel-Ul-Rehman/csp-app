class QuoteModel {
  final String id;
  final String text;
  final String author;
  final String? category;
  final DateTime fetchedDate;
  final bool isMorningQuote;

  QuoteModel({
    required this.id,
    required this.text,
    required this.author,
    this.category,
    required this.fetchedDate,
    this.isMorningQuote = true,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] ?? json['quote'] ?? json['content'] ?? '',
      author: json['author'] ?? json['from'] ?? 'Unknown',
      category: json['category'] ?? json['tags']?.join(', '),
      fetchedDate: DateTime.now(),
      isMorningQuote: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'fetchedDate': fetchedDate.toIso8601String(),
      'isMorningQuote': isMorningQuote,
    };
  }

  @override
  String toString() {
    return '"$text" — $author';
  }
}
