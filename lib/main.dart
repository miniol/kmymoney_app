import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database_initializer.dart';
import 'presentation/screens/account_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseInitializer.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AccountListScreen(),
    );
  }
}
