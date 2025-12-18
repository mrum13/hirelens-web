import "package:d_method/d_method.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
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
  List galleryImages = [];
  List<String> selectedGalleryImages = [];
  bool isLoading = false;
  bool buttonLoading = false;
  bool galleryLoading = false;

  void fetchDatas() async {
    setState(() {
      isLoading = true;
      datas.clear();
    });

    final client = Supabase.instance.client;
    final response = await client
        .from('items_with_transaction_count')
        .select('*, vendors(id, name)');

    setState(() {
      datas.addAll(response);
      isLoading = false;
    });
  }

  void fetchItemsGallery() async {
    try {
      setState(() {
        galleryLoading = true;
      });
      final client = Supabase.instance.client;
      var response = await client.from('item_gallery').select('*');
      // .eq('item_id', itemId);

      setState(() {
        galleryImages = response;
        galleryLoading = false;
      });

      DMethod.log("Berhasil get", prefix: "Fetch Item Gallery");
      DMethod.log("$galleryImages", prefix: "Fetch Item Gallery");
    } catch (e) {
      setState(() {
        galleryLoading = false;
      });
      DMethod.log(e.toString(), prefix: "Fetch Item Gallery");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void verifyItem(String itemId, bool status) async {
    try {
      setState(() {
        isLoading = true;
      });
      final client = Supabase.instance.client;
      await client
          .from('items')
          .update({'is_verified': status})
          .eq('id', itemId)
          .select();

      setState(() {
        isLoading = false;
      });

      fetchDatas();

      String message =
          status ? "Item berhasil diverifikasi" : "Item berhasil ditolak";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
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

  Future getFilteredGallery(String itemId) async {
    selectedGalleryImages.clear();
    for (var item in galleryImages) {
      if (item['item_id'] == itemId) {
        selectedGalleryImages.add(item['image_url']);
      }
    }
  }

  void openItemDetail(String itemId) async {
    await getFilteredGallery(itemId);

    DMethod.log(selectedGalleryImages.toString());

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        selectedData['thumbnail'],
                        width: 360,
                        height: 480,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedData['name'],
                            style:
                                themeFromContext(
                                  context,
                                ).textTheme.displayLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Vendor: ${selectedData['vendors']['name']}",
                            style:
                                themeFromContext(
                                  context,
                                ).textTheme.displayMedium,
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              selectedData['is_verified'] == null
                                  ? "Belum diverifikasi"
                                  : (selectedData['is_verified']
                                      ? "Terverifikasi"
                                      : "Tidak Terverifikasi"),
                            ),
                          ),
                          SizedBox(height: 8),
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
                          const SizedBox(height: 24),
                          Text(
                            "Gallery",
                            style:
                                themeFromContext(
                                  context,
                                ).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          galleryLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: selectedGalleryImages.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    child: Image.network(
                                                      selectedGalleryImages[index],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Image.network(
                                              selectedGalleryImages[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          const SizedBox(height: 8),
                          Text(
                            "BTS",
                            style:
                                themeFromContext(
                                  context,
                                ).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hirelensDarkTheme.colorScheme.tertiary,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      verifyItem(itemId, true);
                    },
                    child: Text(
                      "Verifikasi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      verifyItem(itemId, false);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text("Tolak"),
                  ),
                ),
                // MyFilledButton(
                //   variant: MyFilledButtonVariant.secondary,
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     // context.go('/app/items/edit');
                //   },
                //   child: Text("Verifikasi", style: TextStyle(color: Colors.black54)),
                // ),
                // const SizedBox(width: 24,),
                // MyFilledButton(
                //   variant: MyFilledButtonVariant.error,
                //   onTap: () {
                //     Navigator.of(context).pop();
                //     // context.go('/app/items/edit');
                //   },
                //   child: Text("Tolak", style: TextStyle(color: Colors.black54)),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            MyFilledButton(
              variant: MyFilledButtonVariant.error,
              onTap: () {
                Navigator.pop(context);
                deleteItem(
                  itemId: itemId,
                  transactionsCount: selectedData['transaction_count'],
                );
              },
              child: Text(
                "Hapus",
                style: TextStyle(
                  color: themeFromContext(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
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

  void deleteItem({
    required String itemId,
    required int transactionsCount,
  }) async {
    if (transactionsCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Selesaikan atau hapus transaksi terlebih dahulu !",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        setState(() {
          buttonLoading = true;
        });

        final supabase = Supabase.instance.client;
        await supabase.from('items').delete().eq('id', itemId);

        setState(() {
          buttonLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Items berhasil dihapus",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        fetchDatas();
      } catch (e) {
        setState(() {
          buttonLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDatas();
    fetchItemsGallery();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribeItem();
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
                      childAspectRatio: 2.3,
                    ),
                    itemBuilder: (context, index) {
                      final item = datas[index];

                      return GestureDetector(
                        onTap: () => openItemDetail(item['id']),
                        child: Container(
                          width: double.infinity,
                          // height: 156,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color:
                                themeFromContext(
                                  context,
                                ).colorScheme.surfaceBright,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // spacing: 8,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item['thumbnail'],
                                  width: 80,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                  Text(
                                    item['vendors']['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "${formatCurrency(item['price'])} / 1 jam",
                                    style:
                                        themeFromContext(
                                          context,
                                        ).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.amber),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      item['is_verified'] == null
                                          ? "Belum diverifikasi"
                                          : (item['is_verified']
                                              ? "Terverifikasi"
                                              : "Tidak Terverifikasi"),
                                    ),
                                  ),
                                  const Spacer(),

                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Total transaksi : ",
                                          style:
                                              themeFromContext(
                                                context,
                                              ).textTheme.labelLarge,
                                        ),
                                        TextSpan(
                                          text:
                                              item['transaction_count']
                                                  .toString(),
                                          style:
                                              themeFromContext(
                                                context,
                                              ).textTheme.displayLarge,
                                        ),
                                      ],
                                    ),
                                  ),
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
