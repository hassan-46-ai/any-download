String mimeForExtension(String extension) {
  return switch (extension.toLowerCase()) {
    'mp4' || 'm4v' => 'video/mp4',
    'webm' => 'video/webm',
    'mkv' => 'video/x-matroska',
    'mov' => 'video/quicktime',
    'm4a' => 'audio/mp4',
    'mp3' => 'audio/mpeg',
    'aac' => 'audio/aac',
    'opus' || 'ogg' => 'audio/ogg',
    'wav' => 'audio/wav',
    'flac' => 'audio/flac',
    'jpg' || 'jpeg' => 'image/jpeg',
    'png' => 'image/png',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    _ => 'application/octet-stream',
  };
}
