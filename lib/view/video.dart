import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:try_camera/controller/home_controller.dart';
import 'package:try_camera/controller/video_controller.dart';

class Video extends StatelessWidget {
  const Video({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController myController = Get.find<HomeController>();
    final VideoController video = Get.put(VideoController());
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -10,
              left: -5,
              right: -5,
              child: Container(
                height: 70,
                decoration: const BoxDecoration(color: Colors.black),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13.0.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => GestureDetector(
                          onTap: () {
                            myController.controlFlashlight();
                          },
                          child: Icon(
                            myController.isFlashOn.value
                                ? Icons.flash_off
                                : Icons.flash_on,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GetBuilder(
              init: HomeController(),
              builder: (controller) => Positioned.fill(
                top: 50,
                bottom: controller.isFrontCamera.value == false ? 0 : 150,
                child: AspectRatio(
                  aspectRatio: controller.controller?.value.aspectRatio ?? 1.0,
                  child: controller.controller?.value != null
                      ? CameraPreview(controller.controller as CameraController)
                      : const SizedBox(),
                ),
              ),
            ),
            Obx(
              () => Positioned(
                top: 50,
                right: 10,
                child: SfSlider.vertical(
                  min: 1.0,
                  max: 5.0,
                  activeColor: Colors.white,
                  value: myController.currentZoom.value,
                  onChanged: (value) {
                    myController.zoomCamera(value);
                  },
                ),
              ),
            ),
            GetBuilder<HomeController>(
              builder: (controller) {
                return GestureDetector(
                  onTapDown: (details) {
                    final Offset localPosition = details.localPosition;

                    // Calculate relative position
                    final Offset relativePosition = Offset(
                      localPosition.dx / MediaQuery.of(context).size.width,
                      localPosition.dy / MediaQuery.of(context).size.height,
                    );

                    controller.setFocusPoint(relativePosition);
                  },
                );
              },
            ),
            Obx(
              () {
                final focusPoint = myController.focusPoint.value;
                return Positioned.fill(
                  child: Align(
                    alignment:
                        Alignment(focusPoint.dx * 2 - 1, focusPoint.dy * 2 - 1),
                    child: Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(
                () => Container(
                  height: 150,
                  color: myController.isFrontCamera.value
                      ? Colors.black45
                      : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(const Video()),
                            child: const Text(
                              "Video",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Text(
                            "Photo",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => myController.savedImagePath.isNotEmpty
                                ? Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 2,
                                        color: Colors.white,
                                      ),
                                      image: DecorationImage(
                                        image: FileImage(
                                          File(myController
                                              .savedImagePath.value),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await video.toggleRecording();
                            },
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 4,
                                  color: Colors.white,
                                ),
                              ),
                              child: Center(
                                child: Obx(
                                  () => video.isRecording.value
                                      ? const Icon(
                                          Icons.stop,
                                          color: Colors.white,
                                          size: 32,
                                        )
                                      : const Icon(
                                          Icons.play_arrow,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => myController.switchCamera(),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 2,
                                  color: Colors.white,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.cameraswitch,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
