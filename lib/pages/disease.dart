import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PlantDiseasePredictor extends StatefulWidget {
  const PlantDiseasePredictor({super.key});

  @override
  _PlantDiseasePredictorState createState() => _PlantDiseasePredictorState();
}

class _PlantDiseasePredictorState extends State<PlantDiseasePredictor> {
  File? _image;
  String? _prediction;
  bool _isLoading = false;
  bool _isModelLoaded = false;
  String? _errorMessage;
  late Interpreter _interpreter;

  final List<String> _diseaseLabels = [
    'Pepper Bell Bacterial Spot',
    'Pepper Bell Healthy',
    'Potato Early Blight',
    'Potato Healthy',
    'Potato Late Blight',
    'Tomato Bacterial Spot',
    'Tomato Early Blight',
    'Tomato Healthy',
    'Tomato Late Blight',
    'Tomato Leaf Mold',
    'Tomato Septoria Leaf Spot',
    'Tomato Spotted Spider Mites',
    'Tomato Target Spot',
    'Tomato Mosaic Virus',
    'Tomato Yellow Leaf Curl Virus',
  ];

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _interpreter =
          await Interpreter.fromAsset('assets/models/model_unquant.tflite');
      setState(() => _isModelLoaded = true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load model: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> uploadImage() async {
    if (!_isModelLoaded) {
      setState(() => _errorMessage = 'Please wait for the model to load');
      return;
    }

    try {
      // Picking image files only with specific extensions
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;

        final imageBytes = await File(filePath).readAsBytes();
        final image = img.decodeImage(imageBytes);
        if (image != null) {
          final width = image.width;
          final height = image.height;

          if (width != height) {
            setState(() {
              _errorMessage = 'This is not a valid image.';
            });
            return;
          }
        } else {
          setState(() {
            _errorMessage = 'This is not a valid image.';
          });
          return;
        }

        setState(() {
          _image = File(filePath);
          _isLoading = true;
          _errorMessage = null;
          _prediction = null;
        });

        await predictImage(filePath);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to upload image: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> predictImage(String imagePath) async {
    try {
      final input = await _loadImage(imagePath);
      final output = List.filled(15, 0.0).reshape([1, 15]);

      _interpreter.run(input, output);

      final predictions = output[0];
      var maxScore = predictions[0];
      var maxIndex = 0;

      for (var i = 1; i < predictions.length; i++) {
        if (predictions[i] > maxScore) {
          maxScore = predictions[i];
          maxIndex = i;
        }
      }

      setState(() {
        _prediction = '${_diseaseLabels[maxIndex]}\n'
            'Confidence: ${(maxScore * 100).toStringAsFixed(1)}%';
      });
    } catch (e) {
      setState(
          () => _errorMessage = 'Error during prediction: ${e.toString()}');
    }
  }

  Future<List<List<List<List<double>>>>> _loadImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    final resizedImage = img.copyResize(image, width: 224, height: 224);

    return List.generate(
      1,
      (i) => List.generate(
        224,
        (j) => List.generate(
          224,
          (k) => List.generate(
            3,
            (l) {
              final pixel = resizedImage.getPixel(k, j);
              final r = pixel.r.toDouble() / 255.0;
              final g = pixel.g.toDouble() / 255.0;
              final b = pixel.b.toDouble() / 255.0;

              if (l == 0) return r;
              if (l == 1) return g;
              return b;
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Predictor'),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_image == null)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('No image selected'),
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing...'),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: uploadImage,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Image'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_prediction != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _prediction!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
