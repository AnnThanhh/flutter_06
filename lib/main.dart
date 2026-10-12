import 'package:flutter/material.dart';

import 'pages/danh_ba.dart';
import 'pages/home_page.dart';
import 'pages/page_a.dart';
import 'pages/page_b.dart';
import 'pages/page_c.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Routing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
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

  static const List<Widget> _pages = [
    HomePage(),
    PageA(),
    PageB(),
    PageC(),
    BaiTapDanhBa(),
  ];

  @override
  Widget build(BuildContext context) {
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Page A'),
          BottomNavigationBarItem(icon: Icon(Icons.details), label: 'Page B'),
          BottomNavigationBarItem(icon: Icon(Icons.cabin), label: 'Page C'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Danh bạ'),
        ],
      ),
    );
  }
}
