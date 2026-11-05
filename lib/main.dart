import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/chat/chat_list_page.dart';
import 'package:flutter_app/utils/device_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/pages/profile_page.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/utils/local_storage.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/home_product.dart';
import 'package:flutter_app/providers/chat_provider.dart';

void main() async {
  //đảm bảo giá trị của Flutter binding được khởi tạo trước khi chạy ứng dụng
  WidgetsFlutterBinding.ensureInitialized();

  final accessToken = await readData("ACCESS_TOKEN");

  final authProvider = AuthProvider();

  if (accessToken != null) {
    authProvider.setLogin(accessToken);
  }

  //chỉ hiển thị thông tin thiết bị khi ở chế độ debug
  if (kDebugMode) {
    try {
      final deviceInfo = await getDeviceInfo();
      debugPrint('[device-info] $deviceInfo');
    } catch (e) {
      debugPrint('[device-info] Error: $e');
    }
  }

  //dành cho khi sử dụng bloc
  // String? accessTokenBloc;
  // try {
  //   accessTokenBloc = await readData("ACCESS_TOKEN");
  // } catch (e) {
  //   accessTokenBloc = null;
  // }

  // final hasToken = accessTokenBloc != null;

  runApp(
    MultiProvider(
      providers: [
        //sử dụng lại instance của AuthProvider đã tạo ở trên
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ChatProvider(authProvider)),

        //vẫn khởi tạo như cũ
        // ChangeNotifierProvider(create: (context) => ProductProvider()),
        // ChangeNotifierProvider(create: (context) => OrderProvider()),
        // ChangeNotifierProvider(create: (context) => CartProvider()),
        // ChangeNotifierProvider(create: (context) => PaymentProvider()),
      ],
      child: const MyApp(),
    ),
  );

  //sử dụng khi dùng bloc
  // runApp(
  //   MultiBlocProvider(
  //     providers: [
  //       BlocProvider<AuthBloc>(create: (context) => AuthBloc(
  //         initialState: AuthState(
  //           isLogin: hasToken,
  //           accessToken: accessTokenBloc ?? "",
  //         )
  //       ),),
  //       // BlocProvider(create: (context) => ProductBloc()),
  //       // BlocProvider(create: (context) => OrderBloc()),
  //       // BlocProvider(create: (context) => CartBloc()),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
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
      ChatListPage(),
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
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(authProvider.isLogin ? Icons.person : Icons.login),
            label: authProvider.isLogin ? "Profile" : "Login",
          ),
        ],
      ),
    );

    //sử dụng blocbuilder để lấy trạng thái đăng nhập từ authbloc
    //tham số 1 của blocbuilder là context, tham số 2 là state
    //tự động rebuild khi trạng thái đăng nhập thay đổi
    // return BlocBuilder<AuthBloc, AuthState>(
    //   builder: (context, state) {
    //     final List<Widget> _pages = [
    //       HomePage(),
    //       HomeProductPage(),
    //       state.isLogin ? ProfilePage() : LoginPage(),
    //     ];

    //     return Scaffold(
    //       body: _pages[_selectedIndex],
    //       //dùng BottomNavigationBar để điều hướng giữa các trang
    //       bottomNavigationBar: BottomNavigationBar(
    //         type: BottomNavigationBarType.fixed,
    //         backgroundColor: Colors.deepOrange,
    //         selectedItemColor: Colors.yellow,
    //         unselectedItemColor: Colors.white,
    //         currentIndex: _selectedIndex,
    //         onTap: (index) => setState(() => _selectedIndex = index),
    //         items: [
    //           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    //           BottomNavigationBarItem(
    //             icon: Icon(Icons.shopping_cart),
    //             label: 'Home Product',
    //           ),
    //           BottomNavigationBarItem(
    //             icon: Icon(state.isLogin ? Icons.person : Icons.login),
    //             label: state.isLogin ? "Profile" : "Login",
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }
}
