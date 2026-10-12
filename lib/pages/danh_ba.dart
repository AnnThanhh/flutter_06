import 'package:flutter/material.dart';

class BaiTapDanhBa extends StatefulWidget {
  const BaiTapDanhBa({super.key});

  @override
  State<BaiTapDanhBa> createState() => _BaiTapDanhBaState();
}

class _BaiTapDanhBaState extends State<BaiTapDanhBa> {
  final List<Map<String, String>> listUser = [
    {
      'name': 'Nguyen Van A',
      'email': 'nguyenvana@example.com',
      'country': 'Vietnam',
    },
    {
      'name': 'Tran Thi B',
      'email': 'tranthib@example.com',
      'country': 'Vietnam',
    },
    {'name': 'Le Van C', 'email': 'levanc@example.com', 'country': 'Vietnam'},
    {
      'name': 'Pham Thi D',
      'email': 'phamthid@example.com',
      'country': 'Vietnam',
    },
    {
      'name': 'Hoang Van E',
      'email': 'hoangvane@example.com',
      'country': 'Vietnam',
    },
    {'name': 'Bui Thi F', 'email': 'buithif@example.com', 'country': 'Vietnam'},
    {
      'name': 'Dang Van G',
      'email': 'dangvang@example.com',
      'country': 'Vietnam',
    },
    {'name': 'Vu Thi H', 'email': 'vuthih@example.com', 'country': 'Vietnam'},
    {'name': 'Do Van I', 'email': 'dovani@example.com', 'country': 'Vietnam'},
    {'name': 'Ngo Thi J', 'email': 'ngothij@example.com', 'country': 'Vietnam'},
    {'name': 'John Smith', 'email': 'johnsmith@example.com', 'country': 'USA'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: listUser.length,
        itemBuilder: (context, index) {
          final item = listUser[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: Image.network(
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(item['name']!)}&background=random&bold=true',
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) =>
                    CircleAvatar(radius: 24, child: Text(item['name']![0])),
              ),
            ),
            title: Text(item['name']!),
            subtitle: Text('${item['email']} | ${item['country']}'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bạn chọn ${item['name']}')),
              );
            },
          );
        },
      ),
    );
  }
}
