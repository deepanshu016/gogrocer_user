import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/models/businessLayer/global.dart' as global;

class ProfilePicture extends StatefulWidget {
  @required
  final String? profilePictureUrl;
  final Function? onPressed;
  final File? tImage;
  @required
  final bool? isShow;

  const ProfilePicture({super.key, this.profilePictureUrl, this.onPressed, this.tImage, this.isShow});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {

  _ProfilePictureState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.tImage != null
            ? CircleAvatar(
                backgroundColor: Colors.white,
                radius: 60,
                backgroundImage: FileImage(File(widget.tImage!.path)),
              )
            : global.currentUser!.userImage != null
                ? CachedNetworkImage(
                    imageUrl: global.appInfo!.imageUrl! + global.currentUser!.userImage!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 60,
                      backgroundImage: imageProvider,
                      backgroundColor: Colors.white,
                    ),
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 60,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        )),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 60,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
        widget.isShow!
            ? Positioned(
                bottom: 0,
                right: -4,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      _showCupertinoModalSheet();
                      setState(() {});
                    },
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Future<File?> openCamera() async {
    try {
      PermissionStatus permissionStatus = await Permission.camera.status;
      if (permissionStatus.isLimited || permissionStatus.isDenied) {
        permissionStatus = await Permission.camera.request();
      }
      XFile? selectedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (selectedImage != null) {
        File imageFile = File(selectedImage.path);
        File? finalImage = await _cropImage(imageFile.path);
        if (finalImage != null) {
          final compressedImage = await _imageCompress(finalImage, imageFile.path);
          if (compressedImage != null) {
            finalImage = File(compressedImage.path);

            return finalImage;
          }
        }
      }
    } catch (e) {
      debugPrint("Exception - profile_picture.dart - openCamera():$e");
    }
    return null;
  }

  Future<File?> selectImageFromGallery() async {
    try {
      PermissionStatus permissionStatus = await Permission.photos.status;
      if (permissionStatus.isLimited || permissionStatus.isDenied) {
        permissionStatus = await Permission.photos.request();
      }
      File imageFile;
      XFile? selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(selectedImage != null) {
        imageFile = File(selectedImage.path);
        File? byteData = await _cropImage(imageFile.path);
        if(byteData != null) {
          final compressedImage = await _imageCompress(byteData, imageFile.path);
          if(compressedImage != null) {
            byteData = File(compressedImage.path);
            return byteData;
          }
        }
      }
    } catch (e) {
      debugPrint("Exception - profile_picture.dart - selectImageFromGallery()$e");
    }
    return null;
  }

  Future<File?> _cropImage(String sourcePath) async {
    try {
      File? croppedFile = (await ImageCropper().cropImage(
        sourcePath: sourcePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            initAspectRatio: CropAspectRatioPreset.original,
            backgroundColor: Colors.white,
            toolbarColor: Colors.black,
            dimmedLayerColor: Colors.white,
            toolbarWidgetColor: Colors.white,
            cropGridColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF46A9FC),
            cropFrameColor: const Color(0xFF46A9FC),
            lockAspectRatio: true,
          ),
        ],
      )) as File?;
      if (croppedFile != null) {
        return croppedFile;
      }
    } catch (e) {
      debugPrint("Exception - profile_picture.dart - _cropImage():$e");
    }
    return null;
  }

  Future<XFile?> _imageCompress(File file, String targetPath) async {
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minHeight: 500,
        minWidth: 500,
        quality: 60,
      );

      return result;
    } catch (e) {
      debugPrint("Exception - profile_picture.dart - _cropImage():$e");
      return null;
    }
  }

  _showCupertinoModalSheet() {
    try {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(AppLocalizations.of(context)!.lbl_actions),
          actions: [
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context)!.lbl_take_picture,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);

                final tImage = await openCamera();
                global.selectedImage = tImage!.path;

                setState(() {});
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context)!.txt_upload_image_desc,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () async {
                Navigator.pop(context);

                final tImage = await selectImageFromGallery();
                global.selectedImage = tImage!.path;

                setState(() {});
              },
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(AppLocalizations.of(context)!.lbl_cancel, style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint("Exception - profile_picture.dart - _showCupertinoModalSheet():$e");
    }
  }
}
