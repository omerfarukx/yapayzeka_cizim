import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/drawing_point.dart';
import '../models/drawing_points.dart';

class DrawingService {
  static Future<ui.Image?> convertDrawingToImage(
    List<DrawingPoint> points,
    Size size,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Hedef boyutlar (1024x1024)
    const targetSize = Size(1024, 1024);

    // Ölçekleme faktörünü hesapla
    final scale = targetSize.width / size.width;
    canvas.scale(scale);

    // Beyaz arka plan
    final background = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, background);

    // Çizim noktaları
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i + 1].point == Offset.infinite) continue;

      canvas.drawLine(
        points[i].point,
        points[i + 1].point,
        points[i].paint,
      );
    }

    final picture = recorder.endRecording();
    return picture.toImage(targetSize.width.toInt(), targetSize.height.toInt());
  }

  static Future<String> saveDrawingToFile(
      List<DrawingPoint> points, Size size) async {
    try {
      final image = await convertDrawingToImage(points, size);
      if (image == null) throw Exception('Çizim görüntüye dönüştürülemedi');

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Görüntü verisi alınamadı');

      final bytes = byteData.buffer.asUint8List();

      // Uygulama dökümanlar dizinini al
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      // Dizin yoksa oluştur
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Dosya adı oluştur
      final fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${imagesDir.path}/$fileName';

      // Dosyayı kaydet
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Çizim kaydedilemedi: $e');
    }
  }

  static Future<String> getDrawingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir.path;
  }
}
