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

    // 1. Pre-process image (assuming 224x224 input for common TFLite models)
    var imageBytes = imageFile.readAsBytesSync();
    var decoder = img.decodeImage(imageBytes);
    var resized = img.copyResize(decoder!, width: 224, height: 224);
    
    // 2. Convert to input tensor
    var input = List.generate(1, (i) => 
      List.generate(224, (j) => 
        List.generate(224, (k) => 
          List.generate(3, (l) {
            var pixel = resized.getPixel(k, j);
            // return [pixel.r, pixel.g, pixel.b][l] / 255.0;
            return ([pixel.r, pixel.g, pixel.b][l] / 127.5) - 1.0;
          })
        )
      )
    );

    // 3. Run Inference
    var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);
    _interpreter!.run(input, output);

    // 4. Find best label
    int bestIndex = 0;
    double maxProb = -1.0;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxProb) {
        maxProb = output[0][i];
        bestIndex = i;
      }
    }

    // Return clean label (removing the index number "0 GLASS" -> "GLASS")
    return _labels![bestIndex].split(' ').last;
  }
}