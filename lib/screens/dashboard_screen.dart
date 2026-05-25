import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/database_helper.dart';
import 'animal_list_screen.dart';
import 'finance_screen.dart';
import 'profile_screen.dart';
import 'ai_vet_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // ✅ THE PAGES LIST (Kept exactly as you had it)
  final List<Widget> _pages = [
    const HomeContent(), // 0: Home
    const AnimalListScreen(), // 1: Animals
    const FinanceScreen(), // 2: Finance
    const AIVetScreen(), // 3: AI
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5), // Premium off-white background
      // ✅ MODERN APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87), // Dark menu icon
        title: const Text(
          "FarmMate",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ✅ SIDE MENU (Profile) - Kept your routing logic!
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.agriculture, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "FarmMate Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blueGrey),
              title: const Text('My Profile', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ✅ THE PAGE BODY
      body: IndexedStack(index: _selectedIndex, children: _pages),

      // ✅ MODERN MATERIAL 3 NAVIGATION BAR
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.green.withValues(alpha: 0.2),
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: Colors.green),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.cow, size: 20),
            selectedIcon: Icon(
              FontAwesomeIcons.cow,
              color: Colors.green,
              size: 22,
            ),
            label: 'Animals',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.green,
            ),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded, color: Colors.green),
            label: 'AI Vet',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// HOME CONTENT (Your backend logic + New UI)
// ---------------------------------------------------------
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _totalAnimals = "0";
  String _todayMilk = "0";

  // ✅ Variables for the "Specific Cow" logic (Kept intact)
  bool _isIndividual = false;
  Map<String, dynamic>? _selectedCow;
  List<Map<String, dynamic>> _allCows = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final animals = await DatabaseHelper().getAnimals();
    final milk = await DatabaseHelper().getTodayMilk();

    if (mounted) {
      setState(() {
        _totalAnimals = animals.length.toString();
        _todayMilk = "${milk.toStringAsFixed(1)} L";
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadCows() {
    return DatabaseHelper().getAnimals();
  }

  // ✅ YOUR EXACT ADD MILK POPUP (Logic unchanged, styled slightly)
  Future<void> _showAddMilkDialog() async {
    final cows = await _loadCows();
    if (!mounted) return;

    _allCows = cows;
    final literController = TextEditingController();
    final priceController = TextEditingController();

    _isIndividual = false;
    _selectedCow = null;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Add Today's Milk",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Record Type:"),
                      DropdownButton<bool>(
                        value: _isIndividual,
                        items: const [
                          DropdownMenuItem(
                            value: false,
                            child: Text("Whole Farm"),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text("Specific Cow"),
                          ),
                        ],
                        onChanged: (val) {
                          setDialogState(() {
                            _isIndividual = val!;
                            _selectedCow = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_isIndividual)
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: InputDecoration(
                        labelText: "Select Cow",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                      items: _allCows.map((cow) {
                        return DropdownMenuItem(
                          value: cow,
                          child: Text(
                            "Tag: ${cow['tag_id']} (${cow['breed']})",
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => _selectedCow = val),
                    ),

                  const SizedBox(height: 15),
                  TextField(
                    controller: literController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Liters (e.g. 12.5)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Price per Liter (Rs)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final liters = double.tryParse(literController.text.trim());
                    final price = double.tryParse(priceController.text.trim());

                    if (liters == null ||
                        liters <= 0 ||
                        price == null ||
                        price < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter valid milk and price values."),
                        ),
                      );
                      return;
                    }

                    if (_isIndividual && _selectedCow == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a cow first!"),
                        ),
                      );
                      return;
                    }

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    await DatabaseHelper().insertMilk(
                      liters,
                      price,
                      "Morning",
                      cowId: _isIndividual && _selectedCow != null
                          ? _selectedCow!['id']
                          : null,
                    );

                    if (mounted) {
                      navigator.pop();
                      _loadData();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Milk Added Successfully!"),
                        ),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    literController.dispose();
    priceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          const Text(
            "Welcome back,",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Text(
            "Nasir Mehmood 👋",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // ✅ UNIFIED GRADIENT HERO CARD (Shows both Milk and Animals)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF4CAF50),
                ], // Premium Farm Green
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left Stat: Milk
                Column(
                  children: [
                    const Icon(
                      Icons.water_drop,
                      color: Colors.white70,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _todayMilk,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Today's Milk",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),

                // Divider line
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withValues(alpha: 0.3),
                ),

                // Right Stat: Animals
                Column(
                  children: [
                    const Icon(
                      FontAwesomeIcons.cow,
                      color: Colors.white70,
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _totalAnimals,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Total Animals",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ BEAUTIFUL FLOATING ACTION GRID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickAction(
                icon: Icons.water_drop_rounded,
                label: "Add Milk",
                color: Colors.blue,
                onTap: _showAddMilkDialog,
              ),
              _buildQuickAction(
                icon: Icons.pets_rounded,
                label: "Animals",
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnimalListScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAction(
                icon: Icons.receipt_long_rounded,
                label: "Finance",
                color: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FinanceScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Helper widget for the sleek square buttons
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 34),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
