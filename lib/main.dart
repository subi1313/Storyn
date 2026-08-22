// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'features/books/presentation/providers/books_provider.dart';
import 'features/library/presentation/providers/library_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const StorynApp());
}

class StorynApp extends StatelessWidget {
  const StorynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<BooksProvider>()..loadHomeSections()),
        ChangeNotifierProvider(create: (_) => sl<LibraryProvider>()..loadLibrary()),
        ChangeNotifierProvider(create: (_) => sl<SettingsProvider>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Storyn',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Inter',
        ),
        routerConfig: appRouter,
      ),
    );
  }
}