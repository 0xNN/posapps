import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posapps/models/check_stock.dart';
import 'package:posapps/models/invoice.dart';
import 'package:posapps/models/invoice_save.dart';
import 'package:posapps/models/pelanggan.dart';
import 'package:posapps/models/produk.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:namefully/namefully.dart';
import 'package:intl/intl.dart';
import 'package:posapps/models/salesman.dart';
import 'package:posapps/pages/bayar.dart';
import 'package:posapps/pages/models/bayar.dart';
import 'package:posapps/store/store.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:posapps/resources/string.dart';
import 'package:posapps/db/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }
}

class PenjualanPage extends StatefulWidget {
  final Function reload;
  static const String routeName = '/penjualan';
  final List<ProdukData> produkDatas;
  final bool reset;
  final bool bySearch;
  final Function refresh;
  const PenjualanPage(
      {Key key,
      this.produkDatas,
      this.reset,
      this.reload,
      this.bySearch,
      this.refresh})
      : super(key: key);

  @override
  State<PenjualanPage> createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage>
    with WidgetsBindingObserver {
  final c = Get.put(Controller());
  final CountdownController _controller = CountdownController(autoStart: true);
  DBHelper dbHelper = DBHelper();
  ProgressDialog pd = ProgressDialog(Get.context);

  double total = 0;
  int _totalDiskon = 0;

  bool isDraft = false;
  bool isBatal = false;

  List<ProdukData> produkDipilih = [];
  Set<ProdukData> produkDipilihSet = Set<ProdukData>();

  final Map<String, int> _subTotalPerItem = {};

  String penerimaanPembayaran = "";

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, int> _diskonNominal = {};
  final Map<String, double> _diskonPersen = {};

  Future<SalesmanRes> futureSalesmanRes() async {
    // await pd.show();
    String url = '${API_URL}PosApps/Salesman';
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      // await pd.hide();
      return SalesmanRes.fromMap(jsonDecode(response.body));
    } else {
      // await pd.hide();
      throw Exception('Failed to load Salesman');
    }
  }

