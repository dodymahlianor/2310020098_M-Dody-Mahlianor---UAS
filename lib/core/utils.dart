String stripHtml(String input) {
  // deskripsi kadang berformat html/markup
  final noTags = input.replaceAll(RegExp(r'<[^>]*>'), '');
  return noTags.replaceAll('&nbsp;', ' ').trim();
}

String pad3(int n) => n.toString().padLeft(3, '0');
