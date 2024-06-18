import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import 'medication_list_screen.dart';
import 'medication_add_screen.dart';
import 'schedule_list_screen.dart';
import 'schedule_add_screen.dart';
import 'info_screen.dart';
import 'notifications_screen.dart';
import 'scan_barcode_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    _notificationService.subscribeToTopic('all');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message.notification!.title!),
            content: Text(message.notification!.body!),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
    _notificationService.initializeDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Medicine Dispenser'),
        centerTitle: true,
        backgroundColor: Colors.teal[400],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: <Widget>[
          _buildTile(
            context,
            title: 'Lista Leków',
            icon: Icons.medical_services,
            colors: [Colors.teal[200]!, Colors.teal[300]!],
            onTap: () => _navigateTo(context, MedicationListScreen()),
          ),
          _buildTile(
            context,
            title: 'Dodaj Lek',
            icon: Icons.add_circle_outline,
            colors: [Colors.cyan[200]!, Colors.cyan[300]!],
            onTap: () => _navigateTo(context, MedicationAddScreen()),
          ),
          _buildTile(
            context,
            title: 'Harmonogram Leków',
            icon: Icons.schedule,
            colors: [Colors.purple[200]!, Colors.purple[300]!],
            onTap: () => _navigateTo(context, ScheduleScreen()),
          ),
          _buildTile(
            context,
            title: 'Dodaj Harmonogram',
            icon: Icons.add_alarm,
            colors: [Colors.blue[200]!, Colors.blue[300]!],
            onTap: () => _navigateTo(context, ScheduleAddScreen()),
          ),
          _buildTile(
            context,
            title: 'Ustawienia',
            icon: Icons.settings,
            colors: [Colors.grey[300]!, Colors.grey[400]!],
            onTap: () => _navigateTo(context, NotificationHistoryScreen()),
          ),
          _buildTile(
            context,
            title: 'Informacje',
            icon: Icons.info_outline,
            colors: [Colors.indigo[200]!, Colors.indigo[300]!],
            onTap: () => _navigateTo(context, InfoScreen()),
          ),
          _buildTile(
            context,
            title: 'Scan Barcode',
            icon: Icons.qr_code_scanner,
            colors: [Colors.orange[200]!, Colors.orange[300]!],
            onTap: () => _navigateTo(context, ScanBarcodeScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required String title, required IconData icon, required List<Color> colors, required VoidCallback onTap}) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Futura',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
