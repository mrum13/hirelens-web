import "package:d_method/d_method.dart";
import "package:flutter/material.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:intl/intl.dart";

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];
  String searchQuery = "";
  String selectedStatus = "all";

  @override
  void initState() {
    super.initState();
    fetchTransactions();
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
          .select('*, vendors!inner(id,name)')
          .order('created_at', ascending: false);

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

  void searchTransactions({required String keyword}) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final client = Supabase.instance.client;

      late PostgrestTransformBuilder<List<Map<String,dynamic>>> query; 

      if (keyword.isNotEmpty) {
        query = client
          .from('transactions')
          .select('*, vendors!inner(id,name)')
          .or('user_displayname.ilike.%$keyword%')
          .order('created_at', ascending: false);
      } else {
        query = client
          .from('transactions')
          .select('*, vendors!inner(id,name)')
          .order('created_at', ascending: false);
      }

      final response = await query;

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

  void filterTransactions() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final client = Supabase.instance.client;
      late List<Map<String, dynamic>> response;

      if (selectedStatus != "all") {
        // Fetch transactions tanpa join (simple query)
        response = await client
            .from('transactions')
            .select('*, vendors!inner(id,name)')
            .eq('status_work', selectedStatus)
            .order('created_at', ascending: false);
      } else {
        // Fetch transactions tanpa join (simple query)
        response = await client
            .from('transactions')
            .select('*, vendors!inner(id,name)')
            .order('created_at', ascending: false);
      }

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

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
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

  void _showEditStatusDialog(Map<String, dynamic> transaction) {
    String newStatus = transaction['status'] ?? 'pending';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2F24),
            title: const Text(
              'Update Status',
              style: TextStyle(color: Colors.white),
            ),
            content: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'URL Photos status:',
                      style: TextStyle(color: Color(0xFF9E9E9E)),
                    ),
                    DropdownButton<String>(
                      value: newStatus,
                      dropdownColor: const Color(0xFF2A2F24),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          newStatus = value ?? 'pending';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payout status:',
                      style: TextStyle(color: Color(0xFF9E9E9E)),
                    ),
                    DropdownButton<String>(
                      value: newStatus,
                      dropdownColor: const Color(0xFF2A2F24),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          newStatus = value ?? 'pending';
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await Supabase.instance.client
                        .from('transactions')
                        .update({'status': newStatus})
                        .eq('id', transaction['id']);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Status updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      fetchTransactions();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Color(0xffC69749)),
                ),
              ),
            ],
          ),
    );
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
                    _buildDetailRow(
                      'Status Payout',
                      transaction['status_payout'] ?? '-',
                    ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kelola semua transaksi pelanggan',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: fetchTransactions,
                  icon: const Icon(Icons.refresh),
                  color: const Color(0xffC69749),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter Bar
            Row(
              children: [
                // Search Box
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2F24),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3A3F34)),
                    ),
                    child: TextField(
                      onSubmitted: (value) {
                        searchQuery = value;
                        searchTransactions(keyword: searchQuery);
                        // filterTransactions();
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search by Customer name...',
                        hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xffC69749),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Status Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2F24),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF3A3F34)),
                  ),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    dropdownColor: const Color(0xFF2A2F24),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xffC69749),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Semua')),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 'waiting',
                        child: Text('Waiting'),
                      ),
                      DropdownMenuItem(
                        value: 'editing',
                        child: Text('Editing'),
                      ),
                      DropdownMenuItem(
                        value: 'post_processing',
                        child: Text('Post Processing'),
                      ),
                      DropdownMenuItem(
                        value: 'complete',
                        child: Text('Complete'),
                      ),
                      DropdownMenuItem(value: 'cancel', child: Text('Cancel')),
                      DropdownMenuItem(value: 'finish', child: Text('Finish')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value ?? 'all';
                        filterTransactions();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transaction Count
            Text(
              'Total: ${filteredTransactions.length} transactions',
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Transactions Table
            Expanded(
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xffC69749),
                        ),
                      )
                      : filteredTransactions.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty || selectedStatus != 'all'
                                  ? 'Tidak ada transaksi yang cocok'
                                  : 'Belum ada transaksi',
                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 18,
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
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
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
                                // DataColumn(
                                //   label: Text(
                                //     'Payment Type',
                                //     style: TextStyle(
                                //       color: Color(0xffC69749),
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
                                DataColumn(
                                  label: Text(
                                    'Amount',
                                    style: TextStyle(
                                      color: Color(0xffC69749),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // DataColumn(
                                //   label: Text(
                                //     'Status Payment',
                                //     style: TextStyle(
                                //       color: Color(0xffC69749),
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
                                // DataColumn(
                                //   label: Text(
                                //     'Status Work',
                                //     style: TextStyle(
                                //       color: Color(0xffC69749),
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
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
                                // DataColumn(
                                //   label: Text(
                                //     'Status Payouts',
                                //     style: TextStyle(
                                //       color: Color(0xffC69749),
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
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
                                  filteredTransactions.map((transaction) {
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

                                        // DataCell(
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 12,
                                        //       vertical: 6,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: getStatusColor(
                                        //         transaction['payment_type'],
                                        //       ).withOpacity(0.2),
                                        //       borderRadius:
                                        //           BorderRadius.circular(12),
                                        //       border: Border.all(
                                        //         color: getStatusColor(
                                        //           transaction['payment_type'],
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     child: Text(
                                        //       transaction['payment_type'] ??
                                        //           'Unknown',
                                        //       style: TextStyle(
                                        //         color: getStatusColor(
                                        //           transaction['payment_type'],
                                        //         ),
                                        //         fontSize: 12,
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        DataCell(
                                          Text(
                                            formatCurrency(
                                              transaction['amount'],
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // DataCell(
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 12,
                                        //       vertical: 6,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: getStatusColor(
                                        //         transaction['status_payment'],
                                        //       ).withOpacity(0.2),
                                        //       borderRadius:
                                        //           BorderRadius.circular(12),
                                        //       border: Border.all(
                                        //         color: getStatusColor(
                                        //           transaction['status_payment'],
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     child: Text(
                                        //       transaction['status_payment'] ??
                                        //           'Unknown',
                                        //       style: TextStyle(
                                        //         color: getStatusColor(
                                        //           transaction['status_payment'],
                                        //         ),
                                        //         fontSize: 12,
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        // DataCell(
                                        //   Container(
                                        //     padding: const EdgeInsets.symmetric(
                                        //       horizontal: 12,
                                        //       vertical: 6,
                                        //     ),
                                        //     decoration: BoxDecoration(
                                        //       color: getStatusColor(
                                        //         transaction['status_work'],
                                        //       ).withOpacity(0.2),
                                        //       borderRadius:
                                        //           BorderRadius.circular(12),
                                        //       border: Border.all(
                                        //         color: getStatusColor(
                                        //           transaction['status_work'],
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     child: Text(
                                        //       transaction['status_work'] ??
                                        //           'Unknown',
                                        //       style: TextStyle(
                                        //         color: getStatusColor(
                                        //           transaction['status_work'],
                                        //         ),
                                        //         fontSize: 12,
                                        //         fontWeight: FontWeight.bold,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        DataCell(
                                          Text(
                                            formatDate(
                                              transaction['created_at'],
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            formatDate(
                                              transaction['status_work'],
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          SelectableText(
                                            transaction['url_photos']
                                                .toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Icon(
                                          //   Icons.link,
                                          //   color: transaction['status_url_photos']==null?Colors.grey:(transaction['status_url_photos']=='approved'?Colors.green:Colors.red),
                                          //   size: 20,
                                          // )
                                        ),
                                        // DataCell(
                                        //   Text(
                                        //     transaction['status_payout'],
                                        //     style: const TextStyle(
                                        //       color: Colors.white,
                                        //       fontWeight: FontWeight.bold,
                                        //     ),
                                        //   ),
                                        // ),
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
                      ),
            ),
          ],
        ),
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
