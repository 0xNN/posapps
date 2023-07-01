import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posapps/db/db.dart';
import 'package:posapps/models/gudang.dart';
import 'package:posapps/models/pelanggan.dart';
import 'package:posapps/models/produk.dart';
import 'package:posapps/models/produk_kategori.dart';
import 'package:posapps/models/salesman.dart';
import 'package:posapps/pages/penjualan.dart';
import 'package:posapps/pages/transaksi.dart';
import 'package:posapps/resources/string.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:posapps/router/router.dart' as router;
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:select_dialog/select_dialog.dart';
import 'package:get/get.dart';
import 'package:posapps/store/store.dart';

enum PageSection {
  PENJUALAN,
  TRANSAKSI,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  final sdkVersion = androidInfo.version.sdkInt ?? 0;
  final androidOverscrollIndicator = sdkVersion > 30
      ? AndroidOverscrollIndicator.stretch
      : AndroidOverscrollIndicator.glow;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MyApp(
      androidOverscrollIndicator: androidOverscrollIndicator,
    ));
  });
  runApp(MyApp(
    androidOverscrollIndicator: androidOverscrollIndicator,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    this.androidOverscrollIndicator = AndroidOverscrollIndicator.glow,
  }) : super(key: key);
  final AndroidOverscrollIndicator androidOverscrollIndicator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        androidOverscrollIndicator: androidOverscrollIndicator,
      ),
      onGenerateRoute: router.generateRoute,
      home: const MyHomePage(title: 'POS MEDEQ'),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 0.82),
          child: child,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Controller c = Get.put(Controller());
  DBHelper dbHelper = DBHelper();

  bool isLoading = false;
  bool isLoadingSave = false;

  Future<SalesmanRes> futureSalesmanRes() async {
    String url = '${API_URL}PosApps/Salesman';
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      return SalesmanRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Salesman');
    }
  }

  String salesmanSelected = "Pilih Salesman";
  List<SalesmanData> salesmanData;
  Map<String, SalesmanData> salesmanMap = {};

  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _teleponController = TextEditingController();

  Future<GudangRes> futureGudangRes() async {
    String url = '${API_URL}PosApps/Gudang';
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      return GudangRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Gudang');
    }
  }

  Future<ProdukKategoriRes> futureProdukKategoriRes() async {
    String url = '${API_URL}PosApps/ProdukKategori';
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      return ProdukKategoriRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load ProdukKategori');
    }
  }

  Future<ProdukRes> futureProdukRes() async {
    String url = '${API_URL}PosApps/Produk';
    print(url);

    String gudangId = "";
    // if (MODE != "api") {
    //   await dbHelper.gudangDataByNama(dropdownvalue).then((value) {
    //     gudangId = value.Id;
    //   });
    // } else {
    //   gudangId = gudangDataMap[dropdownvalue].Id;
    // }
    Map<String, dynamic> body = {
      // "GudangId": "",
      "PelangganId": "",
      "SubKategoriId": produkKategoriSelected == "No value selected"
          ? ""
          : produkKategoriDataMap[produkKategoriSelected].id,
    };
    print(body);
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      return ProdukRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Produk');
    }
  }

  Future<PelangganSaveRes> futurePelangganSaveRes() async {
    String url = '${API_URL}PosApps/PelangganSave';
    print(url);
    Map<String, dynamic> body = {
      "Nama": _namaController.text,
      "Alamat": _alamatController.text,
      "NoTelp": _teleponController.text,
      "SalesmanId": salesmanMap[salesmanSelected].id,
    };
    print(body);
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      return PelangganSaveRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load PelangganSave');
    }
  }

  List<GudangData> gudangData;
  List<ProdukKategoriData> produkKategoriData;
  List<ProdukData> produkData;

  Map<String, GudangData> gudangDataMap = {};
  Map<String, ProdukKategoriData> produkKategoriDataMap = {};
  Map<String, ProdukData> produkDataMap = {};

  PageSection section = PageSection.PENJUALAN;

  // Initial Selected Value
  String dropdownvalue = 'Item 1';

  // List of items in our dropdown menu
  List<String> items = [];

  String id;

  String produkKategoriSelected = "No value selected";

  String activePage = "penjualan";

  bool isReset = false;

  Future<void> _getId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        id = androidInfo.androidId;
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        id = iosInfo.identifierForVendor;
      });
    }
  }

  @override
  void initState() {
    // _getId();
    isLoading = true;
    futureSalesmanRes().then((value) async {
      if (MODE != "api") {
        if (value != null) {
          for (SalesmanData data in value.data) {
            await dbHelper.insertSalesman(data);
          }
        }
        dbHelper.salesmans().then((value) {
          for (SalesmanData element in value) {
            salesmanMap[element.nama] = element;
          }
          setState(() {
            salesmanData = value;
          });
        });
      } else {
        if (value != null) {
          for (SalesmanData data in value.data) {
            salesmanMap[data.nama] = data;
          }
          setState(() {
            salesmanData = value.data;
          });
        }
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
    futureProdukKategoriRes().then((value) async {
      if (value != null) {
        if (MODE != "api") {
          for (ProdukKategoriData produkKategori in value.data) {
            await dbHelper.insertProdukKategori(produkKategori);
          }
        } else {
          String nama = "";
          for (ProdukKategoriData element in value.data) {
            produkKategoriDataMap[element.nama] = element;
            if (element.isDefault == "1") {
              nama = element.nama;
            }
          }
          setState(() {
            produkKategoriSelected = nama;
            produkKategoriData = value.data;
          });
          print("JALANKAN INI");
          futureProdukRes().then((value) async {
            if (value != null) {
              if (MODE != "api") {
                for (ProdukData produk in value.data) {
                  await dbHelper.insertProduk(produk);
                }
              } else {
                for (ProdukData element in value.data) {
                  produkDataMap[element.produk] = element;
                }
                setState(() {
                  produkData = value.data;
                });
              }
              if (MODE != "api") {
                await dbHelper.produks().then((value) {
                  setState(() {
                    produkData = value;
                  });
                });
              }
            }
          }).catchError((error) {
            print("ERROR: $error");
          });
        }
        if (MODE != "api") {
          await dbHelper.produkKategoris().then((value) {
            setState(() {
              produkKategoriData = value;
            });
          });
        }
      }
    }).catchError((error) {
      print("ERROR: $error");
    });
    futureGudangRes().then((value) async {
      if (value != null) {
        if (MODE != "api") {
          for (GudangData gudang in value.data) {
            await dbHelper.insertGudang(gudang);
          }
        } else {
          for (GudangData element in value.data) {
            items.add(element.Nama);
            gudangDataMap[element.Nama] = element;
          }
          setState(() {
            dropdownvalue = items[0];
          });
        }
      }
      if (MODE != "api") {
        await dbHelper.gudangs().then((value) {
          for (GudangData element in value) {
            items.add(element.Nama);
          }
          setState(() {
            dropdownvalue = items[0];
          });
        });
      }
    }).catchError((error) {
      print("ERROR: $error");
    });
    super.initState();
  }

  Widget _drawerHeader(String id) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: ClipOval(
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      accountName: Text('Demo Apps'),
      accountEmail: Text("Device ID: $id"),
    );
  }

  Widget _drawerItem(
      {IconData icon,
      String text,
      bool selected = false,
      GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(
            icon,
            color: selected ? Colors.blue : Colors.black,
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.0),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
      selected: selected,
      selectedTileColor: Colors.blue.withOpacity(0.1),
    );
  }

  _showMoreDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, updateState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 16,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Pilih Data Gudang',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: DropdownSearch<String>(
                        mode: Mode.MENU,
                        showSelectedItems: true,
                        items: items,
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Pilih Gudang",
                          hintText: "Pilih Gudang",
                        ),
                        // popupItemDisabled: (String s) => s.startsWith('I'),
                        onChanged: (newValue) {
                          updateState(() {
                            dropdownvalue = newValue;
                          });
                          setState(() {});
                        },
                        selectedItem: dropdownvalue,
                      ),
                      // DropdownButtonFormField(
                      //   elevation: 0,
                      //   decoration: InputDecoration(
                      //     enabledBorder: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: Colors.grey.shade200, width: 1),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     border: OutlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: Colors.grey.shade200, width: 1),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     filled: true,
                      //     fillColor: Colors.grey.shade200,
                      //   ),
                      //   dropdownColor: Colors.grey.shade200,
                      //   value: dropdownvalue,
                      //   onChanged: (String newValue) {
                      //     setState(() {
                      //       dropdownvalue = newValue;
                      //     });
                      //   },
                      //   items: items.map((String items) {
                      //     return DropdownMenuItem(
                      //       value: items,
                      //       child: Text(items),
                      //     );
                      //   }).toList(),
                      // ),
                    ),
                  ),
                  Spacer(),
                  Divider(),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey.shade300,
                            shadowColor: Colors.transparent,
                            onPrimary: Colors.black,
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            futureProdukRes().then((value) {
                              setState(() {
                                produkData = value.data;
                                isReset = true;
                              });
                            });
                          },
                          child: Text('OK'),
                        ),
                      ),
                      // SizedBox(width: 20),
                      // Expanded(
                      //   child: ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       primary: Colors.blue.shade500,
                      //       shadowColor: Colors.transparent,
                      //       onPrimary: Colors.white,
                      //     ),
                      //     onPressed: isLoading
                      //         ? null
                      //         : () async {
                      //             updateState(() {
                      //               isLoading = true;
                      //             });
                      //             await futureProdukKategoriRes()
                      //                 .then((value) async {
                      //               if (value != null) {
                      //                 for (ProdukKategoriData produkKategori
                      //                     in value.data) {
                      //                   await dbHelper.insertProdukKategori(
                      //                       produkKategori);
                      //                 }
                      //                 await dbHelper
                      //                     .produkKategoris()
                      //                     .then((value) {
                      //                   updateState(() {
                      //                     produkKategoriData = value;
                      //                   });
                      //                 });
                      //               }
                      //             }).catchError((error) {
                      //               print("ERROR: $error");
                      //             });
                      //             await futureProdukRes().then((value) async {
                      //               if (value != null) {
                      //                 for (ProdukData produk in value.data) {
                      //                   dbHelper.insertProduk(produk);
                      //                 }
                      //                 await dbHelper.produks().then((value) {
                      //                   updateState(() {
                      //                     produkData = value;
                      //                   });
                      //                   setState(() {});
                      //                 });
                      //               }
                      //             }).catchError((error) {
                      //               print("ERROR: $error");
                      //             });
                      //             updateState(() {
                      //               isLoading = false;
                      //             });
                      //             Navigator.of(context).pop();
                      //           },
                      //     child: isLoading
                      //         ? SizedBox(
                      //             height: 20,
                      //             width: 20,
                      //             child: CircularProgressIndicator(
                      //               strokeWidth: 2,
                      //               valueColor: AlwaysStoppedAnimation<Color>(
                      //                   Colors.white),
                      //             ),
                      //           )
                      //         : Text('Sync'),
                      //   ),
                      // ),
                      SizedBox(width: 20),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    print("ONEEEEE");
    print(isReset);
    print(produkData);
    switch (c.activePage.value) {
      case "penjualan":
        body = PenjualanPage(
          produkDatas: produkData == null ? [] : produkData,
          reset: isReset,
        );
        break;
      case "transaksi":
        body = TransaksiPage(
          refresh: _refresh,
        );
        break;
      default:
        body = PenjualanPage(
          produkDatas: produkData == null ? [] : produkData,
          reset: isReset,
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: c.activePage == "penjualan"
            ? Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.all(7),
                    child: InkWell(
                      onTap: () {
                        SelectDialog.showModal<String>(
                          context,
                          label: "List Produk Kategori",
                          selectedValue: produkKategoriSelected,
                          items: produkKategoriData == null
                              ? []
                              : produkKategoriData
                                  .map((ProdukKategoriData item) {
                                  return item.nama;
                                }).toList(),
                          onChange: (String selected) {
                            setState(() {
                              produkKategoriSelected = selected;
                            });
                            futureProdukRes().then((value) {
                              setState(() {
                                produkData = value.data;
                                isReset = true;
                              });
                            });
                          },
                          constraints:
                              BoxConstraints(maxHeight: 400, maxWidth: 400),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            produkKategoriSelected,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Input Customer
                  IconButton(
                    icon: Icon(Icons.person_add, color: Colors.white),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return StatefulBuilder(
                                builder: (context, updateState) {
                              return AlertDialog(
                                title: Text("Input Customer"),
                                contentPadding:
                                    EdgeInsets.fromLTRB(24, 20, 24, 0),
                                content: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade300,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: InkWell(
                                          onTap: () {
                                            SelectDialog.showModal<String>(
                                              context,
                                              label: "List Salesman",
                                              selectedValue: salesmanSelected,
                                              items: salesmanData == null
                                                  ? []
                                                  : salesmanData
                                                      .map((SalesmanData item) {
                                                      return item.nama;
                                                    }).toList(),
                                              onChange:
                                                  (String selected) async {
                                                updateState(() {
                                                  salesmanSelected = selected;
                                                });
                                              },
                                              constraints: BoxConstraints(
                                                  maxHeight: 400,
                                                  maxWidth: 400),
                                            );
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                salesmanSelected,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Icon(Icons.arrow_drop_down,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: _namaController,
                                        decoration: InputDecoration(
                                          labelText: "Nama",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: _alamatController,
                                        decoration: InputDecoration(
                                          labelText: "Alamat",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: _teleponController,
                                        decoration: InputDecoration(
                                          labelText: "Telepon",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.grey,
                                              elevation: 0,
                                            ),
                                            child: Text("Batal"),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (salesmanSelected ==
                                                  "Pilih Salesman") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Salesman tidak boleh kosong"),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (_namaController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Nama tidak boleh kosong"),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (_alamatController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Alamat tidak boleh kosong"),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (_teleponController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Telepon tidak boleh kosong"),
                                                  ),
                                                );
                                                return;
                                              }
                                              updateState(() {
                                                isLoadingSave = true;
                                              });
                                              await futurePelangganSaveRes()
                                                  .then((value) {
                                                if (value != null) {
                                                  Navigator.of(context).pop();
                                                  c.setSalesman(
                                                      salesmanSelected);
                                                  c.setPelanggan(
                                                      value.data.nama);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Berhasil disimpan"),
                                                    ),
                                                  );
                                                  setState(() {
                                                    isReset = true;
                                                  });
                                                }
                                                updateState(() {
                                                  isLoadingSave = false;
                                                });
                                              }).catchError((error) {
                                                print("ERROR: $error");
                                                updateState(() {
                                                  isLoadingSave = false;
                                                });
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.blue.shade300,
                                              elevation: 0,
                                            ),
                                            child: isLoadingSave
                                                ? SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                  )
                                                : Text("Simpan"),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                actionsPadding:
                                    MediaQuery.of(context).viewInsets,
                                actionsOverflowDirection: VerticalDirection
                                    .up, // button will be aligned to the top
                                actions: [],
                              );
                            });
                          });
                    },
                    padding: EdgeInsets.zero,
                    tooltip: "Input Customer",
                  ),
                ],
              )
            : null,
        actions: c.activePage == "penjualan"
            ? <Widget>[
                IconButton(icon: Icon(Icons.search), onPressed: () {}),
                // IconButton(icon: Icon(Icons.upload), onPressed: () {}),
                // IconButton(
                //   icon: Icon(Icons.inventory),
                //   onPressed: () {
                //     // Dialog Gudang
                //     _showMoreDialog(context);
                //   },
                // ),
              ]
            : null,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _drawerHeader(id),
            _drawerItem(
              icon: Icons.shopping_basket,
              text: 'Penjualan',
              onTap: () {
                Navigator.pop(context);
                // setState(() {
                //   activePage = "penjualan";
                // });
                setState(() {
                  c.setActivePage("penjualan");
                });
              },
              selected: c.activePage == "penjualan",
            ),
            _drawerItem(
              icon: Icons.note_alt,
              text: 'Transaksi',
              onTap: () {
                Navigator.pop(context);
                // setState(() {
                //   activePage = "transaksi";
                // });
                setState(() {
                  c.setActivePage("transaksi");
                });
              },
              selected: c.activePage == "transaksi",
            ),
          ],
        ),
      ),
      body: Center(
        child: body,
      ),
    );
  }
}
