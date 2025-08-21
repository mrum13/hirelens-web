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

  void fetchDatas() async {
    final client = Supabase.instance.client;

    try {
      final response = await client.auth.admin.listUsers();

      final List<User> tmp =
          response.where((data) {
            return data.userMetadata!['role'] != null;
          }).toList();

      setState(() {
        isLoading = false;
        datas = tmp;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: ${e.toString()}')),
      );
    }
  }

  void banUser(String dataId) async {}

  void sendResetCode(String email) async {}

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
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Table(
                  border: TableBorder(
                    bottom: BorderSide(
                      color: themeFromContext(context).colorScheme.outline,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Name", textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Email", textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Role", textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Date Created",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Last Login",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(8.0)),
                      ],
                    ),
                    ...datas.map((data) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              data.userMetadata!['displayName'] ?? "-",
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              data.email ?? "-",
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              data.userMetadata!['role'] ?? "-",
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              DateTime.parse(
                                data.createdAt,
                              ).toLocal().toString(),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              data.lastSignInAt != null
                                  ? DateTime.parse(
                                    data.lastSignInAt!,
                                  ).toLocal().toString()
                                  : "-",
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              spacing: 4,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.do_not_disturb_alt_outlined),
                                  onPressed: () => banUser(data.id),
                                  tooltip: "Ban User",
                                ),
                                IconButton(
                                  icon: Icon(Icons.mail_outline),
                                  onPressed: () => sendResetCode(data.email!),
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
          ],
        ),
      ),
    );
  }
}
