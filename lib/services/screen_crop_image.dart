import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';
import '../widgets/widgets_units/widget_button.dart';
import '../../l10n/app_localizations.dart';

/// 圖片裁切畫面
/// 提供使用者裁切所選圖片的功能界面
/// 圖片裁切畫面Widget
/// 允許使用者以互動方式裁切選定的圖片
class ScreenCropImage extends StatefulWidget {
  /// 要裁切的圖片二進制數據
  final Uint8List imageBytes;

  const ScreenCropImage({super.key, required this.imageBytes});

  @override
  State<ScreenCropImage> createState() => _ScreenCropImageState();
}

class _ScreenCropImageState extends State<ScreenCropImage> {
  /// 裁切控制器
  final _cropController = CropController();

  /// 裁切處理中狀態標記
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.cropImage ?? 'Crop Image'),
      ),
      body: Stack(
        children: [
          Crop(
            controller: _cropController,
            image: widget.imageBytes,
            onCropped: (result) {
              switch (result) {
                case CropSuccess(:final croppedImage):
                  Navigator.pop(context, croppedImage);
                case CropFailure(:final cause):
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to crop: $cause')),
                  );
              }
            },
            withCircleUi: false,
            maskColor: Colors.black.withAlpha(153),
            baseColor: Colors.black,
          ),
          if (_isCropping)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widgetButton(
          l10n?.saveImage ?? 'Save Image',
          Icons.check,
          () {
            setState(() => _isCropping = true);
            _cropController.crop();
          },
          context: context,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
