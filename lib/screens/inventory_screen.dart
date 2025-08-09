import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forest/components/custom_bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../components/custom_card.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Coca Cola',
      'category': 'Boisson gazeuse',
      'stock': 36,
      'barcode': '36985214753951',
      'price': 'XAF 1500',
      'image': 'assets/img/coca_cola.png',
    },
    {
      'name': 'Doritos',
      'category': 'Snacks',
      'stock': 30,
      'barcode': '36985214753951',
      'price': 'XAF 500',
      'image': 'assets/img/doritos.png',
    },
    {
      'name': 'Lays',
      'category': 'Snacks',
      'stock': 40,
      'barcode': '36985214753951',
      'price': 'XAF 1200',
      'image': 'assets/img/lays.png',
    },
    {
      'name': 'Pommes',
      'category': 'Fruits',
      'stock': 20,
      'barcode': '36985214753951',
      'price': ' XAF 450',
      'image': 'assets/img/apples.png',
    },
  ];

  int _currentIndex = 1;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) Navigator.pushNamed(context, '/home');
    if (index == 1) Navigator.pushNamed(context, '/inventory');
    if (index == 2) Navigator.pushNamed(context, '/data-collection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppConstants.lightGrey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        CupertinoIcons.chevron_left,
                        color: AppConstants.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Inventaire',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.lightGrey,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppConstants.textGrey,
                            size: 25,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rechercher...',
                            style: GoogleFonts.poppins(
                              color: AppConstants.textGrey,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppConstants.lightGrey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: AppConstants.white,
                      size: 23,
                    ),
                  ),
                ],
              ),
            ),

            // Section Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Articles',
                    style: GoogleFonts.poppins(
                      color: AppConstants.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Voir Tout',
                    style: GoogleFonts.poppins(
                      color: AppConstants.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _buildItemCard(
                    item,
                    index == 3,
                  ); // Last item has add button
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, bool showAddButton) {
    return CustomCard(
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory,
              color: AppConstants.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['name']} (${item['category']})',
                  style: GoogleFonts.poppins(
                    color: AppConstants.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['stock']} en stock',
                  style: GoogleFonts.poppins(
                    color: AppConstants.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.qr_code, color: AppConstants.textGrey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item['barcode'],
                      style: GoogleFonts.poppins(
                        color: AppConstants.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price and Add Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['price'],
                style: GoogleFonts.poppins(
                  color: AppConstants.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showAddButton) ...[
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: AppConstants.white, size: 20),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
