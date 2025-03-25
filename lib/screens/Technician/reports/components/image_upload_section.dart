import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as web;
import 'package:image/image.dart' as img;

class ImageUploadSection extends StatelessWidget {
  final List<XFile> images;
  final Future<void> Function() onUpload;
  final Function(int) onDelete;
  final String title;

  const ImageUploadSection({
    super.key,
    required this.images,
    required this.onUpload,
    required this.onDelete,
    required this.title,
  });

  Future<Uint8List> _resizeImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image');

    const targetSize = 500;
    final resizedImage = img.copyResize(
      image,
      width: image.width > image.height ? targetSize : null,
      height: image.width > image.height ? null : targetSize,
      maintainAspect: true,
    );

    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: onUpload,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload, size: 40, color: Colors.orange),
                const SizedBox(height: 8),
                const Text('اضغط لرفع الصور',
                    style: TextStyle(color: Colors.orange)),
                const SizedBox(height: 10),
                if (images.isNotEmpty)
                  SizedBox(
                    height: 130,
                    child: FutureBuilder<List<Uint8List>>(
                      future: Future.wait(images.map(_resizeImage)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        final imagesBytes = snapshot.data ?? [];
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imagesBytes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) => ImageItem(
                            imageBytes: imagesBytes[index],
                            onDelete: () => onDelete(index),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ImageItem extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onDelete;

  const ImageItem({
    super.key,
    required this.imageBytes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            ),
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                  )
                ],
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}
