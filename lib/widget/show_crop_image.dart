import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yakgin/state/show_image.dart';
import 'package:yakgin/widget/show_icon_button.dart';

class ShowCropImage extends StatefulWidget {
  const ShowCropImage({
    Key key,
  }) : super(key: key);

  @override
  State<ShowCropImage> createState() => _ShowCropImageState();
}

class _ShowCropImageState extends State<ShowCropImage> {
  File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            file == null ? const ShowImage() : Image.file(file),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ShowIconButton(
                  iconData: Icons.add_a_photo,
                  pressFunc: () {
                    procressTakePhotoandCrop(
                      ImageSource.camera,
                    );
                  },
                ),
                ShowIconButton(
                  iconData: Icons.add_photo_alternate,
                  pressFunc: () {
                    procressTakePhotoandCrop(
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> procressTakePhotoandCrop(ImageSource source) async {
    var result = await ImagePicker().getImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    file = File(result.path);
    var resultCrop = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
        
    file = File(resultCrop.path);

    setState(() {});
  }
}
