import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassifierService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('model_ai/model.tflite');
    final labelData = await rootBundle.loadString('model_ai/labels.txt');
    _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
  }

  Future<String> classifyImage(File imageFile) async {
    if (_interpreter == null) await loadModel();

    // 1. Pre-process image
    var imageBytes = imageFile.readAsBytesSync();
    var decoder = img.decodeImage(imageBytes);

    if (decoder == null) {
      return "Error: Gagal decode gambar";
    }

    // PERBAIKAN 1: Gunakan copyResizeCropSquare (Wajib!)
    // Teachable Machine memotong tengah (center crop), bukan menarik gambar (stretch).
    // Jika pakai copyResize biasa, gambar jadi gepeng dan model bingung.
    var resized = img.copyResizeCropSquare(decoder, size: 224);
    
    // 2. Convert to input tensor [1, 224, 224, 3]
    var input = List.generate(1, (batch) => 
      List.generate(224, (y) => 
        List.generate(224, (x) => 
          List.generate(3, (c) {
            var pixel = resized.getPixel(x, y);
            
            // Ambil nilai RGB dari pixel
            double value = 0;
            if (c == 0) value = pixel.r.toDouble(); // Red
            if (c == 1) value = pixel.g.toDouble(); // Green
            if (c == 2) value = pixel.b.toDouble(); // Blue

            // PERBAIKAN 2: Normalisasi Standar Teachable Machine (Wajib!)
            // Rumus: (Value - 127.5) / 127.5 -> Hasilnya rentang -1.0 sampai 1.0
            // Kode lama Anda: value / 255.0 -> Hasilnya 0.0 sampai 1.0 (Ini salah untuk TM)
            return (value - 127.5) / 127.5;
          })
        )
      )
    );

    // 3. Run Inference
    var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);
    _interpreter!.run(input, output);

    // 4. Cari probabilitas tertinggi
    int bestIndex = 0;
    double maxProb = -100.0;
    List<dynamic> probs = output[0]; 

    for (int i = 0; i < probs.length; i++) {
      if (probs[i] > maxProb) {
        maxProb = probs[i];
        bestIndex = i;
      }
    }

    // Return label bersih (Hapus angka index jika ada)
    return _labels![bestIndex].replaceAll(RegExp(r'^\d+\s*'), '').trim();
  }
}