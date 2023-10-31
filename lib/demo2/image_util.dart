import 'dart:io';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_editor/image_editor.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtil {

  /***
   *
   */
  Future<List<File>> cropAndSaveImage2(File file, List<Face> faces) async {
    final Uint8List bytes = await file.readAsBytes();

    List<Rect> cropRectangles = faces.map((e) => e.boundingBox).toList();

    List<File> crpImages = [];
    for (int i = 0; i < cropRectangles.length; i++) {
      Uint8List? croppedBytes = await cropImage(bytes, cropRectangles[i]);
      if (croppedBytes != null) {
        crpImages.add(await saveCroppedImage(croppedBytes, i));
      }
    }
    return crpImages;
  }

  Rect checkRect(ui.Image image, Rect oldRect) {
    Rect rect = Rect.zero;
    var left = oldRect.left < 0 ? 0.0 : oldRect.left;
    var top = oldRect.top < 0 ? 0.0 : oldRect.top;

    var right =
        oldRect.right > image.width ? image.width.toDouble() : oldRect.right;
    var bottom = oldRect.bottom > image.height
        ? image.height.toDouble()
        : oldRect.height;

    rect = Rect.fromLTRB(left, top, right, bottom);

    return rect;
  }


  Future<Uint8List?> convertImageToBytes(ui.Image image) async {
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    print('byteData =====${byteData?.lengthInBytes}');
    return byteData?.buffer.asUint8List();
  }

  Future<File> saveCroppedImage(Uint8List bytes, int index) async {
    final String savePath =
        await getTemporaryImagePath(index); // Get a temporary file path
    final File saveFile = File(savePath);
    await saveFile.writeAsBytes(bytes);
    return saveFile;
  }

  Future<String> getTemporaryImagePath(int index) async {
    final directory = await getExternalStorageDirectory();
    final tempImagePath =
        '${directory?.path}/face_${DateTime.now().microsecondsSinceEpoch}.png';
    return tempImagePath;
  }

  Future<Uint8List?> cropImage(Uint8List imageData, Rect cropRect) async {
    try {
      final editor = ImageEditorOption();
      editor.addOption(ClipOption.fromRect(cropRect));

      final result = await ImageEditor.editImage(
        image: imageData,
        imageEditorOption: editor,
      );

      if (result != null && result.isNotEmpty) {
        return Uint8List.fromList(result);
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  Future<ui.Image> changeToImage(String assetImage) async {
    final ByteData data = await rootBundle.load(assetImage);
    final List<int> bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes as Uint8List);
    return  (await codec.getNextFrame()).image;
  }
}
