import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/group.dart';

class GroupHeaderWidget extends StatelessWidget {
  final GroupEntity group;
  final VoidCallback onEditImage;
  final File? imageFile;
  final bool isLoadingImage;
  static const String _defaultImageUrl = 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400';

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
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              image: DecorationImage(
                image: imageFile != null
                    ? FileImage(imageFile!)
                    : (group.coverImageUrl?.isNotEmpty ?? false)
                    ? NetworkImage(group.coverImageUrl!)
                    : const NetworkImage(_defaultImageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: isLoadingImage ?
            const Center(child: CircularProgressIndicator()) : null,
          ),
          GestureDetector(
            onTap: onEditImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}