import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const StorynApp());
}

class StorynApp extends StatelessWidget {
  const StorynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Storyn',
      routerConfig: appRouter,
    );
  }
}