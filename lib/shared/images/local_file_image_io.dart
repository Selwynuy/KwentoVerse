import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider? localFileImageProvider(String path) {
  return FileImage(File(path));
}

