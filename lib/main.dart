import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('ERROR: ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'THIX ID',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('THIX ID'),
        ),
        body: const Center(
          child: Text(
            'Application démarrée avec succès',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
