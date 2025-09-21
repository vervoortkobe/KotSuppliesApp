import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File?) onImagePicked;

  const ProfileImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImagePicked,
  });

  @override
  ProfileImagePickerState createState() => ProfileImagePickerState();
}

class ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
      widget.onImagePicked(_pickedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : (widget.initialImageUrl != null &&
                        widget.initialImageUrl!.isNotEmpty
                    ? NetworkImage(widget.initialImageUrl!) as ImageProvider
                    : null),
          child:
              _pickedImage == null &&
                  (widget.initialImageUrl == null ||
                      widget.initialImageUrl!.isEmpty)
              ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
              : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.camera_alt),
          label: Text('Pick Image'),
        ),
      ],
    );
  }
}
