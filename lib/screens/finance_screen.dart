import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_helper.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Lists to hold data
  List<Map<String, dynamic>> _milkRecords = [];
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch Milk and Expenses from Database (Unchanged)
  Future<void> _loadData() async {
    final db = await DatabaseHelper().database;

    // Get all milk records (Newest first)
    final milkData = await db.query('milk', orderBy: "id DESC");

    // Get all expenses (Newest first)
    final expenseData = await db.query('expenses', orderBy: "id DESC");

    if (!mounted) return;

    setState(() {
      _milkRecords = milkData;
      _expenses = expenseData;
      _isLoading = false;
    });
  }

  // ✅ PREMIUM ADD EXPENSE DIALOG
  void _showAddExpenseDialog() {
    final itemController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text(
                "Add Expense",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemController,
                decoration: InputDecoration(
                  labelText: "Item Name (e.g. Feed)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Cost (Rs)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final itemName = itemController.text.trim();
                final amount = double.tryParse(amountController.text.trim());

                if (itemName.isEmpty || amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Enter a valid expense item and amount."),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);
                final db = await DatabaseHelper().database;
                await db.insert('expenses', {
                  'date': DateTime.now().toString().split(' ')[0],
                  'item': itemName,
                  'amount': amount,
                });

                if (mounted) {
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Expense saved!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    ).whenComplete(() {
      itemController.dispose();
      amountController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5), // Premium off-white background
      // ✅ MODERN APP BAR & TAB BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "Finance & Profit",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          indicatorWeight: 3,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(
              icon: Icon(FontAwesomeIcons.bottleDroplet, size: 20),
              text: "Milk Income",
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.wallet, size: 20),
              text: "Expenses",
            ),
          ],
        ),
      ),

      // ✅ FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Add Expense",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: _showAddExpenseDialog,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Milk Tab
                _milkRecords.isEmpty
                    ? _buildEmptyState(
                        FontAwesomeIcons.droplet,
                        "No milk records yet",
                        Colors.blue,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _milkRecords.length,
                        itemBuilder: (context, index) {
                          final item = _milkRecords[index];
                          final total =
                              (item['liter'] as double) *
                              (item['price'] as double);
                          return _buildTransactionCard(
                            title: "${item['liter']} Liters • ${item['time']}",
                            subtitle: item['date'],
                            amount: "+ Rs ${total.toStringAsFixed(0)}",
                            icon: Icons.water_drop_rounded,
                            color: Colors.blue,
                            isIncome: true,
                          );
                        },
                      ),

                // 2. Expenses Tab
                _expenses.isEmpty
                    ? _buildEmptyState(
                        FontAwesomeIcons.receipt,
                        "No expenses added",
                        Colors.redAccent,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final item = _expenses[index];
                          return _buildTransactionCard(
                            title: item['item'],
                            subtitle: item['date'],
                            amount: "- Rs ${item['amount']}",
                            icon: Icons.shopping_bag_rounded,
                            color: Colors.redAccent,
                            isIncome: false,
                          );
                        },
                      ),
              ],
            ),
    );
  }

  // ✅ PREMIUM TRANSACTION CARD UI
  Widget _buildTransactionCard({
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isIncome,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MODERN EMPTY STATE UI
  Widget _buildEmptyState(IconData icon, String text, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: color.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the + button to add a new record.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
