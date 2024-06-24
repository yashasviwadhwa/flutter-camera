
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeController extends GetxController {
  final RxString qrCodeResult = ''.obs;
  QRViewController? controller;
  Rx<Barcode?> result = Rx<Barcode?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    controller?.dispose();
    super.onClose();
  }

  void initQRCodeScanner(QRViewController qrViewController) async {
    try {
      controller = qrViewController;
      controller?.scannedDataStream.listen((scanData) {
        result.value = scanData;
        qrCodeResult.value = scanData.code?.toString() ?? 'No QR code detected';
      });
    } catch (e) {
      // Handle errors during initialization (e.g., camera access)
      print('Error initializing QR code scanner: $e');
    }
  }

  void onPermissionSet(QRViewController ctrl, bool p) {
    if (!p) {
      Get.snackbar('Permission Denied',
          'You need to grant camera permission to use the QR scanner.');
    }
  }

  void resumeScanning() {
    controller?.resumeCamera();
  }

  void pauseScanning() {
    controller?.pauseCamera();
  }
}
