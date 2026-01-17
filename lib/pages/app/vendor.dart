import "dart:convert";
import "package:d_method/d_method.dart";
import "package:flutter/material.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> vendors = [];
  String? errorMessage;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVendors2();
  }

  Future<void> fetchVendors2() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final response = await client.from('vendors').select('*');

      setState(() {
        isLoading = false;
        vendors = response;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      DMethod.log(e.toString());
    }
  }

  // Future<void> fetchVendors() async {
  //   setState(() {
  //     isLoading = true;
  //     errorMessage = null;
  //   });

  //   try {

  //     final response = await Supabase.instance.client.rpc('get_all_users');

  //     final client = Supabase.instance.client;
  //     final response = await client
  //       .from('vendors')
  //       .select('*');

  //     if (response != null) {
  //       final List<dynamic> usersList =
  //           response is String
  //               ? jsonDecode(response)
  //               : (response is List ? response : []);

  //       // Filter vendor - simple approach
  //       final List<Map<String, dynamic>> tmp = [];
  //       for (var user in usersList) {
  //         try {
  //           final metadata = user['user_metadata'] as Map<String, dynamic>?;
  //           final role = metadata?['role']?.toString().toLowerCase();

  //           if (role == 'vendor') {
  //             tmp.add({
  //               'id': user['id']?.toString() ?? '',
  //               'email': user['email']?.toString() ?? '-',
  //               'displayName': metadata?['displayName']?.toString() ?? '-',
  //               'phone': metadata?['phone']?.toString() ?? '-',
  //               'created_at': user['created_at']?.toString() ?? '-',
  //               'last_sign_in_at': user['last_sign_in_at']?.toString() ?? '-',
  //             });

  //             nameController.text = metadata?['displayName']?.toString() ?? '-';
  //             phoneController.text = metadata?['phone']?.toString() ?? '-';
  //             cityController.text =
  //           }
  //         } catch (e) {
  //           print('Error parsing user: $e');
  //         }
  //       }

  //       print('Filtered vendors: ${tmp.length}');

  //       setState(() {
  //         isLoading = false;
  //         vendors = tmp;
  //       });
  //     } else {
  //       throw Exception('Invalid response');
  //     }
  //   } catch (e) {
  //     print('ERROR: $e');

  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Error: $e')));
  //     }

  //     setState(() {
  //       isLoading = false;
  //       errorMessage = e.toString();
  //     });
  //   }
  // }

  Future<void> editVendor({required int index}) async {
    try {
      setState(() {
        isLoading = true;
      });
      final client = Supabase.instance.client;
      await client
          .from('vendors')
          .update({
            'name': nameController.text,
            'phone': phoneController.text,
            'city': cityController.text,
          })
          .eq('id', vendors[index]['id'].toString())
          .select();


      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Profile berhasil diupdate",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      fetchVendors2();
      Navigator.pop(context);
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

  String _formatDate(String dateStr) {
    if (dateStr == '-') return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyAppLayout(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Vendor Management",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${vendors.length} vendors registered",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Error Message
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: fetchVendors2,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vendors.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.store_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No vendors found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: fetchVendors2,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: vendors.length,
                        itemBuilder: (context, index) {
                          final vendor = vendors[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.store),
                              ),
                              title: Text(
                                vendor['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${vendor['email']}'),
                                  Text('Phone: ${vendor['phone']}'),
                                  Text('City: ${vendor['city']}'),
                                  Text(
                                    'Created: ${_formatDate(vendor['created_at'])}',
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit Vendor'),
                                      ),
                                      // const PopupMenuItem(
                                      //   value: 'ban',
                                      //   child: Text('Ban Vendor'),
                                      // ),
                                    ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    emailController.text = vendor['email'];
                                    nameController.text = vendor['name'];
                                    phoneController.text = vendor['phone'];
                                    cityController.text = vendor['city'];
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text(vendor['name']),
                                            content: Column(
                                              children: [
                                                TextField(
                                                  enabled: false,
                                                  autofocus: false,
                                                  controller: emailController,
                                                  decoration: InputDecoration(
                                                    label: Text('Email'),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  autofocus: false,
                                                  controller: nameController,
                                                  decoration: InputDecoration(
                                                    label: Text('Name'),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  autofocus: false,
                                                  controller: phoneController,
                                                  decoration: InputDecoration(
                                                    label: Text('Phone'),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  autofocus: false,
                                                  controller: cityController,
                                                  decoration: InputDecoration(
                                                    label: Text('City'),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  if (nameController
                                                          .text
                                                          .isEmpty ||
                                                      phoneController
                                                          .text
                                                          .isEmpty ||
                                                      cityController
                                                          .text
                                                          .isEmpty) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "Lengkapi form terlebih dahulu",
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    editVendor(index: index);
                                                  }
                                                },
                                                child: const Text('Save'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
