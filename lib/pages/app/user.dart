import "dart:convert";
import "package:d_method/d_method.dart";
import "package:flutter/material.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
import "package:hirelens_admin/theme.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool isLoading = true;
  List<User> datas = [];
  String? errorMessage;

  void fetchDatas() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final client = Supabase.instance.client;

    try {
      print('Calling database function...');

      // Pakai RPC function
      final response = await client.rpc('get_all_users');

      DMethod.log(response.toString(), prefix: "Response RPC");

      print('Response: $response');
      print('Response type: ${response.runtimeType}');

      if (response != null) {
        // Parse JSON response
        final List<dynamic> usersList =
            response is String
                ? jsonDecode(response)
                : (response is List ? response : []);

        print('Users list length: ${usersList.length}');

        final List<User> tmp =
            usersList
                .map<User?>((json) {
                  try {
                    // Adjust mapping sesuai struktur dari function
                    final userData = {
                      'id': json['id'],
                      'email': json['email'],
                      'created_at': json['created_at'],
                      'last_sign_in_at': json['last_sign_in_at'],
                      'user_metadata': json['user_metadata'],
                    };
                    return User.fromJson(userData);
                  } catch (e) {
                    print('Error parsing user: $e');
                    print('JSON data: $json');
                    return null;
                  }
                })
                .where(
                  (user) => user != null && user.userMetadata?['role'] != null,
                )
                .cast<User>()
                .toList();

        print('Filtered users: ${tmp.length}');

        setState(() {
          isLoading = false;
          datas = tmp;
        });

      } else {
        throw Exception('Invalid response: response is null');
      }
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void banUser(String dataId) async {
    // TODO: Implement ban user functionality
    print('Ban user: $dataId');
  }

  void sendResetCode(String email) async {
    // TODO: Implement send reset code functionality
    print('Send reset code to: $email');
  }

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  @override
  Widget build(BuildContext context) {
    return MyAppLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Page",
              style: themeFromContext(context).textTheme.displayLarge,
            ),
            SizedBox(height: 16),
            if (errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                color: Colors.red.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(onPressed: fetchDatas, child: Text('Retry')),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : datas.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users with role found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextButton(
                              onPressed: fetchDatas,
                              child: Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Table(
                            border: TableBorder(
                              bottom: BorderSide(
                                color:
                                    themeFromContext(
                                      context,
                                    ).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            defaultColumnWidth: IntrinsicColumnWidth(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: themeFromContext(
                                    context,
                                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "Name",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "Email",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "Role",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "Rekening",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "No. Rekening",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "Date Created",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "Last Login",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      "Actions",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ...datas.map((data) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        data.userMetadata?['displayName'] ??
                                            "-",
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(data.email ?? "-"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getRoleColor(
                                            data.userMetadata?['role'],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          data.userMetadata?['role'] ?? "-",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(data.userMetadata?['bankName'] ??
                                            "-"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(data.userMetadata?['bankAccount'] ??
                                            "-"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(_formatDate(data.createdAt)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        data.lastSignInAt != null
                                            ? _formatDate(data.lastSignInAt!)
                                            : "-",
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.do_not_disturb_alt_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => banUser(data.id),
                                            tooltip: "Ban User",
                                          ),
                                          SizedBox(width: 4),
                                          IconButton(
                                            icon: Icon(
                                              Icons.mail_outline,
                                              size: 20,
                                            ),
                                            onPressed:
                                                () =>
                                                    sendResetCode(data.email!),
                                            tooltip: "Send Reset Password Code",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function untuk format tanggal
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  // Helper function untuk warna role
  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'vendor':
        return Colors.blue;
      case 'customer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
