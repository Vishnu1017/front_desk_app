import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart'; // Add this import
import 'homepage.dart';
import 'visitor_manager.dart';
import 'visitor.dart'; // Ensure Visitor class is defined

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the path to the Documents directory for internal storage
  final appDocumentDir = await getApplicationDocumentsDirectory();
  print(
      'Hive data will be stored at: ${appDocumentDir.path}'); // Log the path for debugging

  // Initialize Hive with the Documents directory path
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(VisitorAdapter()); // Register the Visitor adapter
  await Hive.openBox<Visitor>(
      'visitorBox'); // Open the box for storing Visitor data

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => VisitorManager(Hive.box<Visitor>('visitorBox')),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Front Desk App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(),
    );
  }
}
