import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'local_file_image_io.dart'
    if (dart.library.html) 'local_file_image_web.dart'
    as impl;

/// Returns an [ImageProvider] for a local file path when supported (mobile/desktop).
/// Returns null on web (and when [path] is null/empty).
ImageProvider? localFileImageProvider(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  return impl.localFileImageProvider(path);
}

/// Debug-only helper so callers can choose fallback behavior on web.
bool get isWeb => kIsWeb;

