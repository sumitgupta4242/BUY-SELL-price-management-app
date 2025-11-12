// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'item_model.dart';
import 'add_edit_item_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Inventory',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshItems() async {
    setState(() {
      _isLoading = true;
    });
    final data = await DatabaseHelper.instance.getAllItems();
    setState(() {
      _allItems = data;
      _filteredItems = data;
      _isLoading = false;
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        return item.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateAndRefresh({Item? item}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditItemPage(item: item)),
    );
    _refreshItems();
  }

  void _confirmDeleteItem(int id) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text('Are you sure you want to delete this item?'),
              actions: [
                TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop()),
                TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                    onPressed: () {
                      DatabaseHelper.instance.deleteItem(id);
                      Navigator.of(context).pop();
                      _refreshItems();
                    }),
              ],
            ));
  }

  // Method to show the item details in a pop-up dialog
  void _showItemDetailsDialog(Item item) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat.yMMMd().add_jm();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(item.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow(
                    'Buying Price:',
                    item.buyingPrice != null
                        ? currencyFormat.format(item.buyingPrice!)
                        : 'N/A'),
                _buildDetailRow(
                    'Selling Price:',
                    item.sellingPrice != null
                        ? currencyFormat.format(item.sellingPrice!)
                        : 'N/A'),
                _buildDetailRow(
                    'Wholesale Price:',
                    item.wholesalePrice != null
                        ? currencyFormat.format(item.wholesalePrice!)
                        : 'N/A'),
                _buildDetailRow(
                    'Maintenance Cost:',
                    item.maintenanceCost != null
                        ? currencyFormat.format(item.maintenanceCost!)
                        : 'N/A'),
                const Divider(height: 24, thickness: 1),
                _buildDetailRow(
                    'Created On:', dateFormat.format(item.createdAt)),
                _buildDetailRow(
                    'Last Updated:', dateFormat.format(item.updatedAt)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper widget for building a row in the details dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Items'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by item name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : _buildItemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'No items yet!'
                : 'No items found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          Text(
            _searchController.text.isEmpty
                ? 'Tap the + button to add a new item.'
                : 'Try a different search term.',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  ListView _buildItemsList() {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return Card(
          child: ListTile(
            onTap: () => _showItemDetailsDialog(item), // Shows the dialog
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              item.sellingPrice != null
                  ? 'Sell Price: ${currencyFormat.format(item.sellingPrice!)}'
                  : 'No selling price set',
              style: TextStyle(
                color: item.sellingPrice != null
                    ? Colors.green.shade800
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.blue.shade700,
                  onPressed: () => _navigateAndRefresh(item: item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade700,
                  onPressed: () => _confirmDeleteItem(item.id!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

