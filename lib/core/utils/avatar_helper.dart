import 'dart:convert';
import 'package:flutter/material.dart';

class AvatarHelper {
  static ImageProvider? getImageProvider(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;

    if (avatar.startsWith('http')) {
      return NetworkImage(avatar);
    }

    // Check if it's base64
    try {
      // Remove data URI prefix if present
      String base64Str = avatar;
      if (avatar.contains('base64,')) {
        base64Str = avatar.split('base64,').last;
      }
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      return null;
    }
  }
}
