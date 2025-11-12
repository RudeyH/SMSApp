import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:sms_app/screens/product_report_screen.dart';
import 'package:sms_app/screens/purchase_order_list_screen.dart';
import 'package:sms_app/screens/settings_screen.dart';
import 'package:sms_app/screens/supplier_list_screen.dart';
import 'package:sms_app/screens/sales_order_list_screen.dart';
import 'package:sms_app/screens/product_list_screen.dart';
import 'package:sms_app/screens/customer_list_screen.dart';
import '../widgets/coming_soon_placeholder.dart';
import '../widgets/home_dashboard.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMainTab = 0;
  late Widget _selectedSubPage;
  String _appBarTitle = "Home";
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Default: Home Dashboard
    _selectedSubPage = const HomeDashboard();
  }

  void _showSubMenu(BuildContext context, List<_SubMenuItem> items) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: items
              .map(
                (item) => ListTile(
              leading: Icon(item.icon, color: Colors.blueAccent),
              title: Text(item.label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _switchPage(item.page, item.label);
              },
            ),
          )
              .toList(),
        );
      },
    );
  }

  void _switchPage(Widget newPage, String title) {
    setState(() {
      _appBarTitle = title;
    });

    // Smooth fade transition
    Future.delayed(Duration.zero, () {
      setState(() {
        _selectedSubPage = AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: newPage,
        );
      });
    });
  }

  void _onMainTabTapped(int index) {
    setState(() {
      _selectedMainTab = index;
    });

    switch (index) {
      case 0:
        _switchPage(const HomeDashboard(), "Home");
        break;
      case 1:
        _appBarTitle = "Master";
        // Show empty placeholder first
        _switchPage(_buildSelectMenuPlaceholder("Master"), "Master");
        _showSubMenu(context, [
          _SubMenuItem(
            icon: Icons.inventory_2,
            label: "Product Master",
            page: const ProductListScreen(),
          ),
          _SubMenuItem(
            icon: Icons.local_shipping,
            label: "Supplier Master",
            page: const SupplierListScreen(),
          ),
          _SubMenuItem(
            icon: Icons.people,
            label: "Customer Master",
            page: const CustomerListScreen(),
          ),
        ]);
        break;
      case 2:
        _appBarTitle = "Transaction";
        _switchPage(_buildSelectMenuPlaceholder("Transaction"), "Transaction");
        _showSubMenu(context, [
          _SubMenuItem(
            icon: Icons.shopping_cart,
            label: "Purchase Order",
            page: const PurchaseOrderListScreen(),
          ),
          _SubMenuItem(
            icon: Icons.sell,
            label: "Sales Order",
            page: const SalesOrderListScreen(),
          ),
        ]);
        break;
      case 3:
        _appBarTitle = "Report";
        _switchPage(_buildSelectMenuPlaceholder("Report"), "Report");
        _showSubMenu(context, [
          _SubMenuItem(
            icon: Icons.report_sharp,
            label: "Product Report",
            page: const ProductReportScreen(),
          ),
        ]);
        break;
      case 4:
        _switchPage(const SettingsScreen(), "Settings");
        break;
    }
  }

  // Widget _buildTempPlaceholder(String menuName) {
  //   return ComingSoonPlaceholder(menuName: menuName);
  // }

  /// ✅ This new helper builds the "Select one of the menu below" screen
  /// ✅ Enhanced, modern placeholder with animation and card styling
  Widget _buildSelectMenuPlaceholder(String menuName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Card(
              key: ValueKey(menuName),
              elevation: 6,
              color: Colors.white,
              shadowColor: Colors.grey.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Icon(
                      Icons.menu_open_rounded,
                      size: 80,
                      color: Colors.blueAccent.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      'Select one of the $menuName menu below',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle hint
                    Text(
                      'Choose an option from the bottom sheet menu to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home, size: 28),
      const Icon(Icons.dashboard, size: 28),
      const Icon(Icons.swap_horiz, size: 28),
      const Icon(Icons.bar_chart, size: 28),
      const Icon(Icons.settings, size: 28),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          _appBarTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: _selectedMainTab != 0 &&
            _appBarTitle != "Home" &&
            _selectedSubPage is! HomeDashboard
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _switchPage(const HomeDashboard(), "Home");
            setState(() => _selectedMainTab = 0);
          },
        )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _selectedSubPage,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        items: items,
        index: _selectedMainTab,
        height: 60,
        color: Colors.blueAccent,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 400),
        animationCurve: Curves.easeInOutCubic,
        onTap: _onMainTabTapped,
      ),
    );
  }
}

class _SubMenuItem {
  final IconData icon;
  final String label;
  final Widget page;

  _SubMenuItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}
