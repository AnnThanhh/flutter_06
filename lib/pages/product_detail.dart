import 'package:flutter/material.dart';
import 'package:flutter_app/services/product_services.dart';

class ProductDetails extends StatefulWidget {
  final int id;

  const ProductDetails({super.key, required this.id});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  dynamic product;

  String? selectedSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Lấy thông tin sản phẩm theo ID
    ProductServices.getProductById(widget.id)
        .then((value) {
          setState(() {
            product = value;
          });
        })
        .catchError((err) {
          print("Failed to load product: $err");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: product == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh sản phẩm
                  Image.network(
                    product["image"],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image_not_supported, size: 80),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Tên sản phẩm
                  Text(
                    product["name"],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Giá sản phẩm
                  Text(
                    "\$${product["price"]}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Mô tả
                  Text(
                    product["description"],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  // Chọn size
                  const Text(
                    "Chọn size:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    children: (product["size"] as List).map<Widget>((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: selectedSize == size,
                        onSelected: (selected) {
                          setState(() {
                            selectedSize = selected ? size : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Số lượng tồn kho
                  Text(
                    "Số lượng còn lại: ${product["quantity"]}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // Thêm vào giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("Product ID: ${widget.id}");
                        print("Selected size: $selectedSize");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text("Thêm vào giỏ hàng"),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Sản phẩm liên quan
                  const Text(
                    "Sản phẩm liên quan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product["relatedProducts"].length,
                      itemBuilder: (context, index) {
                        final related = product["relatedProducts"][index];

                        return SizedBox(
                          width: 160,
                          child: Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Hình ảnh sản phẩm liên quan
                                  Expanded(
                                    child: Image.network(
                                      related["image"],
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.image_not_supported,
                                            );
                                          },
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Tên
                                  Text(
                                    related["name"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  // Giá
                                  Text(
                                    "\$${related["price"]}",
                                    style: const TextStyle(
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
