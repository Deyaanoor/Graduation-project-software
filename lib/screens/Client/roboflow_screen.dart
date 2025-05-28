import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class RoboflowScreen extends StatefulWidget {
  const RoboflowScreen({super.key});

  @override
  State<RoboflowScreen> createState() => _RoboflowScreenState();
}

class _RoboflowScreenState extends State<RoboflowScreen> {
  Uint8List? _originalImageBytes;
  Uint8List? _analyzedImageBytes;
  List<dynamic> _predictions = [];
  bool _isLoading = false;
  final _httpClient = http.Client();
  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      final imageBytes = await pickedFile.readAsBytes();

      setState(() {
        _originalImageBytes = imageBytes;
        _analyzedImageBytes = null;
        _isLoading = true;
      });

      final response = await _sendToRoboflow(imageBytes).timeout(
        const Duration(seconds: 15),
        onTimeout: () => http.Response('Request Timeout', 408),
      );

      _handleResponse(response, imageBytes);
    } on TimeoutException {
      _showError('Request timed out');
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndAnalyzeImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndAnalyzeImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void selectImage() {
    if (kIsWeb) {
      _pickAndAnalyzeImage(ImageSource.gallery);
    } else {
      _showImageSourceOptions();
    }
  }

  String fuzzyLogic(String symbol, double confidence) {
    String message = getWarningMessage(symbol);

    if (confidence >= 0.9) {
      message = getWarningMessage(symbol);
    } else if (confidence >= 0.7) {
      message =
          "${getWarningMessage(symbol)}\nThere might be an issue with '$symbol'.\n\nIt is recommended to check your vehicle.";
    } else if (confidence >= 0.5) {
      message =
          "${getWarningMessage(symbol)}\nThe analysis is uncertain.\n\nThe likelihood of accurately identifying the issue with '$symbol' is low, but it is recommended to have the vehicle inspected.";
    } else {
      message =
          "${getWarningMessage(symbol)}\nUncertain warning.\n\nIt’s best to check your vehicle just in case.";
    }

    return message;
  }

  String getWarningMessage(String symbol) {
    switch (symbol) {
      case 'Anti Lock Braking System':
        return '🚨 ABS Warning:\nPossible issue with the anti-lock braking system.\nThis may affect braking safety. Please visit a service center.';
      case 'Braking System Issue':
        return '🛑 Brake Alert:\nThere’s a problem with the braking system.\nAvoid driving and seek immediate inspection.';
      case 'Charging System Issue':
        return '🔋 Charging Warning:\nIssue detected in the battery charging system.\nCheck alternator and battery to avoid sudden shutdown.';
      case 'Check Engine':
        return '⚠️ Engine Alert:\nA potential problem was found in the engine.\nHave it diagnosed by a professional.';
      case 'Electronic Stability Problem (ESP)':
        return '🌀 ESP Warning:\nThere’s a fault in the Electronic Stability Program.\nMay affect control on slippery roads. Drive carefully.';
      case 'Engine Overheating Warning Light':
        return '🔥 Overheating Alert:\nEngine temperature is too high.\nStop your vehicle and check coolant levels immediately.';
      case 'Low Engine Oil Warning Light':
        return '🛢️ Oil Warning:\nEngine oil level is low.\nAdd oil to prevent serious engine damage.';
      case 'Low Tire Pressure Warning Light':
        return '⚠️ Tire Pressure:\nLow air pressure detected in tires.\nCheck and inflate tires to recommended levels.';
      case 'Master warning light':
        return '❗ General Warning:\nAn issue has been detected.\nCheck vehicle info screen or consult a technician.';
      case 'SRS-Airbag':
        return '🎈 Airbag System:\nA fault was found in the airbag system.\nAirbags may not deploy during an accident. Service is required.';
      case 'Seat Belt Reminder':
        return '🔔 Seat Belt Reminder:\nPlease fasten your seatbelt.\nDriving without it is unsafe and illegal.';
      default:
        return '❓ Unknown Warning:\nThe symbol is not recognized.\nPlease refer to your vehicle manual or a mechanic.';
    }
  }

  Future<http.Response> _sendToRoboflow(Uint8List imageBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://detect.roboflow.com/car-dashboard-icons/2?api_key=fFHdqd3otTUHxDSUBlBi',
      ),
    )..files.add(http.MultipartFile.fromBytes('file', imageBytes,
        filename: 'image.jpg'));

    final response = await _httpClient.send(request);
    return http.Response.fromStream(response);
  }

  void _handleResponse(http.Response response, Uint8List originalImage) async {
    if (response.statusCode != 200)
      throw Exception('Failed to analyze image: ${response.statusCode}');

    final jsonResponse = json.decode(response.body);
    if (jsonResponse['error'] != null) throw Exception(jsonResponse['error']);

    final predictions = jsonResponse['predictions'] ?? [];

    // Draw analyzed image
    final image = await decodeImageFromList(originalImage);
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImage(image, Offset.zero, Paint());

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w900,
      backgroundColor: Colors.black,
    );

    for (int i = 0; i < predictions.length; i++) {
      final prediction = predictions[i];
      final color = _getColor(i);

      final symbol = prediction['class'];
      final confidence = prediction['confidence'] ?? 0.0;

      String message = fuzzyLogic(symbol, confidence);

      // Draw bounding box
      final rect = Rect.fromCenter(
        center: Offset(prediction['x'], prediction['y']),
        width: prediction['width'],
        height: prediction['height'],
      );

      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRect(rect, boxPaint);

      // Draw number
      final textSpan = TextSpan(
        text: '${i + 1}',
        style: textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          rect.left + 5,
          rect.top - textPainter.height - 5,
        ),
      );
    }

    final img =
        await pictureRecorder.endRecording().toImage(image.width, image.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      _predictions = predictions;
      _analyzedImageBytes = byteData!.buffer.asUint8List();
    });
  }

  Color _getColor(int index) {
    const colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple
    ];
    return colors[index % colors.length];
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(child: _buildSelectImageButton()),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildImageSection(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: _buildDetectionDetailsScrollable(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Center(child: _buildSelectImageButton()),
          const SizedBox(height: 20),
          _buildImageSection(),
          const SizedBox(height: 20),
          _buildDetectionDetails(),
        ],
      ),
    );
  }

  Widget _buildDetectionDetailsScrollable() {
    if (_predictions.isEmpty) return const SizedBox();

    return Card(
      elevation: 4,
      child: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _predictions.length,
          itemBuilder: (context, index) {
            final prediction = _predictions[index];
            final symbol = prediction['class'] ?? 'Unknown';
            final confidence = prediction['confidence'] ?? 0.0;
            final message = fuzzyLogic(symbol, confidence);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getColor(index),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                symbol,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                showPredictionDetails(context, message);
              },
            );
          },
        ),
      ),
    );
  }

  void showPredictionDetails(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prediction Details"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectImageButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : selectImage,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 10,
        shadowColor: Colors.deepOrangeAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.image, size: 24),
          SizedBox(width: 8),
          Text(
            'Select Image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing Image...'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_analyzedImageBytes != null)
          _buildImageCard('Analyzed Image', _analyzedImageBytes!),
      ],
    );
  }

  Widget _buildImageCard(String title, Uint8List bytes) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return FutureBuilder<double>(
                future: _getImageAspectRatio(bytes),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading image'));
                  } else {
                    return AspectRatio(
                      aspectRatio: snapshot.data ?? 1.0,
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.1,
                        maxScale: 4.0,
                        child: Image.memory(bytes, fit: BoxFit.contain),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<double> _getImageAspectRatio(Uint8List bytes) async {
    final completer = Completer<double>();
    ui.decodeImageFromList(bytes, (image) {
      completer.complete(image.width / image.height);
    });
    return completer.future;
  }

  Widget _buildDetectionDetails() {
    if (_predictions.isEmpty) return const SizedBox();

    return SizedBox(
      height: 200,
      child: Card(
        elevation: 4,
        child: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _predictions.length,
            itemBuilder: (context, index) {
              final prediction = _predictions[index];
              final symbol = prediction['class'] ?? 'Unknown';
              final confidence = prediction['confidence'] ?? 0.0;
              final message = fuzzyLogic(symbol, confidence);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColor(index),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  prediction['class'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Confidence: ${((prediction['confidence'] ?? 0) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  showPredictionDetails(context, message);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
