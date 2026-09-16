import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/app_user.dart';

class ProfilePhotoService {
  static const maxBytes = 2 * 1024 * 1024;
  static const maxStoredBytes = 200 * 1024;

  static const _imageTypes = XTypeGroup(
    label: 'Foto de perfil PNG o JPEG',
    extensions: ['png', 'jpg', 'jpeg'],
    mimeTypes: ['image/png', 'image/jpeg'],
  );

  static Future<String?> pickAndSave(AppUser user) async {
    final file = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (file == null) return null;
    if (await file.length() > maxBytes) {
      throw const FormatException('La foto debe pesar 2 MB o menos');
    }
    final bytes = await file.readAsBytes();
    if (imageContentType(bytes) == null) {
      throw const FormatException('Selecciona una imagen PNG o JPEG válida');
    }
    final thumbnail = await makeThumbnail(bytes);
    if (Firebase.apps.isEmpty) {
      throw StateError('El almacenamiento de fotos no está disponible');
    }
    final encoded = base64Encode(thumbnail);
    await FirebaseFirestore.instance.collection('users').doc(user.id).update({
      'photoData': encoded,
    });
    return encoded;
  }

  static Future<Uint8List> makeThumbnail(Uint8List bytes) async {
    try {
      for (final width in [192, 160, 128]) {
        final codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: width,
          allowUpscaling: false,
        );
        final frame = await codec.getNextFrame();
        final data = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        frame.image.dispose();
        codec.dispose();
        if (data == null) continue;
        final thumbnail = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        if (thumbnail.length <= maxStoredBytes) return thumbnail;
      }
      throw const FormatException('La imagen no se pudo reducir lo suficiente');
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('La imagen seleccionada está dañada');
    }
  }

  static String? imageContentType(Uint8List bytes) {
    if (bytes.length > maxBytes) return null;
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    return null;
  }
}