  Future<PelangganRes> futurePelangganRes(String salesmanId) async {
    // await pd.show();
    String url = '${API_URL}PosApps/Pelanggan';
    print(salesmanId);
    if (salesmanId != null && salesmanId.isNotEmpty) {
      url = '${API_URL}PosApps/Pelanggan?SalesmanId=$salesmanId';
    }
    print(url);
    final response =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      print(response.body);
      // await pd.hide();
      return PelangganRes.fromMap(jsonDecode(response.body));
    } else {
      // await pd.hide();
      throw Exception('Failed to load Pelanggan');
    }
  }

  Future<InvoiceSaveRes> futureInvoiceSave(String userId) async {
    // await pd.show();

    String url = "${API_URL}PosApps/InvoiceSave";
    List<Map<String, dynamic>> invoiceDetail = [];
    for (var element in produkDipilihSet) {
      invoiceDetail.add({
        "RowUniqueId": element.rowUniqueId,
        "ProdukId": element.produkId,
        "Qty": 0.toString(),
        "Harga": element.hargaJual,
        "GudangId": element.gudangId,
        "DiskonNominal": 0.toString(),
        "NoSerial": element.noSerial,
        "TglKadaluarsa": element.expDate,
      });
    }
    for (var i = 0; i < produkDipilihSet.length; i++) {
      var element = produkDipilihSet.elementAt(i);
      invoiceDetail[i]["Qty"] = produkDipilih
          .where((element) =>
              element.rowUniqueId == produkDipilihSet.elementAt(i).rowUniqueId)
          .length
          .toString();
      invoiceDetail[i]["DiskonNominal"] =
          _diskonNominal[element.rowUniqueId] == null
              ? 0.toString()
              : _diskonNominal[element.rowUniqueId].toString();
    }

    int subTotal = _subTotalPerItem
        .map((key, value) {
          return MapEntry(key, value);
        })
        .values
        .fold(0, (previousValue, element) {
          return previousValue + element;
        });
    print(subTotal);
    Map<String, dynamic> body = {
      "SalesmanId": salesmanMap[salesmanSelected].id,
      "PelangganId": pelangganMap[pelangganSelected].id,
      "DiskonNominal": "0",
      "SubTotal": subTotal.toString(),
      "PPN": "0",
      "Pembulatan": "0",
      "NominalBayar": "0",
      "RekeningId": "",
      "IsStatusInvoice": "DRAFT",
      "StatusLunas": "0",
      "InvoiceId": c.isEdit ? c.invoiceId : "",
      "UserId": userId,
      "InvoiceDetail": jsonEncode(invoiceDetail),
    };
    print(body);
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      // await pd.hide();
      return InvoiceSaveRes.fromMap(jsonDecode(response.body));
    } else {
      // await pd.hide();
      throw Exception('Failed to load data');
    }
  }

  List<SalesmanData> salesmanData;
  Map<String, SalesmanData> salesmanMap = {};
  Map<String, SalesmanData> salesmanMapId = {};
  List<PelangganData> pelangganData;
  Map<String, PelangganData> pelangganMap = {};
  ListInvoice invoiceData;

  String salesmanSelected = "Pilih Salesman";
  String pelangganSelected = "Pilih Customer";

  bool isSalesmanLoad = false;
  bool isPelangganLoad = false;

  bool isPause = false;
  Map<String, ProdukData> produkDataMap = {};

  Future<void> _navigateAndDisplayResult(BuildContext context) async {
    List<Map<String, dynamic>> invoiceDetail = [];
    for (var element in produkDipilihSet) {
      invoiceDetail.add({
        "RowUniqueId": element.rowUniqueId,
        "ProdukId": element.produkId,
        "Qty": 0.toString(),
        "Harga": element.hargaJual,
        "GudangId": element.gudangId,
        "DiskonNominal": 0.toString(),
        "NoSerial": element.noSerial,
        "TglKadaluarsa": element.expDate,
      });
    }
    for (var i = 0; i < produkDipilihSet.length; i++) {
      var element = produkDipilihSet.elementAt(i);
      invoiceDetail[i]["Qty"] = produkDipilih
          .where((element) =>
              element.rowUniqueId == produkDipilihSet.elementAt(i).rowUniqueId)
          .length
          .toString();
      invoiceDetail[i]["DiskonNominal"] =
          _diskonNominal[element.rowUniqueId] == null
              ? 0.toString()
              : _diskonNominal[element.rowUniqueId].toString();
    }
    print("Total");
    print(
      _subTotalPerItem
          .map((key, value) {
            return MapEntry(key, value);
          })
          .values
          .fold(
            0,
            (previousValue, element) {
              return previousValue + element;
            },
          )
          .toString(),
    );
    c.setActiveBayar(true);
    final result = await Navigator.pushNamed(
      context,
      BayarPage.routeName,
      arguments: ProdukDatasArgs(
        produkDipilih,
        produkDipilihSet,
        // total,
        _subTotalPerItem
            .map((key, value) {
              return MapEntry(key, value);
            })
            .values
            .fold(
              0,
              (previousValue, element) {
                return previousValue + element;
              },
            ),
        _totalDiskon,
        salesmanMap[salesmanSelected].id,
        pelangganMap[pelangganSelected].id,
        jsonEncode(invoiceDetail),
      ),
    );

    if (!mounted) return;

    if (result == null) return;
    if (result == "cancel") {
      print("RESULT");
      print(result);
      setState(() {
        penerimaanPembayaran = "Pembayaran Batal";
        produkDipilih.clear();
        produkDipilihSet.clear();
        _subTotalPerItem.clear();
        _totalDiskon = 0;
        _diskonNominal.clear();
        _diskonPersen.clear();
        total = 0;
        _controllers.forEach((key, value) {
          value.text = "";
        });
        isPause = false;
        salesmanSelected = "Pilih Salesman";
        pelangganSelected = "Pilih Customer";
      });
      _controller.restart();
    } else {
      print("RESULT");
      print(result);
      setState(() {
        penerimaanPembayaran = "Pembayaran Selesai";
        produkDipilih.clear();
        produkDipilihSet.clear();
        _subTotalPerItem.clear();
        _totalDiskon = 0;
        _diskonNominal.clear();
        _diskonPersen.clear();
        total = 0;
        _controllers.forEach((key, value) {
          value.text = "";
        });
        isPause = false;
        salesmanSelected = "Pilih Salesman";
        pelangganSelected = "Pilih Customer";
      });
      _controller.restart();
      c.setActivePage("transaksi");
      // c.setReload(false);
      c.setTanggal(DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()));
    }
    widget.refresh();
  }

  Future<InvoiceRes> futureInvoice(String id) async {
    // await pd.show();
    String url = '${API_URL}PosApps/Invoice';
    print(url);
    Map<String, dynamic> body = {
      "InvoiceId": id ?? "",
      "Status": "",
      "StatusLunas": "",
    };
    print(body);
    url = url + '?' + Uri(queryParameters: body).query;
    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      print(response.body);
      // await pd.hide();
      return InvoiceRes.fromMap(jsonDecode(response.body));
    } else {
      // await pd.hide();
      throw Exception('Failed to load invoice');
    }
  }

  Future<ProdukRes> futureProdukFromEditRes(String id,
      {String invoiceId}) async {
    // await pd.show();
    String url = '${API_URL}PosApps/Produk';
    print(url);
    Map<String, dynamic> body = {
      "ProdukId": id ?? "",
      "PelangganId": "",
      "SubKategoriId": "",
      "InvoiceId": invoiceId ?? "",
    };
    print(body);
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      // await pd.hide();
      return ProdukRes.fromMap(jsonDecode(response.body));
    } else {
      // await pd.hide();
      throw Exception('Failed to load Produk');
    }
  }

  Future<CheckStockRes> futureCheckStock() async {
    // await pd.show();
    String url = '${API_URL}PosApps/CheckStok';
    print(url);
    List<Map<String, dynamic>> invoiceDetail = [];
    for (var element in produkDipilihSet) {
      invoiceDetail.add({
        "RowUniqueId": element.rowUniqueId,
        "ProdukId": element.produkId,
        "Qty": 0.toString(),
        "Harga": element.hargaJual,
        "GudangId": element.gudangId,
        "DiskonNominal": 0.toString(),
        "NoSerial": element.noSerial,
        "TglKadaluarsa": element.expDate,
      });
    }
    for (var i = 0; i < produkDipilihSet.length; i++) {
      var element = produkDipilihSet.elementAt(i);
      invoiceDetail[i]["Qty"] = produkDipilih
          .where((element) =>
              element.rowUniqueId == produkDipilihSet.elementAt(i).rowUniqueId)
          .length
          .toString();
      invoiceDetail[i]["DiskonNominal"] =
          _diskonNominal[element.rowUniqueId] == null
              ? 0.toString()
              : _diskonNominal[element.rowUniqueId].toString();
    }
    Map<String, dynamic> body = {
      "InvoiceId": c.isEdit ? c.invoiceId : "",
      "InvoiceDetail": jsonEncode(invoiceDetail),
    };
    print(body);
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      // await pd.hide();
      return CheckStockRes.fromMap(jsonDecode(response.body));
    } else {
      // await pd.hide();
      throw Exception('Failed to load Produk');
    }
  }

  @override
  void initState() {
    pd = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: true);
    setState(() {
      for (ProdukData element in widget.produkDatas) {
        _controllers[element.rowUniqueId] = TextEditingController(text: "");
        _diskonNominal[element.rowUniqueId] = 0;
        _diskonPersen[element.rowUniqueId] = 0.0;
      }
      produkDipilih.clear();
      produkDipilihSet.clear();
      total = 0;
    });

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
      await futurePelangganRes(null).then((value) {
        if (MODE != "api") {
          if (value != null) {
            for (PelangganData data in value.data) {
              dbHelper.insertPelanggan(data);
            }
          }
          dbHelper.pelanggans().then((value) {
            for (PelangganData element in value) {
              pelangganMap[element.nama] = element;
            }
            setState(() {
              pelangganData = value;
            });
          });
        } else {
          if (value != null) {
            for (PelangganData data in value.data) {
              pelangganMap[data.nama] = data;
            }
            if (mounted) {
              setState(() {
                pelangganData = value.data;
              });
            }
          }
        }
      }).onError((error, stackTrace) {
        print(error);
        print(stackTrace);
      });
    }).onError((error, stackTrace) {
      print(error);
      print(stackTrace);
    });
    if (c.isEdit) {
      print("INIT");
      futureInvoice(c.invoiceId).then((value) {
        setState(() {
          invoiceData = value.data.listInvoice[0];
          salesmanSelected = invoiceData.salesman;
          pelangganSelected = invoiceData.pelanggan;
        });
        for (DetailInvoice element in invoiceData.detailInvoice) {
          futureProdukFromEditRes(element.produkId,
                  invoiceId: c.isEdit ? c.invoiceId : null)
              .then((v) async {
            if (value != null) {
              if (MODE != "api") {
                for (ProdukData produk in v.data) {
                  await dbHelper.insertProduk(produk);
                }
              } else {
                if (v.data.isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      produkDipilih.add(v.data[0]);
                      // produkDipilihSet.add(v.data[0]);
                      produkDipilihSet.where((e) {
                        if (e.rowUniqueId == v.data[0].rowUniqueId &&
                            e.produkId == v.data[0].produkId) {
                          return true;
                        } else {
                          return false;
                        }
                      }).isEmpty
                          ? produkDipilihSet.add(v.data[0])
                          : null;
                      total += double.parse(v.data[0].hargaJual);
                      for (var e in produkDipilihSet) {
                        int produkLength = produkDipilih
                            .where((element) =>
                                element.produkId == e.produkId &&
                                element.rowUniqueId == e.rowUniqueId)
                            .toList()
                            .length;
                        _subTotalPerItem[e.rowUniqueId] =
                            produkLength * int.parse(e.hargaJual);
                        print(_subTotalPerItem[e.rowUniqueId]);
                      }
                      _controller.pause();
                      isPause = true;
                    });
                  }
                }
              }
              if (MODE != "api") {
                await dbHelper.produks().then((value) {
                  setState(() {
                    produkDipilih.addAll(value);
                    produkDipilihSet.addAll(value);
                  });
                });
              }
            }
          }).catchError((error) {
            print("ERROR: $error");
          });
        }
      }).onError((error, stackTrace) {
        print(error);
        print(stackTrace);
      });
    }
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print("DISPOSE");
    for (ProdukData element in widget.produkDatas) {
      if (_controllers[element.rowUniqueId] != null) {
        _controllers[element.rowUniqueId].dispose();
      }
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    print("DEACTIVATE");
    super.deactivate();
  }

  @override
  void didUpdateWidget(PenjualanPage oldWidget) {
    print("UPDATE");
    print(c.invoiceId);

    if (c.salesman.isNotEmpty) {
      print("SALESMAN STATE");
      print(c.salesman);
      print(c.pelanggan);
      setState(() {
        salesmanSelected = c.salesman.string;
        pelangganSelected = c.pelanggan.string;
      });
    }
    if (!c.isReload) {
      _controller.restart();
    } else {
      print("MASUK RELOADDDDDD");
      widget.reload();
    }
    if (oldWidget.reset) {
      // if (widget.bySearch) {
      //   print("MASUK BY SEARCH TRUE 1");
      // } else {
      // }
      print("IS ACTIVE BAYAR");
      print(c.isActiveBayar);
      if (!c.isActiveBayar) {
        if (!widget.bySearch) {
          if (c.isResetProduk) {
            print("MASUK BY SEARCH 1 WIDGET RESET TRUE");
            setState(() {
              for (ProdukData element in widget.produkDatas) {
                _controllers[element.rowUniqueId] =
                    TextEditingController(text: "");
                _diskonNominal[element.rowUniqueId] = 0;
                _diskonPersen[element.rowUniqueId] = 0.0;
              }
              produkDipilih.clear();
              produkDipilihSet.clear();
              total = 0;
              _subTotalPerItem.clear();
              isPause = false;
            });
            _controller.restart();
          }
        }
      }
    }
    //  else {
    //   if (widget.bySearch) {
    //     print("MASUK BY SEARCH TRUE 2");
    //   } else {
    //     print("MASUK BY SEARCH FALSE 2");
    //     // setState(() {
    //     //   for (ProdukData element in widget.produkDatas) {
    //     //     _controllers[element.rowUniqueId] = TextEditingController(text: "");
    //     //     _diskonNominal[element.rowUniqueId] = 0;
    //     //     _diskonPersen[element.rowUniqueId] = 0.0;
    //     //   }
    //     //   produkDipilih.clear();
    //     //   produkDipilihSet.clear();
    //     //   total = 0;
    //     //   _subTotalPerItem.clear();
    //     // });
    //   }
    // }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: widget.produkDatas.isNotEmpty
                ? Column(
                    children: [
                      isPause
                          ? Container()
                          : SizedBox(
                              height: 30,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Data produk otomatis diperbarui dalam",
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Countdown(
                                      controller: _controller,
                                      seconds: 10,
                                      build: (_, double time) => Text(
                                        time.toInt().toString() + " detik",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      interval: Duration(seconds: 1),
                                      onFinished: () async {
                                        // setState(() {
                                        //   produkDipilih.clear();
                                        //   produkDipilihSet.clear();
                                        //   total = 0;
                                        //   _subTotalPerItem.clear();
                                        // });
                                        c.setReload(true);
                                        widget.reload();
                                        // _controller.restart();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      Expanded(
                        child: AlignedGridView.count(
                          crossAxisCount: 1,
                          mainAxisSpacing: 0.0,
                          crossAxisSpacing: 0.0,
                          itemCount: widget.produkDatas.length,
                          itemBuilder: (context, index) {
                            // var name = Namefully(widget.produkDatas[index].produk);
                            // String initialName = name.initials().join();
                            return InkWell(
                              onTap: () {
                                _controller.pause();
                                c.setReload(false);
                                c.setResetProduk(false);
                                setState(() {
                                  isPause = true;
                                });
                                int stok =
                                    int.parse(widget.produkDatas[index].stok);
                                if (stok > 0) {
                                  // cek apakah produk di list melebihi stok
                                  int count = 0;
                                  for (ProdukData data in produkDipilih) {
                                    if (data.rowUniqueId ==
                                        widget.produkDatas[index].rowUniqueId) {
                                      count++;
                                    }
                                  }
                                  if (count < stok) {
                                    setState(() {
                                      produkDipilih
                                          .add(widget.produkDatas[index]);
                                      // Cek if exists then add to produkDipilihSet
                                      produkDipilihSet.where((element) {
                                        if (element.rowUniqueId ==
                                                widget.produkDatas[index]
                                                    .rowUniqueId &&
                                            element.produkId ==
                                                widget.produkDatas[index]
                                                    .produkId) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      }).isEmpty
                                          ? produkDipilihSet
                                              .add(widget.produkDatas[index])
                                          : null;
                                      // produkDipilihSet
                                      //     .add(widget.produkDatas[index]);
                                      total += double.parse(
                                          widget.produkDatas[index].hargaJual);
                                      for (var e in produkDipilihSet) {
                                        int produkLength = produkDipilih
                                            .where((element) =>
                                                element.produkId ==
                                                    e.produkId &&
                                                element.rowUniqueId ==
                                                    e.rowUniqueId)
                                            .toList()
                                            .length;
                                        _subTotalPerItem[e.rowUniqueId] =
                                            produkLength *
                                                int.parse(e.hargaJual);
                                        print(_subTotalPerItem[e.rowUniqueId]);
                                      }
                                    });
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Informasi Stok"),
                                            content: Text(
                                              "Stok produk tidak boleh lebih dari $stok",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("OK"),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                  // setState(() {
                                  //   produkDipilih.add(widget.produkDatas[index]);
                                  //   produkDipilihSet.add(widget.produkDatas[index]);
                                  //   total += double.parse(
                                  //       widget.produkDatas[index].hargaJual);
                                  // });
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("Informasi Stok"),
                                          content: Text(
                                            "Stok produk tidak tersedia",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      });
                                }
                                print("PRODUK DIPILIH SET");
                                print(produkDipilihSet.length);
                                print(produkDipilihSet);
                                for (var element in produkDipilihSet) {
                                  print(element.produk +
                                      " " +
                                      element.rowUniqueId +
                                      " " +
                                      element.produkId);
                                }
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: 30,
                                margin: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(
                                    color: Colors.blue[200],
                                    width: .5,
                                  ),
                                  // gradient: LinearGradient(
                                  //   begin: Alignment.topLeft,
                                  //   end: Alignment.bottomRight,
                                  //   colors: [
                                  //     Colors.white,
                                  //     Colors.blue[50],
                                  //   ],
                                  // ),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.blue.withOpacity(0.2),
                                  //     spreadRadius: 1,
                                  //     blurRadius: 2,
                                  //     offset:
                                  //         Offset(0, 1), // changes position of shadow
                                  //   ),
                                  // ],
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.only(
                                              top: 8.0,
                                              left: 8.0,
                                              bottom: 8.0,
                                              right: 14.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  widget
                                                      .produkDatas[index].produk
                                                      .toUpperCase(),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Text(
                                                  "S/N : ${widget.produkDatas[index].noSerial ?? "-"}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.indigo[400],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 4.0),
                                                Text(
                                                  "Stok : ${widget.produkDatas[index].stok}",
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.indigo[400],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Container(
                                        //   // height: 20,
                                        //   width: double.infinity,
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.indigo[50],
                                        //     borderRadius: BorderRadius.only(
                                        //         // topRight: Radius.circular(4.0),
                                        //         ),
                                        //   ),
                                        //   padding: EdgeInsets.all(4.0),
                                        //   child: Text(
                                        //     "S/N : ${widget.produkDatas[index].noSerial ?? "-"}",
                                        //     textAlign: TextAlign.center,
                                        //     style: TextStyle(
                                        //       fontSize: 12.0,
                                        //       color: Colors.indigo[400],
                                        //       fontWeight: FontWeight.bold,
                                        //     ),
                                        //   ),
                                        // ),
                                        // Container(
                                        //   width: double.infinity,
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.blue.shade200,
                                        //     borderRadius: BorderRadius.only(
                                        //       bottomLeft: Radius.circular(8.0),
                                        //       bottomRight: Radius.circular(8.0),
                                        //     ),
                                        //   ),
                                        //   padding: EdgeInsets.all(4.0),
                                        //   child: Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.center,
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.center,
                                        //     children: [
                                        //       Text(
                                        //         "Stok : ${widget.produkDatas[index].stok}",
                                        //         textAlign: TextAlign.center,
                                        //         softWrap: true,
                                        //         overflow: TextOverflow.ellipsis,
                                        //         style: TextStyle(
                                        //           fontSize: 12.0,
                                        //           color: Colors.white,
                                        //           fontWeight: FontWeight.bold,
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        height: 16,
                                        width: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.indigo[400],
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    child: Center(
                      child: Image.asset(
                        "images/no-data-found.png",
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0.0),
                border: Border.all(
                  color: Colors.grey[200],
                  width: 1.0,
                ),
              ),
              width: double.infinity,
              // height: double.infinity,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  produkDipilihSet.isEmpty
                      ? Expanded(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 50,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  "Keranjang Kosong",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey[300],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: ListView.builder(
                              itemCount: produkDipilihSet.length,
                              itemBuilder: (context, index) {
                                int produkLength = produkDipilih
                                    .where((element) =>
                                        element.produkId ==
                                            produkDipilihSet
                                                .elementAt(index)
                                                .produkId &&
                                        element.rowUniqueId ==
                                            produkDipilihSet
                                                .elementAt(index)
                                                .rowUniqueId)
                                    .toList()
                                    .length;
                                return AnimatedContainer(
                                    duration: Duration(milliseconds: 100),
                                    curve: Curves.easeInOut,
                                    margin: EdgeInsets.only(bottom: 4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                        color: Colors.grey[300],
                                        width: 1.0,
                                      ),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      isThreeLine: false,
                                      title: Text(
                                        produkDipilihSet
                                            .elementAt(index)
                                            .produk,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "$produkLength",
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.pink,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                " x " +
                                                    CurrencyFormat.convertToIdr(
                                                        int.parse(
                                                            produkDipilihSet
                                                                .elementAt(
                                                                    index)
                                                                .hargaJual),
                                                        0),
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              // total
                                              produkDipilihSet
                                                      .elementAt(index)
                                                      .hargaJual
                                                      .isEmpty
                                                  ? Container()
                                                  : Text(
                                                      " = " +
                                                          // CurrencyFormat.convertToIdr(
                                                          //     (int.parse(produkDipilihSet
                                                          //                 .elementAt(
                                                          //                     index)
                                                          //                 .hargaJual) -
                                                          //             _diskonNominal[
                                                          //                 produkDipilihSet
                                                          //                     .elementAt(
                                                          //                         index)
                                                          //                     .rowUniqueId]) *
                                                          //         produkLength,
                                                          //     0),

                                                          CurrencyFormat.convertToIdr(
                                                              produkLength *
                                                                  int.parse(produkDipilihSet
                                                                      .elementAt(
                                                                          index)
                                                                      .hargaJual),
                                                              0),
                                                      style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors
                                                            .blue.shade800,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    )
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: InkWell(
                                        onTap: () {
                                          setState(() {
                                            total -= double.parse(
                                                produkDipilihSet
                                                    .elementAt(index)
                                                    .hargaJual);
                                            List<ProdukData> produkLength =
                                                produkDipilih
                                                    .where((element) =>
                                                        element.produkId ==
                                                            produkDipilihSet
                                                                .elementAt(
                                                                    index)
                                                                .produkId &&
                                                        element.rowUniqueId ==
                                                            produkDipilihSet
                                                                .elementAt(
                                                                    index)
                                                                .rowUniqueId)
                                                    .toList();
                                            if (produkLength.length == 1) {
                                              print("MASUK == 1");
                                              if (_diskonNominal[produkDipilih
                                                      .elementAt(index)
                                                      .rowUniqueId] !=
                                                  null) {
                                                _totalDiskon -= _diskonNominal[
                                                    produkDipilih
                                                        .elementAt(index)
                                                        .rowUniqueId];
                                              } else {
                                                _totalDiskon -= 0;
                                              }
                                              _diskonNominal[produkDipilihSet
                                                  .elementAt(index)
                                                  .rowUniqueId] = 0;
                                              _diskonPersen[produkDipilihSet
                                                  .elementAt(index)
                                                  .rowUniqueId] = 0;
                                              // _controllers[produkDipilihSet
                                              //         .elementAt(index)
                                              //         .rowUniqueId]
                                              //     .value = TextEditingValue(
                                              //   text: "",
                                              // );

                                              int produkLengthNew =
                                                  produkDipilih
                                                      .where((element) =>
                                                          element.produkId ==
                                                              produkDipilihSet
                                                                  .elementAt(
                                                                      index)
                                                                  .produkId &&
                                                          element.rowUniqueId ==
                                                              produkDipilihSet
                                                                  .elementAt(
                                                                      index)
                                                                  .rowUniqueId)
                                                      .toList()
                                                      .length;

                                              _subTotalPerItem[produkDipilihSet
                                                      .elementAt(index)
                                                      .rowUniqueId] =
                                                  produkLengthNew *
                                                      int.parse(produkDipilihSet
                                                          .elementAt(index)
                                                          .hargaJual);

                                              _subTotalPerItem[produkDipilihSet
                                                      .elementAt(index)
                                                      .rowUniqueId] -=
                                                  int.parse(produkDipilihSet
                                                      .elementAt(index)
                                                      .hargaJual);

                                              produkDipilih.removeWhere(
                                                  (element) =>
                                                      element.produkId ==
                                                          produkDipilihSet
                                                              .elementAt(index)
                                                              .produkId &&
                                                      element.rowUniqueId ==
                                                          produkDipilihSet
                                                              .elementAt(index)
                                                              .rowUniqueId);
                                              produkDipilihSet.removeWhere(
                                                  (element) =>
                                                      element.produkId ==
                                                          produkDipilihSet
                                                              .elementAt(index)
                                                              .produkId &&
                                                      element.rowUniqueId ==
                                                          produkDipilihSet
                                                              .elementAt(index)
                                                              .rowUniqueId);
                                            } else {
                                              print("MASUK > 1");
                                              _subTotalPerItem[produkDipilihSet
                                                      .elementAt(index)
                                                      .rowUniqueId] -=
                                                  int.parse(produkDipilihSet
                                                      .elementAt(index)
                                                      .hargaJual);
                                              produkDipilih.removeWhere(
                                                  (element) =>
                                                      element.produkId ==
                                                          produkDipilihSet
                                                              .elementAt(index)
                                                              .produkId &&
                                                      element.rowUniqueId ==
                                                          produkDipilihSet
                                                              .elementAt(index)
                                                              .rowUniqueId);
                                              for (var i = produkLength.length;
                                                  i > 1;
                                                  i--) {
                                                produkDipilih.add(
                                                    produkDipilihSet
                                                        .elementAt(index));
                                              }
                                            }
                                          });
                                          if (produkDipilih.isEmpty) {
                                            c.setReload(false);
                                            c.setResetProduk(true);
                                            setState(() {
                                              isPause = false;
                                            });
                                            _controller.restart();
                                          }
                                        },
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.red[400],
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ));
                              },
                            ),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Pilih Salesman
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
                                  selectedValue: salesmanSelected,
                                  searchBoxDecoration: InputDecoration(
                                    hintText: "Cari Salesman",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  items: salesmanData == null
                                      ? []
                                      : salesmanData.map((SalesmanData item) {
                                          return item.nama;
                                        }).toList(),
                                  onChange: (String selected) async {
                                    setState(() {
                                      salesmanSelected = selected;
                                      isPelangganLoad = true;
                                    });
                                    await futurePelangganRes(
                                            salesmanMap[selected].id)
                                        .then((value) async {
                                      if (MODE != "api") {
                                        if (value != null) {
                                          for (PelangganData data
                                              in value.data) {
                                            await dbHelper
                                                .insertPelanggan(data);
                                          }
                                        }
                                        await dbHelper
                                            .pelanggans()
                                            .then((value) {
                                          setState(() {
                                            pelangganData = value;
                                            pelangganSelected =
                                                "Pilih Customer";
                                            isPelangganLoad = false;
                                          });
                                        }).catchError((error) {
                                          print(error);
                                          setState(() {
                                            pelangganData = null;
                                            pelangganSelected =
                                                "Pilih Customer";
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          pelangganData = value.data;
                                          pelangganSelected = "Pilih Customer";
                                          isPelangganLoad = false;
                                        });
                                      }
                                    }).onError((error, stackTrace) {
                                      print(error);
                                      print(stackTrace);
                                      setState(() {
                                        pelangganData = null;
                                        pelangganSelected = "Pilih Customer";
                                        isPelangganLoad = false;
                                      });
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
                          SizedBox(width: 10),
                          // Pilih Pelanggan
                          Container(
                            decoration: BoxDecoration(
                              color: isPelangganLoad
                                  ? Colors.grey
                                  : Colors.blue.shade300,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.all(4),
                            child: InkWell(
                              onTap: isPelangganLoad
                                  ? null
                                  : () {
                                      SelectDialog.showModal<String>(
                                        context,
                                        label: "List Pelanggan",
                                        selectedValue: pelangganSelected,
                                        searchBoxDecoration: InputDecoration(
                                          hintText: "Cari Pelanggan",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                        items: pelangganData == null
                                            ? []
                                            : pelangganData
                                                .map((PelangganData item) {
                                                return item.nama;
                                              }).toList(),
                                        onChange: (String selected) {
                                          setState(() {
                                            pelangganSelected = selected;
                                          });
                                          print(pelangganSelected);
                                          print(selected);
                                          String salesmanId = "";
                                          bool isSalesmanSet = false;
                                          for (var element in pelangganData) {
                                            if (element.nama ==
                                                pelangganSelected) {
                                              salesmanId = element.pegawaiId;
                                            }
                                          }
                                          for (var element in salesmanData) {
                                            if (element.id == salesmanId) {
                                              print(element.id);
                                              print(element.nama);
                                              setState(() {
                                                salesmanSelected = element.nama;
                                              });
                                              isSalesmanSet = true;
                                            }
                                          }
                                          if (!isSalesmanSet) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    "Salesman tidak ditemukan"),
                                              ),
                                            );
                                          }
                                        },
                                        constraints: BoxConstraints(
                                            maxHeight: 400, maxWidth: 400),
                                      );
                                    },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isPelangganLoad
                                        ? "Loading"
                                        : pelangganSelected,
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
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: Row(
                      mainAxisAlignment: produkDipilih.isNotEmpty
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.end,
                      children: [
                        // if (produkDipilih.isNotEmpty)
                        //   Text(
                        //     penerimaanPembayaran,
                        //     style:
                        //         TextStyle(fontSize: 16.0, color: Colors.green),
                        //   ),
                        Text(
                          CurrencyFormat.convertToIdr(
                              _subTotalPerItem
                                  .map((key, value) {
                                    return MapEntry(key, value);
                                  })
                                  .values
                                  .fold(0, (previousValue, element) {
                                    return previousValue + element;
                                  }),
                              0),
                          style: TextStyle(
                            fontSize: 16.0,
                            color: produkDipilih.isNotEmpty
                                ? Colors.blue
                                : Colors.green,
                          ),
                        ),
                        // Text(
                        //   " ( Diskon -${CurrencyFormat.convertToIdr(_totalDiskon, 0)} )",
                        //   style: TextStyle(
                        //     fontSize: 12.0,
                        //     color: Colors.pink,
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Center(
                              child: Icon(Icons.more_vert, color: Colors.blue),
                            ),
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  side: BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  // barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                        builder: (context, updateState) {
                                      return AlertDialog(
                                        title: Text("Pilih Aksi"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              child: isDraft
                                                  ? Text("LOADING")
                                                  : Text("SIMPAN DRAFT"),
                                              style: ElevatedButton.styleFrom(
                                                primary: isDraft
                                                    ? Colors.grey
                                                    : Colors.blue,
                                                onPrimary: isDraft
                                                    ? Colors.black
                                                    : Colors.white,
                                                elevation: 0,
                                              ),
                                              onPressed: isDraft
                                                  ? null
                                                  : () async {
                                                      // _navigateAndDisplayResult(
                                                      //     context);
                                                      final SharedPreferences
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      String userId = prefs
                                                          .getString("user_id");
                                                      if (userId == null) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                "User belum dipilih"),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      await futureCheckStock()
                                                          .then((val) async {
                                                        if (val.success) {
                                                          updateState(() {
                                                            isDraft = true;
                                                          });
                                                          await futureInvoiceSave(
                                                                  userId)
                                                              .then((value) {
                                                            if (value != null) {
                                                              if (value
                                                                  .success) {
                                                                updateState(() {
                                                                  isDraft =
                                                                      false;
                                                                });
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                        value
                                                                            .message),
                                                                  ),
                                                                );
                                                                c.cancelEdit();
                                                                c.setSalesman(
                                                                    "");
                                                                c.setPelanggan(
                                                                    "");
                                                                c.setStatusBayar(
                                                                    "");
                                                                setState(() {
                                                                  isPause =
                                                                      false;
                                                                  produkDipilih
                                                                      .clear();
                                                                  produkDipilihSet
                                                                      .clear();
                                                                  _subTotalPerItem
                                                                      .clear();
                                                                  _totalDiskon =
                                                                      0;
                                                                  _diskonNominal
                                                                      .clear();
                                                                  _diskonPersen
                                                                      .clear();
                                                                  total = 0;
                                                                  _controllers
                                                                      .forEach((key,
                                                                          value) {
                                                                    value.text =
                                                                        "";
                                                                  });
                                                                  salesmanSelected =
                                                                      "Pilih Salesman";
                                                                  pelangganSelected =
                                                                      "Pilih Pelanggan";
                                                                });
                                                                _controller
                                                                    .restart();
                                                                c.setReload(
                                                                    true);
                                                                widget.reload();
                                                              } else {
                                                                updateState(() {
                                                                  isDraft =
                                                                      false;
                                                                });
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                        value
                                                                            .message),
                                                                  ),
                                                                );
                                                              }
                                                            } else {
                                                              updateState(() {
                                                                isDraft = false;
                                                              });
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      "Terjadi kesalahan"),
                                                                ),
                                                              );
                                                            }
                                                          }).catchError(
                                                                  (onError) {
                                                            updateState(() {
                                                              isDraft = false;
                                                            });
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    "Terjadi kesalahan"),
                                                              ),
                                                            );
                                                          });
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                val.message,
                                                              ),
                                                            ),
                                                          );
                                                          // c.cancelEdit();
                                                          // setState(() {
                                                          //   produkDipilih
                                                          //       .clear();
                                                          //   produkDipilihSet
                                                          //       .clear();
                                                          //   _subTotalPerItem
                                                          //       .clear();
                                                          //   _totalDiskon = 0;
                                                          //   _diskonNominal
                                                          //       .clear();
                                                          //   _diskonPersen
                                                          //       .clear();
                                                          //   total = 0;
                                                          //   _controllers
                                                          //       .forEach((key,
                                                          //           value) {
                                                          //     value.text = "";
                                                          //   });
                                                          // });
                                                        }
                                                      }).onError(
                                                        (error, stackTrace) {
                                                          print(error);
                                                          print(stackTrace);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(error
                                                                  .toString()),
                                                            ),
                                                          );
                                                          c.setReload(true);
                                                        },
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                            ),
                                            ElevatedButton(
                                              child: Text("BATALKAN TRANSAKSI"),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                                onPrimary: Colors.white,
                                                elevation: 0,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                c.setReload(true);
                                                if (c.isEdit) {
                                                  c.cancelEdit();
                                                  c.setSalesman("");
                                                  c.setPelanggan("");
                                                  c.setStatusBayar("");
                                                }
                                                setState(() {
                                                  produkDipilih.clear();
                                                  produkDipilihSet.clear();
                                                  _subTotalPerItem.clear();
                                                  _totalDiskon = 0;
                                                  _diskonNominal.clear();
                                                  _diskonPersen.clear();
                                                  total = 0;
                                                  _controllers
                                                      .forEach((key, value) {
                                                    value.text = "";
                                                  });
                                                  isPause = false;
                                                  salesmanSelected =
                                                      "Pilih Salesman";
                                                  pelangganSelected =
                                                      "Pilih Customer";
                                                });
                                                _controller.restart();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  });
                            },
                          ),
                        ),
                        // ElevatedButton.icon(
                        //   icon: Icon(Icons.add),
                        //   label: Text("Tambah Produk"),
                        //   style: ElevatedButton.styleFrom(
                        //     primary: salesmanSelected != "Pilih Salesman" &&
                        //             pelangganSelected != "Pilih Customer" &&
                        //             total > 0
                        //         ? Colors.indigo[400]
                        //         : Colors.grey[400],
                        //     onPrimary: Colors.white,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(4.0),
                        //     ),
                        //     minimumSize: Size.fromHeight(40.0),
                        //   ),
                        //   onPressed: salesmanSelected != "Pilih Salesman" &&
                        //           pelangganSelected != "Pilih Customer" &&
                        //           total > 0
                        //       ? () {
                        //           _navigateAndDisplayResult(context);
                        //         }
                        //       : null,
                        // ),
                        SizedBox(width: 5),
                        Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: salesmanSelected != "Pilih Salesman" &&
                                      pelangganSelected != "Pilih Customer" &&
                                      total > 0
                                  ? Colors.indigo[400]
                                  : Colors.grey[400],
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              minimumSize: Size.fromHeight(40.0),
                            ),
                            onPressed: salesmanSelected != "Pilih Salesman" &&
                                    pelangganSelected != "Pilih Customer" &&
                                    total > 0
                                ? () {
                                    futureCheckStock().then((val) async {
                                      if (val.success) {
                                        _navigateAndDisplayResult(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              val.message,
                                            ),
                                          ),
                                        );
                                      }
                                    }).onError((error, stackTrace) {
                                      print(error);
                                      print(stackTrace);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(error.toString()),
                                        ),
                                      );
                                    });
                                  }
                                : null,
                            child: Text("BAYAR"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
