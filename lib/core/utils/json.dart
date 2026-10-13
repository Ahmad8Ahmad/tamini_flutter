/// Extracts a list of models from a DRF-style response.
///
/// Reads the payload from `results` (DRF default) or `data`, falling back to an
/// empty list for anything else, so callers never have to guard against a
/// malformed body.
List<T> extractResults<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = data['results'] ?? data['data'] ?? [];
  if (raw is! List) return [];
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}
