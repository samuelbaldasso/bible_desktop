class BibleApiException implements Exception {
  final String message;

  const BibleApiException(this.message);

  @override
  String toString() => message;
}
