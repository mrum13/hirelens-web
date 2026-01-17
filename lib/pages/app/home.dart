import "package:d_method/d_method.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hirelens_admin/components/item_card.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
import "package:intl/intl.dart";
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
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    fetchTransactions();
  }

  Future<void> fetchDashboardData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final client = Supabase.instance.client;
      final usersResponse = await client.rpc('get_all_users');

      if (usersResponse != null) {
        final List<dynamic> usersList =
            usersResponse is String
                ? []
                : (usersResponse is List ? usersResponse : []);

        // Count total users
        totalUsers =
            usersList.where((user) {
              final role =
                  (user['user_metadata']?['role'] as String?)?.toLowerCase();

              return role == 'vendor' || role == 'customer';
            }).length;

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

  Future<void> fetchTransactions() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final client = Supabase.instance.client;

      // Fetch transactions tanpa join (simple query)
      final response = await client
          .from('transactions')
          .select('*, vendors!inner(id,name,bank_name,bank_account)')
          .order('created_at', ascending: true)
          .limit(4);

      if (mounted) {
        setState(() {
          transactions = List<Map<String, dynamic>>.from(response);
          filteredTransactions = transactions;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
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

  void _showCustomMenu(
    BuildContext context,
    Offset offset,
    Map<String, dynamic> transaction,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selectedValue = await showMenu<String>(
      context: context,
      // Position the menu relative to the global position of the tap
      position: RelativeRect.fromRect(
        Rect.fromPoints(offset, offset),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(value: 'option1', child: Text('Lihat Detail')),
        if (transaction['url_photos'] != null)
          const PopupMenuItem(
            value: 'option2',
            child: Text('Verifikasi Hasil'),
          ),
        if (transaction['url_photos'] != null)
          const PopupMenuItem<String>(
            value: 'option3',
            child: Text('Tolak Hasil'),
          ),
        if (transaction['status_payout'] != "not_requested")
          const PopupMenuItem<String>(
            value: 'option4',
            child: Text('Complete Payout/Refund'),
          ),

        PopupMenuItem<String>(value: 'option5', child: Text('Delete')),
      ],
      elevation: 8.0,
    );

    // Handle the selection
    if (selectedValue == "option1") {
      _showTransactionDetail(transaction);
    } else if (selectedValue == "option2") {
      _updateStatusUrlPhotos(transactionId: transaction['id'], status: true);
    } else if (selectedValue == "option3") {
      _updateStatusUrlPhotos(transactionId: transaction['id'], status: false);
    } else if (selectedValue == "option4") {
      _updateStatusPayout(transactionId: transaction['id']);
    } else if (selectedValue == "option5") {
      _deleteTransaction(transaction);
    }
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    final vendor = transaction['vendors'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2F24),
            title: const Text(
              'Transaction Details',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow(
                      'Transaction ID',
                      transaction['id'].toString(),
                    ),
                    _buildDetailRow(
                      'Customer',
                      transaction['user_displayname'] ?? 'Unknown',
                    ),
                    _buildDetailRow('Vendor', vendor?['name'] ?? 'Unknown'),
                    _buildDetailRow(
                      'Durasi',
                      "${transaction['durasi']} jam" ?? 'Unknown',
                    ),
                    _buildDetailRow(
                      'Amount',
                      formatCurrency(transaction['amount']),
                    ),
                    _buildDetailRow(
                      'Date',
                      formatDate(transaction['created_at']),
                    ),
                    _buildDetailRow(
                      'URL Photos',
                      transaction['url_photos'] ?? '-',
                    ),
                    _buildDetailRow(
                      'Status Payment',
                      transaction['status_payment'] ?? '-',
                    ),
                    _buildDetailRow(
                      'Status Work',
                      transaction['status_work'] ?? '-',
                    ),
                    _buildDetailRow(
                      'Status URL Photos',
                      transaction['status_url_photos'] ?? '-',
                    ),
                    // _buildDetailRow(
                    //   'Status Payout',
                    //   transaction['status_payout'] ?? '-',
                    // ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xffC69749)),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteTransaction(Map<String, dynamic> transaction) async {
    try {
      setState(() {
        isLoading = true;
      });

      final supabase = Supabase.instance.client;
      await supabase.from('transactions').delete().eq('id', transaction['id']);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Transaksi berhasil dihapus",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      fetchTransactions();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateStatusUrlPhotos({
    required String transactionId,
    required bool status,
  }) async {
    String statusUrlUpdate = status ? "approved" : "not_approved";
    String statusWorkUpdate = status ? "complete" : "post_processing";

    try {
      await Supabase.instance.client
          .from('transactions')
          .update({
            'status_url_photos': statusUrlUpdate,
            'status_work': statusWorkUpdate,
          })
          .eq('id', transactionId);

      String message =
          status ? "URL Photos di verifikasi" : "URL Photos di tolak";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      fetchTransactions();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error update status url photos: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateStatusPayout({required String transactionId}) async {
    try {
      await Supabase.instance.client
          .from('transactions')
          .update({'status_payout': 'complete'})
          .eq('id', transactionId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Payout $transactionId berhasil diupdate",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      fetchTransactions();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error update status payout: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      InkWell(
        onTap: () {
          context.go('/app/vendors');
        },
        child: _buildStatCard(
          title: 'Total Vendors',
          value: '$totalVendors',
          subtitle: 'Active vendors',
          icon: Icons.store,
          color: Colors.green,
          context: context,
        ),
      ),
      InkWell(
        onTap: () {
          context.go('/app/users');
        },
        child: _buildStatCard(
          title: 'Total Users',
          value: '$totalUsers',
          subtitle: '$totalCustomers customers',
          icon: Icons.people,
          color: Colors.blue,
          context: context,
        ),
      ),
      InkWell(
        onTap: () {
          context.go('/app/transactions');
        },
        child: _buildStatCard(
          title: 'Total Transactions',
          value: '$totalTransactions',
          subtitle: 'All time',
          icon: Icons.receipt_long,
          color: Colors.orange,
          context: context,
        ),
      ),
      InkWell(
        onTap: () {
          context.go('/app/items');
        },
        child: _buildStatCard(
          title: 'Total Items',
          value: '$totalItems',
          subtitle: 'Available items',
          icon: Icons.inventory,
          color: Colors.purple,
          context: context,
        ),
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
                context.go('/app/transactions');
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
            context.go('/app/transactions');
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
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3F34), width: 1),
      ),
      child:
          filteredTransactions.length == 0
              ? Center(
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
              )
              : Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2F24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3F34)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xFF3A3F34),
                            ),
                            dataRowColor: WidgetStateProperty.all(
                              const Color(0xFF2A2F24),
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'ID',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Customer',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Vendor',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Durasi',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Amount',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status Kerja',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'URL Photos',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Rekening Vendor',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(
                                    color: Color(0xffC69749),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows:
                                filteredTransactions.reversed.map((
                                  transaction,
                                ) {
                                  final customer =
                                      transaction as Map<String, dynamic>?;

                                  final vendor =
                                      transaction['vendors']
                                          as Map<String, dynamic>?;
                                  final customerName =
                                      customer?['user_displayname'] ??
                                      'Unknown Cus';
                                  final vendorName =
                                      vendor?['name'] ?? 'Unknown';
                                  final bankAccount =
                                      "${vendor!['bank_name']} | ${vendor['bank_account']}" ??
                                      'Unknown';

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          transaction['id']
                                              .toString()
                                              .substring(0, 8),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          customerName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          vendorName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          transaction['durasi'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          formatCurrency(transaction['amount']),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          formatDate(transaction['created_at']),
                                          style: const TextStyle(
                                            color: Color(0xFF9E9E9E),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SelectableText(
                                          transaction['status_work'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SelectableText(
                                          transaction['url_photos'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SelectableText(
                                          bankAccount,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        GestureDetector(
                                          onTapDown: (details) {
                                            _showCustomMenu(
                                              context,
                                              details.globalPosition,
                                              transaction,
                                            );
                                          },
                                          child: Icon(Icons.more_vert),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
