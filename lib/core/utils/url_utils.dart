/// Extracts a usable http(s) URL from pasted text, or returns null.
///
/// Handles share texts such as "Look at this https://vm.tiktok.com/abc"
/// and bare links such as "youtube.com/shorts/abc".
String? normalizeUrl(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;

  final match = RegExp(r'https?://\S+', caseSensitive: false).firstMatch(text);
  final candidate = match?.group(0) ?? (text.contains(' ') ? null : 'https://$text');
  if (candidate == null) return null;

  final uri = Uri.tryParse(candidate);
  if (uri == null || !uri.host.contains('.')) return null;
  return uri.toString();
}
