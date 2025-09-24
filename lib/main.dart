import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/app_main_screen.dart';
import 'package:provider/provider.dart';
import 'package:yummygo/provider/favorite_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FavoriteProvider())],
      child: MaterialApp(title: 'YummyGo', home: AppMainScreen()),
    );
  }
}
