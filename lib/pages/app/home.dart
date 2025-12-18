import "package:d_method/d_method.dart";
import "package:flutter/material.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  int totalUsers = 0;
  int totalVendors = 0;
  int totalCustomers = 0;
  int totalTransactions = 0;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final client = Supabase.instance.client;

      // Fetch all users using RPC function
      print('Fetching users...');
      final usersResponse = await client.rpc('get_all_users');
      print('Users response received');

      if (usersResponse != null) {
        final List<dynamic> usersList =
            usersResponse is String
                ? []
                : (usersResponse is List ? usersResponse : []);

        print('Total users: ${usersList.length}');

        // Count total users
        totalUsers = usersList.length;

        // Count users by role
        totalVendors =
            usersList.where((user) {
              final metadata = user['user_metadata'] as Map<String, dynamic>?;
              return metadata?['role']?.toString().toLowerCase() == 'vendor';
            }).length;

        totalCustomers =
            usersList.where((user) {
              final metadata = user['user_metadata'] as Map<String, dynamic>?;
              return metadata?['role']?.toString().toLowerCase() == 'customer';
            }).length;

        print('Filtered vendors: $totalVendors');
      }

      // Fetch total transactions
      try {
        final transactionsResponse = await client
            .from('transactions')
            .select('*');

        

        totalTransactions = transactionsResponse.length;
      } catch (e) {
        print('Transactions error: $e');
        totalTransactions = 0;
      }

      // Fetch total items
      try {
        final itemsResponse = await client.from('items').select('id');

        totalItems = itemsResponse.length;
      } catch (e) {
        print('Items error: $e');
        totalItems = 0;
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper untuk check ukuran screen
  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Get responsive padding
  EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(16);
    if (isTablet(context)) return const EdgeInsets.all(20);
    return const EdgeInsets.all(24);
  }

  // Get responsive font size for title
  double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 24;
    if (isTablet(context)) return 28;
    return 32;
  }

  @override
  Widget build(BuildContext context) {
    return MyAppLayout(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff181C14),
        padding: getResponsivePadding(context),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xffC69749)),
                )
                : RefreshIndicator(
                  onRefresh: fetchDashboardData,
                  color: const Color(0xffC69749),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header - Responsive
                        _buildHeader(context),
                        SizedBox(height: isMobile(context) ? 24 : 40),

                        // Statistics Cards - Responsive Grid
                        _buildStatisticsGrid(context),

                        SizedBox(height: isMobile(context) ? 24 : 40),

                        // Recent Transactions Header
                        _buildTransactionsHeader(context),
                        const SizedBox(height: 16),

                        // Transactions Placeholder
                        _buildTransactionsPlaceholder(context),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (isMobile(context)) {
      // Mobile: Stack vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: getTitleFontSize(context),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Selamat datang di Hirelens Admin Panel',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
              ),
              IconButton(
                onPressed: fetchDashboardData,
                icon: const Icon(Icons.refresh),
                color: const Color(0xffC69749),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ],
      );
    }

    // Tablet & Desktop: Side by side
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: getTitleFontSize(context),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selamat datang di Hirelens Admin Panel',
              style: TextStyle(
                fontSize: isTablet(context) ? 14 : 16,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: fetchDashboardData,
          icon: const Icon(Icons.refresh),
          color: const Color(0xffC69749),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    final cards = [
      _buildStatCard(
        title: 'Total Users',
        value: '$totalUsers',
        subtitle: '$totalCustomers customers',
        icon: Icons.people,
        color: Colors.blue,
        context: context,
      ),
      _buildStatCard(
        title: 'Total Vendors',
        value: '$totalVendors',
        subtitle: 'Active vendors',
        icon: Icons.store,
        color: Colors.green,
        context: context,
      ),
      _buildStatCard(
        title: 'Total Transactions',
        value: '$totalTransactions',
        subtitle: 'All time',
        icon: Icons.receipt_long,
        color: Colors.orange,
        context: context,
      ),
      _buildStatCard(
        title: 'Total Items',
        value: '$totalItems',
        subtitle: 'Available items',
        icon: Icons.inventory,
        color: Colors.purple,
        context: context,
      ),
    ];

    if (isMobile(context)) {
      // Mobile: 1 column
      return Column(
        children:
            cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: card,
                  ),
                )
                .toList(),
      );
    } else if (isTablet(context)) {
      // Tablet: 2 columns
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      // Desktop: 2x2 grid (bisa juga 4 columns)
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    if (isMobile(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to transactions page
              },
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xffC69749)),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: isTablet(context) ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () {
            // Navigate to transactions page
          },
          child: const Text(
            'View All',
            style: TextStyle(color: Color(0xffC69749)),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile(context) ? 32 : 48),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3F34), width: 1),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: isMobile(context) ? 48 : 64,
              color: const Color(0xFF616161),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                color: const Color(0xFF9E9E9E),
                fontSize: isMobile(context) ? 16 : 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) {
    final cardPadding = isMobile(context) ? 16.0 : 24.0;
    final iconSize = isMobile(context) ? 20.0 : 24.0;
    final titleFontSize = isMobile(context) ? 12.0 : 14.0;
    final valueFontSize = isMobile(context) ? 24.0 : 32.0;
    final subtitleFontSize = isMobile(context) ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3F34), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: iconSize),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: isMobile(context) ? 16 : 20),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF9E9E9E),
              fontSize: titleFontSize,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: const Color(0xFF757575),
              fontSize: subtitleFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
