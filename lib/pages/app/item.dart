import "package:flutter/material.dart";
import "package:hirelens_admin/components/buttons.dart";
import "package:hirelens_admin/components/item_card.dart";
import "package:hirelens_admin/pages/app/_layout.dart";
import "package:hirelens_admin/theme.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  List<Map<String, dynamic>> datas = [];
  bool isLoading = true;

  void fetchDatas() async {
    final client = Supabase.instance.client;
    final response = await client
        .from("items")
        .select("*, vendor(id, name)")
        .order('verified_at', ascending: false);

    setState(() {
      datas = response;
      isLoading = false;
    });
  }

  void verifyItem(int itemId) async {
    await showDialog(
      context: context,
      builder: (context) {
        final selectedData = datas.firstWhere((item) => item['id'] == itemId);

        return AlertDialog(
          title: Text(
            "Verify Item",
            style: themeFromContext(context).textTheme.displayMedium,
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Row(
                  spacing: 16,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        selectedData['thumbnail'],
                        width: 240,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedData['name'],
                          style:
                              themeFromContext(context).textTheme.displayLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Vendor: ${selectedData['vendor']['name']}",
                          style:
                              themeFromContext(context).textTheme.displayMedium,
                        ),
                        SizedBox(height: 48),
                        Text(
                          "Harga Mulai dari",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          formatCurrency(selectedData['price']),
                          style: themeFromContext(
                            context,
                          ).textTheme.displayLarge!.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: MyFilledButton(
                    variant: MyFilledButtonVariant.neutral,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: themeFromContext(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: MyFilledButton(
                    variant: MyFilledButtonVariant.primary,
                    onTap: () {
                      // URGENT: handle verify item logic
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Verify",
                      style: TextStyle(
                        color: themeFromContext(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void openItemDetail(int itemId) async {
    await showDialog(
      context: context,
      builder: (context) {
        final selectedData = datas.firstWhere((item) => item['id'] == itemId);

        return AlertDialog(
          title: Text(
            "Item Detail",
            style: themeFromContext(context).textTheme.displayMedium,
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Row(
                  spacing: 16,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        selectedData['thumbnail'],
                        width: 240,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedData['name'],
                          style:
                              themeFromContext(context).textTheme.displayLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Vendor: ${selectedData['vendor']['name']}",
                          style:
                              themeFromContext(context).textTheme.displayMedium,
                        ),
                        SizedBox(height: 48),
                        Text(
                          "Harga Mulai dari",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          formatCurrency(selectedData['price']),
                          style: themeFromContext(
                            context,
                          ).textTheme.displayLarge!.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            MyFilledButton(
              variant: MyFilledButtonVariant.neutral,
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: TextStyle(
                  color: themeFromContext(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void subscribeItem() async {
    final client = Supabase.instance.client;
    client.from('items').stream(primaryKey: ['id']).listen((data) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("New item added!")));
      fetchDatas();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeItem();
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
              "Items",
              style: themeFromContext(context).textTheme.displayLarge,
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                  child: GridView.builder(
                    itemCount: datas.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      final item = datas[index];

                      return GestureDetector(
                        onTap: () => openItemDetail(item['id']),
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                (item['is_verified'] as bool)
                                    ? themeFromContext(
                                      context,
                                    ).colorScheme.surfaceBright
                                    : themeFromContext(
                                      context,
                                    ).colorScheme.primary,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['thumbnail'],
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style:
                                        themeFromContext(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                  Expanded(
                                    child: SizedBox(height: double.infinity),
                                  ),
                                  Text(item['vendor']['name']),
                                ],
                              ),
                            ],
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
