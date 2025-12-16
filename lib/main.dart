import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'nav.dart';

/// Main entry point for the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://iytpyokmahkumobgagtg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5dHB5b2ttYWhrdW1vYmdhZ3RnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU4Mzk2NDMsImV4cCI6MjA4MTQxNTY0M30.TULOoEmUrJxuLP58K9_UaSp7EYpEmdsp_tFvjNCWYCw',
  );

  // Initialize the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Difereti App',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,

      // Use context.go() or context.push() to navigate to the routes.
      routerConfig: AppRouter.router,
    );
  }
}
