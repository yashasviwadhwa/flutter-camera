import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:try_camera/controller/home_controller.dart';
import 'package:try_camera/view/qr_code_scannner.dart';
import 'package:try_camera/view/video.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SafeArea(
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
                              controller.controlFlashlight();
                            },
                            child: Icon(
                              controller.isFlashOn.value
                                  ? Icons.flash_off
                                  : Icons.flash_on,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.to(QrCodeScanner());
                          },
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                          ),
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
                    aspectRatio:
                        controller.controller?.value.aspectRatio ?? 1.0,
                    child: controller.controller?.value != null
                        ? CameraPreview(
                            controller.controller as CameraController)
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
                    value: controller.currentZoom.value,
                    onChanged: (value) {
                      controller.zoomCamera(value);
                    },
                  ),
                ),
              ),
              // GetBuilder<HomeController>(
              //   builder: (controller) {
              //     return GestureDetector(
              //       onTapDown: (details) {
              //         final RenderBox box =
              //             context.findRenderObject() as RenderBox;
              //         final Offset localPosition =
              //             box.globalToLocal(details.globalPosition);
              //         final double x = localPosition.dx / box.size.width;
              //         final double y = localPosition.dy / box.size.height;
              //         controller.setFocusPoint(Offset(x, y));
              //       },
              //     );
              //   },
              // ),
              Obx(
                () {
                  final focusPoint = controller.focusPoint.value;
                  return Positioned.fill(
                    child: Align(
                      alignment: Alignment(
                          focusPoint.dx * 2 - 1, focusPoint.dy * 2 - 1),
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
                    color: controller.isFrontCamera.value
                        ? Colors.black45
                        : Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Get.to(const Video()),
                              child: Text(
                                "Video",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(),
                            Text(
                              "Photo",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(
                              () => controller.savedImagePath.isNotEmpty
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
                                            File(controller
                                                .savedImagePath.value),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            GestureDetector(
                              onTap: () => controller.takePicture(),
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
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.switchCamera(),
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
      ),
    );
  }
}
