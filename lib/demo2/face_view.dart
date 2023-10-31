import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'face_rectangle_painter.dart';
import 'image_util.dart';

class FaceShowView extends StatefulWidget {
  const FaceShowView({Key? key}) : super(key: key);

  @override
  State<FaceShowView> createState() => _FaceShowViewState();
}

class _FaceShowViewState extends State<FaceShowView> {

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  CustomPainter? painter;
  Image? _image;
  List<Face>? faces;
  List<File> clipFiles = [];
  List<ui.Image> uiImage = [];

  String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人脸检测'),
      ),
      body: Center(
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: CustomPaint(
                painter: painter,
          foregroundPainter : painter,
                child: _image,
              ),
            ),

            TextButton(onPressed: (){
              onClickUpload();
            }, child: const Text('选择图片')),

            TextButton(onPressed: () async{
              if(faces == null) {
                return;
              }
              clipFiles.clear();
              uiImage.clear();
              clipFiles =await ImageUtil().cropAndSaveImage2(File(imagePath??""),faces!);
              setState(() {

              });

            }, child: const Text('保存')),

            Container(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection:  Axis.horizontal,
                  itemCount: clipFiles.length,
                  itemBuilder: (context,index) {
                return Image.file(clipFiles[index],width: 100,height: 100,);
              }),
            ),


            Text(_text??'')
          ],
        ),
      ),
    );
  }

  ///选择照片
  void onClickUpload() async {
    var status = await Permission.storage.request();
    // var status2 = await Permission.mediaLibrary.request();

    if(status.isGranted){
      final picker = ImagePicker();
      var pic = await picker.pickImage(source: ImageSource.gallery);
      if (pic != null) {
        // _uploadImg(pics!)
        await _cropImage(pic.path);
      }
    } else {
      // showToast("权限拒绝");
    }

  }

  Future<void> _cropImage(String filePath) async {
    var croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
        ]
            : [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: '图片裁剪',

              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: '图片裁剪',
          )
        ]);
    if (croppedFile != null) {
      // _uploadImg(croppedFile.path, filePath);

      setState(() {
        imagePath = croppedFile.path;
        getImageSizeSync(imagePath!);
      });
    }
  }

  Future<void> _processImage(InputImage inputImage, Size imageSize) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
     faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      // final painter = FaceDetectorPainter(
      //   faces,
      //   inputImage.metadata!.size,
      //   inputImage.metadata!.rotation,
      //   _cameraLensDirection,
      // );
      // _customPaint = CustomPaint(painter: painter);
    } else {
      final bgImages = await ImageUtil().changeToImage('asset/bg.png');
      painter = FaceRectanglePainter(faces!,imageSize, bgImages);
      String text = 'Faces found: ${faces!.length}\n\n';
      for (final face in faces!) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      // _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void getImageSizeSync(String path) async {



    _image = Image.file(File(path),);
    _image!.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
      int width = info.image.width;
      int height = info.image.height;

      print('Image Width: $width, Height: $height');
      _processImage(InputImage.fromFilePath(path),Size(width.toDouble(), height.toDouble()));
    }));
  }


}





