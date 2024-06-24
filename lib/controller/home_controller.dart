import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomeController extends GetxController {
  List<CameraDescription> _cameras = [];
  CameraController? controller;
  RxInt selectedCameraIndex = 0.obs;
  RxBool isFrontCamera = false.obs;
  RxBool isFlashOn = false.obs;
  RxBool isCapturing = false.obs;
  RxDouble currentZoom = 1.0.obs;
  RxString savedImagePath = ''.obs;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Rx<Offset> focusPoint = const Offset(0.5, 0.5).obs;
  @override
  void onInit() {
    super.onInit();
    initializeCameras();
  }

  void initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        initializeCamera(_cameras.first);
      }
    } catch (e) {
      print("Error initializing cameras: ${e.toString()}");
    }
  }

  void initializeCamera(CameraDescription cameraDescription) async {
    try {
      if (controller != null) {
        await controller?.dispose();
      }

      if (!isClosed) {
        controller = CameraController(cameraDescription, ResolutionPreset.max);
        await controller?.initialize();
      }
      if (isClosed) {
        return;
      }
      update();
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("Camera access denied");
            break;
          default:
            print("Unknown camera error: ${e.description}");
            break;
        }
      }
    }
  }

  void controlFlashlight() {
    if (isFlashOn.value == true) {
      controller?.setFlashMode(FlashMode.off);
    } else {
      controller?.setFlashMode(FlashMode.torch);
    }
    isFlashOn.value = !isFlashOn.value;
  }

  void switchCamera() async {
    selectedCameraIndex.value =
        (selectedCameraIndex.value + 1) % _cameras.length;
    CameraDescription selectedCamera = _cameras[selectedCameraIndex.value];
    initializeCamera(selectedCamera);
  }

  Future<void> takePicture() async {
    if (!controller!.value.isInitialized || controller!.value.isTakingPicture) {
      return;
    }

    isCapturing.value = true;

    try {
      final Directory appDir = await getApplicationSupportDirectory();
      final String capturePath =
          path.join(appDir.path, '${DateTime.now()}.jpg');
      final XFile capturedImage = await controller!.takePicture();
      final String imagePath = capturedImage.path;
      print("Image saved at: $imagePath");
      await GallerySaver.saveImage(imagePath);
      await _audioPlayer.play(
        AssetSource("music/camera2.mp3"),
      );
      savedImagePath.value = imagePath;
      print("Image saved to gallery");
    } catch (e) {
      print("Error capturing photo: ${e.toString()}");
      Get.snackbar("Error", "Error capturing image: ${e.toString()}");
    } finally {
      isCapturing.value = false;
    }
  }

  void zoomCamera(double value) {
    currentZoom.value = value;
    controller?.setZoomLevel(value);
  }

  Future<void> setFocusPoint(Offset point) async {
    final double x = point.dx.clamp(0.3, 1.0);
    final double y = point.dy.clamp(0.3, 1.0);

    await controller?.setFocusPoint(Offset(x, y));
    await controller?.setFocusMode(FocusMode.auto);
    focusPoint.value = Offset(x, y);

    await Future.delayed(const Duration(seconds: 2));
    focusPoint.value = const Offset(0.5, 0.5);

    await Future.delayed(const Duration(seconds: 2));
    focusPoint.value = const Offset(0.5, 0.5);
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }
}
