import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:try_camera/controller/home_controller.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class VideoController extends GetxController {
  RxBool isRecording = false.obs;
  final HomeController homeController = Get.find<HomeController>();
  String? videoPath;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> toggleRecording() async {
    if (homeController.controller == null ||
        !homeController.controller!.value.isInitialized) {
      print('CameraController is not initialized.');
      return;
    }

    if (isRecording.value) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (homeController.controller != null &&
        homeController.controller!.value.isInitialized &&
        !homeController.controller!.value.isRecordingVideo) {
      try {
        final directory = await getApplicationSupportDirectory();
        videoPath = path.join(
            directory.path, '${DateTime.now().toIso8601String()}.mp4');

        await homeController.controller!.startVideoRecording();
        isRecording.value = true;
      } catch (e) {
        print('Error starting video recording: $e');
      }
    }
  }

  Future<void> stopRecording() async {
    if (homeController.controller != null &&
        homeController.controller!.value.isInitialized &&
        homeController.controller!.value.isRecordingVideo) {
      try {
        final XFile videoFile =
            await homeController.controller!.stopVideoRecording();
        isRecording.value = false;
        if (videoPath != null) {
          final File file = File(videoFile.path);
          await file.rename(videoPath!);
          await GallerySaver.saveVideo(videoPath ?? "");
          print('Video saved to $videoPath');
        }
      } catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }
}
