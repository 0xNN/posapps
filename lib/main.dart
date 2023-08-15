import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:posapps/db/db.dart';
import 'package:posapps/models/gudang.dart';
import 'package:posapps/models/metode_bayar.dart';
import 'package:posapps/models/pelanggan.dart';
import 'package:posapps/models/produk.dart';
import 'package:posapps/models/produk_kategori.dart';
import 'package:posapps/models/salesman.dart';
import 'package:posapps/models/salesman_filter.dart';
import 'package:posapps/models/status_bayar.dart';
import 'package:posapps/models/user.dart';
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
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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
    return GetMaterialApp(
      title: 'Medeq POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        androidOverscrollIndicator: androidOverscrollIndicator,
      ),
      onGenerateRoute: router.generateRoute,
      home: const MyHomePage(title: 'Medeq POS'),
      builder: EasyLoading.init(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 0.82),
            child: child,
          );
        },
      ),
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
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<String> userId;
  Future<String> userName;

  Future<void> _user(String userId, String userName) async {
    final SharedPreferences pref = await prefs;
    // final String userId = pref.getString("user_id");
    // final String userName = pref.getString("user_name");
    setState(() {
      this.userId = pref.setString("user_id", userId).then((value) {
        return userId;
      });
      this.userName = pref.setString("user_name", userName).then((value) {
        return userName;
      });
    });
  }

  String date = "";

  DBHelper dbHelper = DBHelper();

  bool isLoading = false;
  bool isLoadingSave = false;

  bool isUpdateTransaksi = false;

  // Default now date
  final TextEditingController _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()));

  // Sampai tanggal
  final TextEditingController _dateToController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()));

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

  Future<SalesmanFilterRes> futureSalesmanFilterRes() async {
    String url = '${API_URL}PosApps/SalesmanFilter';
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      return SalesmanFilterRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load SalesmanFilter');
    }
  }

  Future<MetodeBayarRes> futureMetodeBayar() async {
    String url = "${API_URL}PosApps/MetodeBayar";
    final response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200) {
      return MetodeBayarRes.fromJson(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<UserRes> futureUserRes() async {
    String url = '${API_URL}PosApps/User';
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      return UserRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load User');
    }
  }

  String salesmanSelected = "Pilih Salesman";
  String salesmanFilterSelected = "Pilih Salesman";
  String statusPembayaranSelected = "Pilih Status Pembayaran";
  String userSelected = "Pilih User";

  List<SalesmanData> salesmanData;
  List<String> statusBayar = ["Lunas", "Belum Lunas"];
  List<SalesmanFilterData> salesmanFilterData;
  List<UserData> userData;

  Map<String, UserData> userDataMap = {};
  Map<String, SalesmanData> salesmanMap = {};
  Map<String, SalesmanFilterData> salesmanFilterMap = {};

  TextEditingController _namaController = TextEditingController();
  TextEditingController _alamatController = TextEditingController();
  TextEditingController _teleponController = TextEditingController();

  TextEditingController _searchController = TextEditingController();

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

  Future<ProdukRes> futureProdukRes({String invoiceId}) async {
    String url = '${API_URL}PosApps/Produk';
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
      "SubKategoriId": produkKategoriSelected == "No value selected" ||
              produkKategoriSelected == ""
          ? ""
          : produkKategoriDataMap[produkKategoriSelected].id,
      "InvoiceId": invoiceId ?? "",
    };
    print(body);
    print(url);
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      return ProdukRes.fromMap(jsonDecode(response.body));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data produk"),
        ),
      );
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

  Future<StatusBayarRes> futureStatusBayarRes() async {
    String url = '${API_URL}PosApps/StatusBayar';
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      return StatusBayarRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load StatusBayar');
    }
  }

  List<GudangData> gudangData;
  List<ProdukKategoriData> produkKategoriData;
  List<ProdukData> produkData;
  List<ProdukData> produkDataOriginal;

  Map<String, GudangData> gudangDataMap = {};
  Map<String, ProdukKategoriData> produkKategoriDataMap = {};
  Map<String, ProdukData> produkDataMap = {};

  List<StatusBayarData> statusBayarData;
  Map<String, StatusBayarData> statusBayarDataMap = {};

  PageSection section = PageSection.PENJUALAN;

  // Initial Selected Value
  String dropdownvalue = 'Item 1';

  // List of items in our dropdown menu
  List<String> items = [];

  String id;

  String produkKategoriSelected = "No value selected";

  String activePage = "penjualan";

  bool isReset = false;
  bool isBySearch = false;

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
    c.setTanggal(_dateController.text);
    c.setTanggalTo(_dateToController.text);
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
    futureSalesmanFilterRes().then((value) async {
      if (MODE != "api") {
        // if (value != null) {
        //   for (SalesmanData data in value.data) {
        //     await dbHelper.insertSalesman(data);
        //   }
        // }
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
          String namaDefault = "";
          for (SalesmanFilterData data in value.data) {
            salesmanFilterMap[data.nama] = data;
            if (data.isDefault == 1) {
              namaDefault = data.nama;
            }
          }
          setState(() {
            salesmanFilterData = value.data;
            salesmanFilterSelected = namaDefault;
          });
        }
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
    futureStatusBayarRes().then((value) async {
      if (value != null) {
        for (StatusBayarData data in value.data) {
          statusBayarDataMap[data.nama] = data;
        }
        setState(() {
          statusBayarData = value.data;
        });
      }
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
    futureProdukKategoriRes().then((value) async {
      if (value.data != null) {
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
          futureProdukRes(invoiceId: c.isEdit ? c.invoiceId : null)
              .then((value) async {
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
                  produkDataOriginal = value.data;
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
      } else {
        throw Exception("Failed to load data");
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
    futureUserRes().then((value) async {
      if (value != null) {
        if (value.data.isNotEmpty) {
          userData = value.data;
          for (UserData data in value.data) {
            userDataMap[data.nama] = data;
          }
          final SharedPreferences pref = await prefs;
          final String userId = pref.getString("user_id");
          final String userName = pref.getString("user_name");
          if (userId != null && userName != null) {
            setState(() {
              this.userId = pref.setString("user_id", userId).then((value) {
                return userId;
              });
              this.userName =
                  pref.setString("user_name", userName).then((value) {
                return userName;
              });
              userSelected = userName;
            });
          } else {
            setState(() {
              userSelected = "Pilih User";
            });
          }
        } else {
          userData = null;
        }
      } else {
        userData = null;
      }
    }).catchError((error) {
      print("ERROR: $error");
      userData = null;
    });
    super.initState();
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  Widget _drawerHeader(String id) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      currentAccountPicture: ClipOval(
        // child: Icon(
        //   Icons.person,
        //   color: Colors.white,
        // ),
        child: Image.asset(
          'images/logo-medeq.png',
          // fit: BoxFit.cover,
          width: 50,
        ),
      ),
      accountName: Text(
        'Medeq Mandiri Utama - POS',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      accountEmail: Text(
        "Device ID: ${id ?? "-"}",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
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

  void _refresh() async {
    print("MASUK REFRERGHSS");
    if (c.isEdit) {
      await futureProdukRes(invoiceId: c.isEdit ? c.invoiceId : null)
          .then((value) {
        setState(() {
          produkData = value.data;
          produkDataOriginal = value.data;
          isReset = true;
        });
      });
    } else {
      setState(() {});
    }
  }

  void _reload() async {
    if (c.isReload) {
      // if (Loader.isShown) {
      //   Loader.hide();
      // }
      // Loader.show(context, progressIndicator: CircularProgressIndicator());
      // setState(() {
      //   produkData = null;
      //   produkDataOriginal = null;
      //   isReset = true;
      // });
      await futureProdukRes(invoiceId: c.isEdit ? c.invoiceId : null)
          .then((value) {
        setState(() {
          produkData = value.data;
          produkDataOriginal = value.data;
          isReset = true;
        });
        // context.loaderOverlay.hide();
      });
      // Loader.hide();
      c.setReload(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    print("BUILDDDD");
    print(isBySearch);
    switch (c.activePage.value) {
      case "penjualan":
        body = PenjualanPage(
          produkDatas: produkData == null ? [] : produkData,
          reset: isReset,
          reload: _reload,
          bySearch: isBySearch,
          refresh: _refresh,
        );
        break;
      case "transaksi":
        body = TransaksiPage(
          refresh: _refresh,
          isUpdate: isUpdateTransaksi,
        );
        break;
      default:
        body = PenjualanPage(
          produkDatas: produkData == null ? [] : produkData,
          reset: isReset,
          reload: _reload,
          bySearch: isBySearch,
          refresh: _refresh,
        );
        break;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: c.activePage.toString() == "penjualan"
            ? Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.all(7),
                    child: InkWell(
                      onTap: () async {
                        if (!c.isResetProduk) {
                          await AwesomeDialog(
                            context: context,
                            dialogType: DialogType.question,
                            animType: AnimType.topSlide,
                            title: 'Konfirmasi',
                            desc:
                                'Mengganti kategori akan mereset produk beserta keranjang. Lanjutkan?',
                            dismissOnTouchOutside: false,
                            dismissOnBackKeyPress: false,
                            btnOkText: "Ya",
                            btnCancelText: "Tidak",
                            btnCancelOnPress: () {
                              return;
                            },
                            btnOkOnPress: () {
                              SelectDialog.showModal<String>(
                                context,
                                label: "List Produk Kategori",
                                selectedValue: produkKategoriSelected,
                                searchBoxDecoration: InputDecoration(
                                  hintText: "Cari Produk Kategori",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                items: produkKategoriData == null
                                    ? []
                                    : produkKategoriData
                                        .map((ProdukKategoriData item) {
                                        return item.nama;
                                      }).toList(),
                                onChange: (String selected) async {
                                  setState(() {
                                    produkKategoriSelected = selected;
                                  });
                                  futureProdukRes(
                                          invoiceId:
                                              c.isEdit ? c.invoiceId : null)
                                      .then((value) {
                                    setState(() {
                                      produkData = value.data;
                                      produkDataOriginal = value.data;
                                      isReset = true;
                                      isBySearch = false;
                                    });
                                    c.setResetProduk(true);
                                  });
                                },
                                constraints: BoxConstraints(
                                    maxHeight: 400, maxWidth: 400),
                              );
                            },
                          ).show();
                        } else {
                          SelectDialog.showModal<String>(
                            context,
                            label: "List Produk Kategori",
                            searchBoxDecoration: InputDecoration(
                              hintText: "Cari Produk Kategori",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            selectedValue: produkKategoriSelected,
                            items: produkKategoriData == null
                                ? []
                                : produkKategoriData
                                    .map((ProdukKategoriData item) {
                                    return item.nama;
                                  }).toList(),
                            onChange: (String selected) async {
                              setState(() {
                                produkKategoriSelected = selected;
                              });
                              futureProdukRes(
                                      invoiceId: c.isEdit ? c.invoiceId : null)
                                  .then((value) {
                                setState(() {
                                  produkData = value.data;
                                  produkDataOriginal = value.data;
                                  isReset = true;
                                  isBySearch = false;
                                });
                                c.setResetProduk(true);
                              });
                            },
                            constraints:
                                BoxConstraints(maxHeight: 400, maxWidth: 400),
                          );
                        }
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
                  // Pilih User
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
                          label: "List User",
                          searchBoxDecoration: InputDecoration(
                            hintText: "Cari User",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          selectedValue:
                              userName == null ? "Pilih User" : userSelected,
                          items: userData == null
                              ? []
                              : userData.map((UserData item) {
                                  return item.nama;
                                }).toList(),
                          onChange: (String selected) async {
                            await _user(userDataMap[selected].id, selected);
                            userName.then((value) {
                              setState(() {
                                userSelected = value;
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
                            userName == null ? "Pilih User" : userSelected,
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
                                scrollable: true,
                                title: Text("Input Customer"),
                                contentPadding:
                                    EdgeInsets.fromLTRB(24, 20, 24, 0),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade300,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: EdgeInsets.all(4),
                                      child: InkWell(
                                        onTap: () {
                                          SelectDialog.showModal<String>(
                                            context,
                                            label: "List Salesman",
                                            searchBoxDecoration:
                                                InputDecoration(
                                              hintText: "Cari Salesman",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            selectedValue: salesmanSelected,
                                            items: salesmanData == null
                                                ? []
                                                : salesmanData
                                                    .map((SalesmanData item) {
                                                    return item.nama;
                                                  }).toList(),
                                            onChange: (String selected) async {
                                              updateState(() {
                                                salesmanSelected = selected;
                                              });
                                            },
                                            constraints: BoxConstraints(
                                                maxHeight: 400, maxWidth: 400),
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
                                        labelText: "No Whatsapp",
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
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
                                            if (_namaController.text.isEmpty) {
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
                                                c.setSalesman(salesmanSelected);
                                                c.setPelanggan(value.data.nama);
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
                                // actionsPadding:
                                //     MediaQuery.of(context).viewInsets,
                                // actionsOverflowDirection: VerticalDirection
                                //     .up, // button will be aligned to the top
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
                //Search Input
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  margin: EdgeInsets.only(
                    right: 10,
                    top: 10,
                    bottom: 10,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari Produk",
                      contentPadding: EdgeInsets.only(left: 5),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 14,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_searchController.text.isEmpty) {
                              produkData = produkDataOriginal;
                            } else {
                              produkData = produkData
                                  .where(
                                    (element) => element.produk
                                        .toLowerCase()
                                        .contains(
                                          _searchController.text.toLowerCase(),
                                        ),
                                  )
                                  .toList();
                            }
                            isBySearch = true;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        if (_searchController.text.isEmpty) {
                          produkData = produkDataOriginal;
                        } else {
                          produkData = produkData
                              .where(
                                (element) =>
                                    element.produk.toLowerCase().contains(
                                          _searchController.text.toLowerCase(),
                                        ),
                              )
                              .toList();
                        }
                        isBySearch = true;
                      });
                    },
                  ),
                ),
                // IconButton(icon: Icon(Icons.upload), onPressed: () {}),
                // IconButton(
                //   icon: Icon(Icons.inventory),
                //   onPressed: () {
                //     // Dialog Gudang
                //     _showMoreDialog(context);
                //   },
                // ),
              ]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.filter_alt),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter updateState) {
                            return AlertDialog(
                              // scrollable: true,
                              title: Text("Filter"),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  children: [
                                    // Pilih Salesman
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade300,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(4),
                                      child: InkWell(
                                        onTap: () {
                                          SelectDialog.showModal<String>(
                                            context,
                                            label: "List Salesman",
                                            searchBoxDecoration:
                                                InputDecoration(
                                              hintText: "Cari Salesman",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            selectedValue:
                                                salesmanFilterSelected,
                                            items: salesmanFilterData == null
                                                ? []
                                                : salesmanFilterData.map(
                                                    (SalesmanFilterData item) {
                                                    return item.nama;
                                                  }).toList(),
                                            onChange: (String selected) async {
                                              updateState(() {
                                                salesmanFilterSelected =
                                                    selected;
                                              });
                                            },
                                            constraints: BoxConstraints(
                                                maxHeight: 400, maxWidth: 400),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              salesmanFilterSelected,
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
                                    SizedBox(height: 15),
                                    // Pilih Status Pembayaran
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade300,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.all(4),
                                      child: InkWell(
                                        onTap: () {
                                          SelectDialog.showModal<String>(
                                            context,
                                            label: "List Status Pembayaran",
                                            searchBoxDecoration:
                                                InputDecoration(
                                              hintText:
                                                  "Cari Status Pembayaran",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            selectedValue:
                                                statusPembayaranSelected,
                                            items: statusBayarData == null
                                                ? []
                                                : statusBayarData.map(
                                                    (StatusBayarData item) {
                                                    return item.nama;
                                                  }).toList(),
                                            onChange: (String selected) async {
                                              updateState(() {
                                                statusPembayaranSelected =
                                                    selected;
                                              });
                                            },
                                            constraints: BoxConstraints(
                                                maxHeight: 400, maxWidth: 400),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              statusPembayaranSelected,
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
                                    SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DateTimePicker(
                                            controller: _dateController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Dari Tanggal',
                                              suffixIcon:
                                                  Icon(Icons.date_range),
                                              isDense: true,
                                            ),
                                            // initialValue: date,
                                            type: DateTimePickerType.date,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                            dateLabelText: 'Tanggal',
                                            dateMask: 'yyyy-MM-dd',
                                            onChanged: (val) {
                                              print(val);
                                              print("CHANGED");
                                              // setState(() {
                                              //   date = val;
                                              // });
                                              _dateController.text = val;
                                              c.setTanggal(val);
                                            },
                                            validator: (val) {
                                              print(val);
                                              return null;
                                            },
                                            onSaved: (val) {
                                              print(val);
                                              print("SAVED");
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        // Clear
                                        InkWell(
                                          onTap: () {
                                            // Navigator.pop(context);
                                            c.setTanggal("");
                                            updateState(() {
                                              _dateController.text = "";
                                            });
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: DateTimePicker(
                                            controller: _dateToController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Sampai Tanggal',
                                              suffixIcon:
                                                  Icon(Icons.date_range),
                                              isDense: true,
                                            ),
                                            // initialValue: date,
                                            type: DateTimePickerType.date,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                            dateLabelText: 'Tanggal',
                                            dateMask: 'yyyy-MM-dd',
                                            onChanged: (val) {
                                              print(val);
                                              print("CHANGED");
                                              // setState(() {
                                              //   date = val;
                                              // });
                                              _dateToController.text = val;
                                              c.setTanggalTo(val);
                                            },
                                            validator: (val) {
                                              print(val);
                                              return null;
                                            },
                                            onSaved: (val) {
                                              print(val);
                                              print("SAVED");
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        // Clear
                                        InkWell(
                                          onTap: () {
                                            // Navigator.pop(context);
                                            c.setTanggalTo("");
                                            updateState(() {
                                              _dateToController.text = "";
                                            });
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    // Button Filter
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.purple,
                                          onPrimary: Colors.white,
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          if (statusPembayaranSelected ==
                                              "Pilih Status Pembayaran") {
                                            c.setStatusBayar("");
                                          } else {
                                            c.setStatusBayar(statusBayarData
                                                .where((element) =>
                                                    element.nama ==
                                                    statusPembayaranSelected)
                                                .first
                                                .id
                                                .toString());
                                          }
                                          if (salesmanFilterSelected ==
                                              "Pilih Salesman") {
                                            c.setSalesmanId("");
                                          } else {
                                            c.setSalesmanId(salesmanFilterData
                                                .where((element) =>
                                                    element.nama ==
                                                    salesmanFilterSelected)
                                                .first
                                                .id
                                                .toString());
                                          }
                                          // if (date.isEmpty) {
                                          //   c.setTanggal("");
                                          // } else {
                                          //   c.setTanggal(date);
                                          // }
                                          print("SALESMAN FILTER");
                                          print(c.salesmanId);
                                          setState(() {
                                            isUpdateTransaksi = true;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text("Filter"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        });
                  },
                ),
              ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _drawerHeader(id),
            _drawerItem(
              icon: Icons.shopping_basket,
              text: 'Transaksi Invoice',
              onTap: () async {
                // setState(() {
                //   activePage = "penjualan";
                // });
                print(c.isReload);
                print("BEFOREE");
                if (c.isReload) {
                  await EasyLoading.show(
                    status: 'Sedang memuat data...',
                    dismissOnTap: false,
                    maskType: EasyLoadingMaskType.black,
                  );
                  await futureProdukRes(
                          invoiceId: c.isEdit ? c.invoiceId : null)
                      .then((value) {
                    setState(() {
                      produkData = value.data;
                      produkDataOriginal = value.data;
                      isReset = true;
                    });
                    // context.loaderOverlay.hide();
                  });
                  if (EasyLoading.isShow) {
                    await EasyLoading.dismiss();
                  }
                }
                Navigator.pop(context);
                print("CLICKAGAIN");
                c.setActivePage("penjualan");
                c.cancelEdit();
                c.setSalesman("");
                c.setPelanggan("");
                c.setStatusBayar("");
                setState(() {
                  isBySearch = false;
                });
              },
              selected: c.activePage == "penjualan",
            ),
            _drawerItem(
              icon: Icons.note_alt,
              text: 'Laporan Penjualan',
              onTap: () {
                Navigator.pop(context);
                // setState(() {
                //   activePage = "transaksi";
                // });
                c.setActivePage("transaksi");
                c.cancelEdit();
                c.setSalesman("");
                c.setPelanggan("");
                c.setStatusBayar("");
                setState(() {
                  isBySearch = false;
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
