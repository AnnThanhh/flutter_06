import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<dynamic> getProducts() async {
  //xử lý url backend
  final url = Uri.parse("https://apistore.cybersoft.edu.vn/api/product");

  final response = await http.get(url);

  print(response.body);
}

class HomeProductPage extends StatefulWidget {
  const HomeProductPage({super.key});

  @override
  State<HomeProductPage> createState() => _HomeProductPageState();
}

class _HomeProductPageState extends State<HomeProductPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
