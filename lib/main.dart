import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/pages/profile_page.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/utils/local_storage.dart';
import 'package:provider/provider.dart';

import 'pages/danh_ba.dart';
import 'database/ui.dart';
import 'pages/home_page.dart';
import 'pages/home_product.dart';

void main() async {
  //đảm bảo giá trị của Flutter binding được khởi tạo trước khi chạy ứng dụng
  WidgetsFlutterBinding.ensureInitialized();

  final accessToken = await readData("ACCESS_TOKEN");

  final authProvider = AuthProvider();

  if (accessToken != null) {
    authProvider.setLogin(accessToken);
  }

  runApp(
    MultiProvider(
      providers: [
        //sử dụng lại instance của AuthProvider đã tạo ở trên
        ChangeNotifierProvider.value(value: authProvider),

        //vẫn khởi tạo như cũ
        // ChangeNotifierProvider(create: (context) => ProductProvider()),
        // ChangeNotifierProvider(create: (context) => OrderProvider()),
        // ChangeNotifierProvider(create: (context) => CartProvider()),
        // ChangeNotifierProvider(create: (context) => PaymentProvider()),
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
      title: 'Flutter Routing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          // Android: màu + icon của statusbar; iOS: statusBarBrightness.dark = icon sáng
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.deepOrange,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final List<Widget> _pages = [
      HomePage(),
      HomeProductPage(),
      authProvider.isLogin ? ProfilePage() : LoginPage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      //dùng BottomNavigationBar để điều hướng giữa các trang
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.deepOrange,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          // BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Page A'),
          // BottomNavigationBarItem(icon: Icon(Icons.details), label: 'Page B'),
          // BottomNavigationBarItem(icon: Icon(Icons.cabin), label: 'Page C'),
          // BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh bạ'),
          // BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Database'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Home Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(authProvider.isLogin ? Icons.person : Icons.login),
            label: authProvider.isLogin ? "Profile" : "Login",
          ),
        ],
      ),
    );
  }
}
