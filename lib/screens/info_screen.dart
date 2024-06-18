import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informacje'),
        centerTitle: true,
        backgroundColor: Colors.teal[400],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 100,
                    color: Colors.teal[300], // Matching the color scheme
                  ),
                  SizedBox(width: 20),
                  Image.asset(
                    'assets/icon/info_logo.png', // Path to your bottle icon image
                    width: 150,
                    height: 150,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Smart Medicine Dispenser',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[400], // Matching the color scheme
                  fontFamily: 'Futura',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            buildSectionTitle('Cel aplikacji'),
            buildSectionContent(
              'Aplikacja Smart Medicine Dispenser pomaga w zarządzaniu lekami. '
                  'Umożliwia dodawanie leków, tworzenie harmonogramów ich przyjmowania '
                  'oraz monitorowanie ilości leków w urządzeniu.',
            ),
            buildSectionTitle('Instrukcje użytkowania'),
            buildSectionContent(
              '1. Dodaj lek: Przejdź do sekcji "Dodaj Lek" i wprowadź szczegóły dotyczące leku.\n'
                  '2. Tworzenie harmonogramu: Po dodaniu leku, przejdź do sekcji "Dodaj Harmonogram" i utwórz harmonogram przyjmowania leku.\n'
                  '3. Monitorowanie leków: Przejdź do sekcji "Lista Leków" aby zobaczyć wszystkie dodane leki i ich ilości w urządzeniu.\n'
                  '4. Harmonogramy: Przejdź do sekcji "Harmonogram Leków" aby zobaczyć harmonogramy przyjmowania leków.',
            ),
            buildSectionTitle('Kontakt i wsparcie'),
            buildSectionContent(
              'Jeśli masz pytania lub potrzebujesz wsparcia, skontaktuj się z nami pod adresem email: support@medicinedispenser.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal[400], // Matching the color scheme
          fontFamily: 'Futura',
        ),
      ),
    );
  }

  Widget buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16, height: 1.5, fontFamily: 'Futura'),
      ),
    );
  }
}
