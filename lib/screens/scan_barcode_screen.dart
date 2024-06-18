import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:smart_medicine_dispecer_app/services/drug_service.dart';

class ScanBarcodeScreen extends StatefulWidget {
  @override
  _ScanBarcodeScreenState createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  String barcode = '';
  Map<String, dynamic>? drugInfo;

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcode = result.rawContent;
      });
      fetchDrugInfo();
    } catch (e) {
      setState(() {
        barcode = 'Failed to get the barcode.';
      });
    }
  }

  Future<void> fetchDrugInfo() async {
    if (barcode.isNotEmpty) {
      DrugService drugService = DrugService();
      Map<String, dynamic>? info = await drugService.fetchDrugInfo(barcode);
      setState(() {
        drugInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
        backgroundColor: Colors.teal[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: scanBarcode,
              child: Text('Scan Barcode'),
            ),
            SizedBox(height: 20),
            Text(
              barcode.isEmpty ? 'Scan a barcode to see drug information' : 'Barcode: $barcode',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            drugInfo != null
                ? Column(
              children: [
                Text('Drug Name: ${drugInfo!['product_name'] ?? 'N/A'}'),
                Text('Brand: ${drugInfo!['brands'] ?? 'N/A'}'),
                Text('Quantity: ${drugInfo!['quantity'] ?? 'N/A'}'),
                // Dodaj więcej pól, jeśli są dostępne
              ],
            )
                : Text('No drug information found.'),
          ],
        ),
      ),
    );
  }
}
