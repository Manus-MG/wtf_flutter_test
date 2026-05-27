String? validateNonEmpty(String? value, {String message = 'Required'}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? validateFutureDate(DateTime value, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  if (value.isBefore(reference)) {
    return 'Please pick a future time.';
  }
  return null;
}
