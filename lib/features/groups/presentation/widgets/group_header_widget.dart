import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../groups/domain/entities/group.dart';

class GroupHeaderWidget extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onEditImage;
  final File? imageFile;
  final bool isLoadingImage;

  const GroupHeaderWidget({
    super.key,
    required this.group,
    required this.onEditImage,
    this.imageFile,
    this.isLoadingImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onEditImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: _buildImageContent(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (isLoadingImage) {
      return const Center(child: CircularProgressIndicator());
    }
    if (imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.cover);
    }
    if (group.coverImageUrl != null && group.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: group.coverImageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => const Icon(Icons.group, size: 50, color: Colors.blue),
      );
    }
    return const Icon(Icons.group, size: 50, color: Colors.blue);
  }
}