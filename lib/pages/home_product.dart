import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/services/product_services.dart';

class HomeProductPage extends StatefulWidget {
  const HomeProductPage({super.key});

  @override
  State<HomeProductPage> createState() => _HomeProductPageState();
}

class _HomeProductPageState extends State<HomeProductPage> {
  var listProduct = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ProductServices.getProducts()
        //thành công sẽ nhận được giá trị trả về từ getProducts()
        .then((value) {
          setState(() {
            listProduct = value;
          });
        })
        //nếu có lỗi sẽ được catchError bắt và xử lý
        .catchError((err) {
          print("Error loading products: $err");
        });
  }

  @override
  Widget build(BuildContext context) {
    // return const Scaffold();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Product'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: listProduct.length,
        itemBuilder: (context, index) {
          final product = listProduct[index];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh sản phẩm
                  Expanded(
                    child: Image.network(
                      product["image"] ?? "",
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tên sản phẩm
                  Text(
                    product["name"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Mô tả sản phẩm
                  Text(
                    product["shortDescription"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 8),

                  // Giá sản phẩm
                  Text(
                    "\$${product["price"]}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Nút xem chi tiết
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print(product["id"]);
                      },
                      child: const Text("Xem chi tiết"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
