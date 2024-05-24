import 'package:pragma_todo/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adapters/todo_adapter.dart';
import 'models/todo.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    await Hive.openBox<Todo>('todos');
    await initNotifications();
    runApp(const MyApp());
}

Future<void> initNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    const InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    ThemeMode themeMode = ThemeMode.system;

    @override
    void initState() {
        super.initState();
        _loadThemeMode();
    }

    void _loadThemeMode() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
            themeMode = prefs.getBool('isDarkMode') ?? false ? ThemeMode.dark : ThemeMode.light;
        });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'ToDo App',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
        );
    }
}
