import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> allProducts = [
    "Áo thun nam",
    "Đầm dạ hội",
    "Quần jeans nữ",
    "Giày thể thao",
    "Túi xách thời trang",
    "Mũ lưỡi trai",
  ];
  List<String> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = allProducts;
  }

  void _filterSearchResults(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((product) => product.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Tìm kiếm sản phẩm...",
            border: InputBorder.none,
          ),
          onChanged: _filterSearchResults,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              _filterSearchResults("");
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredProducts[index]),
            onTap: () {
              // Thêm chức năng khi chọn sản phẩm
            },
          );
        },
      ),
    );
  }
}
