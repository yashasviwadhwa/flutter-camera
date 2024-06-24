import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:try_camera/controller/qr_code_controller.dart';

class QrCodeScanner extends StatelessWidget {
  const QrCodeScanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    double scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return Scaffold(
      body: SafeArea(
        child: GetBuilder<QrCodeController>(
          init: QrCodeController(),
          builder: (qrController) {
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: (controller) {
                      qrController.initQRCodeScanner(controller);
                    },
                    overlay: QrScannerOverlayShape(
                      borderColor: Colors.red,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: scanArea,
                    ),
                    onPermissionSet: (ctrl, p) {
                      qrController.onPermissionSet(ctrl, p);
                    },
                  ),
                ),
                // Display scanned QR code
                Obx(() => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Scanned QR Code: ${qrController.qrCodeResult.value}',
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}
