import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_service.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'calculator_screen.dart';
import 'theme_provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('com.yourpackage/battery');

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Tab Drawer Navigation',
          theme: themeProvider.themeData,
          home: MyHomePage(),
        );
      },
    );
  }

  Future<void> _startBatteryMonitoring() async {
    try {
      await platform.invokeMethod('startBatteryMonitoring');
    } on PlatformException catch (e) {
      print("Failed to start battery monitoring: '${e.message}'.");
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    MyApp()._startBatteryMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              connectivityService.connectionStatus == ConnectivityResult.none
                  ? Icons.signal_wifi_off
                  : Icons.signal_wifi_4_bar,
            ),
          ),
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Sign In'),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Sign Up'),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                _tabController.animateTo(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SignInScreen(),
          SignUpScreen(),
          CalculatorScreen(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: Icon(Icons.login), text: 'Sign In'),
          Tab(icon: Icon(Icons.app_registration), text: 'Sign Up'),
          Tab(icon: Icon(Icons.calculate), text: 'Calculator'),
        ],
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
      ),
    );
  }
}
