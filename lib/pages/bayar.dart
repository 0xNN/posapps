import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posapps/models/invoice_save.dart';
import 'package:posapps/models/metode_bayar.dart';
import 'package:posapps/models/produk.dart';
import 'package:posapps/models/send_wa.dart';
import 'package:posapps/pages/models/bayar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:posapps/resources/string.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:posapps/store/store.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class BayarPage extends StatefulWidget {
  static const String routeName = '/bayar';
  final ProdukDatasArgs args;
  const BayarPage({Key key, this.args}) : super(key: key);

  @override
  State<BayarPage> createState() => _BayarPageState();
}

class _BayarPageState extends State<BayarPage> {
  final c = Get.put(Controller());
  int total = 0;
  int penerimaanTunai = 0;

  bool isLunas = false;
  bool isPublish = false;
  bool isPpn = false;

  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textDiskonController =
      TextEditingController(text: "");
  final TextEditingController _textPersentaseController =
      TextEditingController(text: "");
  final TextEditingController _textPembulatanController =
      TextEditingController(text: "");
  final TextEditingController _textPembayaranController =
      TextEditingController(text: "");

  final TextEditingController _noWaController = TextEditingController(text: '');

  int totalHarga = 0;
  int totalSetelahDiskon = 0;
  int ppn = 0;

  Timer countdownTimer;
  Duration myDuration = Duration(seconds: 5);

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer.cancel();
        Navigator.of(context).pop(
          BayarDatasArgs(
            widget.args.totalHarga,
            total,
            total - widget.args.totalHarga.toInt(),
          ),
        );
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
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

  Future<InvoiceSaveRes> futureInvoiceSave(bool isDraft, String userId) async {
    String url = "${API_URL}PosApps/InvoiceSave";
    Map<String, dynamic> body = {
      "SalesmanId": widget.args.salesmanId,
      "PelangganId": widget.args.pelangganId,
      "DiskonNominal": _textDiskonController.text.isEmpty
          ? "0"
          : _textDiskonController.text.replaceAll(".", ""),
      "SubTotal": totalHarga.toString(),
      "Pembulatan": _textPembulatanController.text.isEmpty
          ? "0"
          : _textPembulatanController.text.replaceAll(".", ""),
      "PPN": ppn.toString(),
      "NominalBayar": _textPembayaranController.text.replaceAll(".", ""),
      "RekeningId": metodeBayarSelectedMap[metodeBayarSelected].id,
      // "IsStatusInvoice": isPublish ? "PUBLISHED" : "DRAFT",
      "IsStatusInvoice": isDraft ? "DRAFT" : "PUBLISHED",
      "StatusLunas": isLunas ? "1" : "0",
      "InvoiceId": c.isEdit ? c.invoiceId : "",
      "InvoiceDetail": widget.args.invoiceDetail,
      "UserId": userId,
    };
    print(body);
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      print(response.body);
      return InvoiceSaveRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<SendWaRes> futureSendWa(String invoiceId) async {
    String url = '${API_URL}PosApps/SendWa';
    print(url);
    Map<String, dynamic> body = {
      "InvoiceId": invoiceId,
      "NoTelpPelanggan":
          _noWaController.text.isEmpty ? "" : _noWaController.text,
    };
    print(body.toString());
    url = url + '?' + Uri(queryParameters: body).query;
    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      print(response.body);
      return SendWaRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send wa');
    }
  }

  List<MetodeBayarData> metodeBayar = [];
  Map<String, MetodeBayarData> metodeBayarSelectedMap = {};
  String metodeBayarSelected = "";

  @override
  void initState() {
    print("Diskon");
    print(widget.args.diskon);
    // totalHarga = widget.args.totalHarga.toInt() - widget.args.diskon;
    totalHarga = widget.args.totalHarga.toInt();
    totalSetelahDiskon = totalHarga -
        int.parse(_textDiskonController.text.isEmpty
            ? "0"
            : _textDiskonController.text.replaceAll(".", "")) -
        int.parse(_textPembulatanController.text.isEmpty
            ? "0"
            : _textPembulatanController.text);
    if (isPpn) {
      ppn = (0.11 * totalSetelahDiskon).round();
    } else {
      ppn = 0;
    }
    futureMetodeBayar().then((value) {
      setState(() {
        metodeBayar = value.data;
        for (MetodeBayarData element in metodeBayar) {
          metodeBayarSelectedMap[element.alias] = element;
        }
      });
    });
    super.initState();
  }

  Future<bool> _onWillPop() async {
    c.setActiveBayar(false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Kembali'),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Sub Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Text(
                                CurrencyFormat.convertToIdr(
                                    widget.args.totalHarga, 0),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Diskon',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: _textDiskonController,
                                        decoration: InputDecoration(
                                          // labelText: "Diskon Nominal",
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(6),
                                          hintText: "Diskon Nominal",
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            // if (value == "0") {
                                            //   print("KOSONGGGFGGG");
                                            //   _textDiskonController.text = "0";
                                            // } else {}
                                            String diskon = value.isEmpty
                                                ? "0"
                                                : value.replaceAll(".", "");
                                            _textPersentaseController.text =
                                                ((int.parse(diskon ?? "0") /
                                                            totalHarga) *
                                                        100)
                                                    .toStringAsFixed(2)
                                                    .replaceAll(".", ",");
                                            totalSetelahDiskon = totalHarga -
                                                int.parse(diskon ?? "0") -
                                                int.parse(_textPembulatanController
                                                        .text.isEmpty
                                                    ? "0"
                                                    : _textPembulatanController
                                                        .text);
                                            if (isPpn) {
                                              ppn = (0.11 * totalSetelahDiskon)
                                                  .round();
                                            } else {
                                              ppn = 0;
                                            }
                                            if (isLunas) {
                                              _textPembayaranController
                                                  .text = ((totalHarga -
                                                          (diskon == null
                                                              ? 0
                                                              : int.parse(
                                                                  diskon)) -
                                                          (_textPembulatanController
                                                                  .text.isEmpty
                                                              ? 0
                                                              : int.parse(
                                                                  _textPembulatanController
                                                                      .text))) +
                                                      ppn)
                                                  .toString();
                                            }
                                          });
                                        },
                                        inputFormatters: [
                                          MoneyInputFormatter(
                                            mantissaLength: 0,
                                            thousandSeparator:
                                                ThousandSeparator.Period,
                                          )
                                        ],
                                        enabled: true,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _textPersentaseController,
                                        decoration: InputDecoration(
                                          // labelText: "Persentase",
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(6),
                                          hintText: "Persentase",
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            // if (value == "") {
                                            //   _textPersentaseController.text =
                                            //       "0";
                                            // }
                                            // cek value is double
                                            if (value.contains(".")) {
                                              _textPersentaseController.text =
                                                  value.replaceAll(".", ",");
                                              _textPersentaseController
                                                  .selection = TextSelection(
                                                baseOffset: value.length,
                                                extentOffset: value.length,
                                              );
                                            }
                                            double persentase = double.parse(
                                                _textPersentaseController
                                                        .text.isEmpty
                                                    ? "0"
                                                    : _textPersentaseController
                                                        .text);
                                            _textDiskonController
                                                .text = ((persentase / 100) *
                                                    totalHarga)
                                                .toStringAsFixed(0)
                                                .toCurrencyString(
                                                  thousandSeparator:
                                                      ThousandSeparator.Period,
                                                  mantissaLength: 0,
                                                );
                                            String diskon =
                                                _textDiskonController.text
                                                    .replaceAll(".", "");
                                            totalSetelahDiskon = totalHarga -
                                                int.parse(diskon ?? "0") -
                                                int.parse(_textPembulatanController
                                                        .text.isEmpty
                                                    ? "0"
                                                    : _textPembulatanController
                                                        .text);
                                            if (isPpn) {
                                              ppn = (0.11 * totalSetelahDiskon)
                                                  .round();
                                            } else {
                                              ppn = 0;
                                            }
                                            if (isLunas) {
                                              _textPembayaranController
                                                  .text = ((totalHarga -
                                                          (diskon == null
                                                              ? 0
                                                              : int.parse(
                                                                  diskon)) -
                                                          (_textPembulatanController
                                                                  .text.isEmpty
                                                              ? 0
                                                              : int.parse(
                                                                  _textPembulatanController
                                                                      .text))) +
                                                      ppn)
                                                  .toString();
                                            }
                                          });
                                        },
                                        enabled: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     // Percentage discount
                              //     if (_textDiskonController.text != "") ...[
                              //       Text(
                              //         '(${((int.parse(_textDiskonController.text) / totalHarga) * 100).toStringAsFixed(2)}%) ',
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.pink,
                              //         ),
                              //       ),
                              //     ] else ...[
                              //       Text(
                              //         ' (0%)',
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.pink,
                              //         ),
                              //       ),
                              //     ],
                              //     Text(
                              //       // _textDiskonController.text,
                              //       _textDiskonController.text == ""
                              //           ? CurrencyFormat.convertToIdr(0, 0)
                              //           : CurrencyFormat.convertToIdr(
                              //               int.parse(
                              //                   _textDiskonController.text),
                              //               0),
                              //       style: TextStyle(
                              //         fontSize: 18,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.blue,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Pembulatan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _textPembulatanController,
                                  decoration: InputDecoration(
                                    // labelText: "Pembulatan",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(6),
                                    hintText: "Pembulatan",
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    MoneyInputFormatter(
                                      mantissaLength: 0,
                                      thousandSeparator:
                                          ThousandSeparator.Period,
                                    )
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      // if (value == "") {
                                      //   _textPembulatanController.text = "0";
                                      // }
                                      String diskon =
                                          _textDiskonController.text.isEmpty
                                              ? "0"
                                              : _textDiskonController.text
                                                  .replaceAll(".", "");

                                      String pembulatan =
                                          _textPembulatanController.text.isEmpty
                                              ? "0"
                                              : _textPembulatanController.text
                                                  .replaceAll(".", "");
                                      totalSetelahDiskon = totalHarga -
                                          int.parse(diskon ?? "0") -
                                          int.parse(pembulatan ?? "0");
                                      if (isPpn) {
                                        ppn =
                                            (0.11 * totalSetelahDiskon).round();
                                      } else {
                                        ppn = 0;
                                      }
                                      if (isLunas) {
                                        _textPembayaranController
                                            .text = ((totalHarga -
                                                    (diskon == null
                                                        ? 0
                                                        : int.parse(diskon)) -
                                                    (pembulatan == null
                                                        ? 0
                                                        : int.parse(
                                                            pembulatan))) +
                                                ppn)
                                            .toString();
                                      }
                                    });
                                  },
                                  enabled: true,
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     // Percentage discount
                              //     if (_textDiskonController.text != "") ...[
                              //       Text(
                              //         '(${((int.parse(_textDiskonController.text) / totalHarga) * 100).toStringAsFixed(2)}%) ',
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.pink,
                              //         ),
                              //       ),
                              //     ] else ...[
                              //       Text(
                              //         ' (0%)',
                              //         style: TextStyle(
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.bold,
                              //           color: Colors.pink,
                              //         ),
                              //       ),
                              //     ],
                              //     Text(
                              //       // _textDiskonController.text,
                              //       _textDiskonController.text == ""
                              //           ? CurrencyFormat.convertToIdr(0, 0)
                              //           : CurrencyFormat.convertToIdr(
                              //               int.parse(
                              //                   _textDiskonController.text),
                              //               0),
                              //       style: TextStyle(
                              //         fontSize: 18,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.blue,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'PPN',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  // Lunas atau belum
                                  Checkbox(
                                    value: isPpn,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isPpn = value;
                                        if (value == true) {
                                          ppn = (0.11 * totalSetelahDiskon)
                                              .round();
                                        } else {
                                          ppn = 0;
                                        }
                                        if (isLunas) {
                                          _textPembayaranController
                                              .text = ((totalHarga -
                                                      (_textDiskonController
                                                              .text.isEmpty
                                                          ? 0
                                                          : int.parse(
                                                              _textDiskonController
                                                                  .text
                                                                  .replaceAll(
                                                                      ".",
                                                                      ""))) -
                                                      (_textPembulatanController
                                                              .text.isEmpty
                                                          ? 0
                                                          : int.parse(
                                                              _textPembulatanController
                                                                  .text
                                                                  .replaceAll(
                                                                      ".",
                                                                      "")))) +
                                                  ppn)
                                              .toString();
                                        }
                                      });
                                    },
                                    activeColor: Colors.green,
                                    visualDensity: VisualDensity(
                                        horizontal: -4, vertical: -4),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    CurrencyFormat.convertToIdr(ppn, 0),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              // Text(
                              //   CurrencyFormat.convertToIdr(ppn, 0),
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.blue,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Grand Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              isPpn
                                  ? Text(
                                      CurrencyFormat.convertToIdr(
                                          (totalHarga -
                                                  (_textDiskonController
                                                          .text.isEmpty
                                                      ? 0
                                                      : int.parse(
                                                          _textDiskonController
                                                              .text
                                                              .replaceAll(
                                                                  ".", ""))) -
                                                  (_textPembulatanController
                                                          .text.isEmpty
                                                      ? 0
                                                      : int.parse(
                                                          _textPembulatanController
                                                              .text
                                                              .replaceAll(
                                                                  ".", "")))) +
                                              ppn,
                                          0),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : Text(
                                      CurrencyFormat.convertToIdr(
                                          (totalHarga -
                                              (_textDiskonController
                                                      .text.isEmpty
                                                  ? 0
                                                  : int.parse(
                                                      _textDiskonController.text
                                                          .replaceAll(
                                                              ".", ""))) -
                                              (_textPembulatanController
                                                      .text.isEmpty
                                                  ? 0
                                                  : int.parse(
                                                      _textPembulatanController
                                                          .text
                                                          .replaceAll(
                                                              ".", "")))),
                                          0),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Pembayaran',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _textPembayaranController,
                                  decoration: InputDecoration(
                                    // labelText: "Pembayaran",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(6),
                                    hintText: 'Pembayaran',
                                  ),
                                  inputFormatters: [
                                    MoneyInputFormatter(
                                      mantissaLength: 0,
                                      thousandSeparator:
                                          ThousandSeparator.Period,
                                    ),
                                  ],
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {},
                                  enabled: !isLunas,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              // Lunas atau belum
                              Checkbox(
                                value: isLunas,
                                onChanged: (bool value) {
                                  setState(() {
                                    isLunas = value;
                                    if (isLunas) {
                                      if (isPpn) {
                                        ppn =
                                            (0.11 * totalSetelahDiskon).round();
                                      } else {
                                        ppn = 0;
                                      }
                                      _textPembayaranController
                                          .text = ((totalHarga -
                                                  (_textDiskonController
                                                          .text.isEmpty
                                                      ? 0
                                                      : int.parse(
                                                          _textDiskonController
                                                              .text
                                                              .replaceAll(
                                                                  ".", ""))) -
                                                  (_textPembulatanController
                                                          .text.isEmpty
                                                      ? 0
                                                      : int.parse(
                                                          _textPembulatanController
                                                              .text
                                                              .replaceAll(
                                                                  ".", "")))) +
                                              ppn)
                                          .toString()
                                          .toCurrencyString(
                                            thousandSeparator:
                                                ThousandSeparator.Period,
                                            mantissaLength: 0,
                                          );
                                    } else {
                                      _textPembayaranController.text = "";
                                    }
                                  });
                                },
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: -4),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Lunas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: metodeBayar.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Pilih Metode Pembayaran",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: AlignedGridView.count(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 4.0,
                                  crossAxisSpacing: 4.0,
                                  itemCount: metodeBayar.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          metodeBayarSelected =
                                              metodeBayar[index].alias;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: metodeBayarSelected ==
                                                  metodeBayar[index].alias
                                              ? Colors.blue.withOpacity(0.6)
                                              : Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.payment,
                                              size: 16,
                                              color: metodeBayarSelected ==
                                                      metodeBayar[index].alias
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              metodeBayar[index].alias,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: metodeBayarSelected ==
                                                        metodeBayar[index].alias
                                                    ? Colors.white
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                ),
              ],
            ),
            // Spacer(),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                        ),
                        onPressed: () async {
                          if (_textPembayaranController.text.isEmpty ||
                              _textPembayaranController.text == "0") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      "Pembayaran tidak boleh kosong atau 0",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          if (metodeBayarSelected == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      "Pilih metode pembayaran",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String userId = prefs.getString("user_id");
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("User belum dipilih"),
                              ),
                            );
                            return;
                          }
                          futureInvoiceSave(false, userId).then((value) {
                            if (value != null) {
                              if (value.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(value.message),
                                  ),
                                );
                                _noWaController.text = value.data.noTelp;
                                c.cancelEdit();
                                c.setSalesman("");
                                c.setPelanggan("");
                                c.setStatusBayar("");

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: Text("Konfirmasi Whatsapp"),
                                        // content: Text(
                                        //     "Apakah anda yakin ingin mengirim invoice ini?"),
                                        // Input no Whatsapp
                                        content: SizedBox(
                                          height: 100,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller: _noWaController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: "No Whatsapp",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              c.setActiveBayar(false);
                                              Navigator.pop(
                                                  context, 'redirect');
                                            },
                                            child: Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await futureSendWa(
                                                      value.data.invoiceId)
                                                  .then((value) {
                                                if (value.success) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Invoice berhasil dikirim"),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ));
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Invoice gagal dikirim"),
                                                    backgroundColor: Colors.red,
                                                  ));
                                                }
                                                Navigator.pop(context);
                                              }).onError((error, stackTrace) {
                                                print(error);
                                                print(stackTrace);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Invoice gagal dikirim"),
                                                  backgroundColor: Colors.red,
                                                ));
                                                Navigator.pop(context);
                                              });
                                              c.setActiveBayar(false);
                                              Navigator.pop(context, 'success');
                                            },
                                            child: Text("Kirim"),
                                          ),
                                        ],
                                      );
                                    });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(value.message),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gagal menyimpan invoice"),
                                ),
                              );
                            }
                          }).catchError((onError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Terjadi kesalahan"),
                              ),
                            );
                          });
                          // if (isLunas) {
                          //   setState(() {
                          //     total = widget.args.totalHarga.toInt();
                          //     penerimaanTunai = total;
                          //   });
                          // } else {
                          //   if (total > 0) {
                          //     setState(() {
                          //       penerimaanTunai = total;
                          //     });
                          //   }
                          // }
                        },
                        icon: Icon(Icons.check),
                        label: Text('SIMPAN'),
                      ),
                    ),
                    SizedBox(width: 5),
                    // Button Draft
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey.shade600,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                        ),
                        onPressed: () async {
                          if (_textPembayaranController.text.isEmpty ||
                              _textPembayaranController.text == "0") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      "Pembayaran tidak boleh kosong atau 0",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          if (metodeBayarSelected == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      "Pilih metode pembayaran",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String userId = prefs.getString("user_id");
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("User belum dipilih"),
                              ),
                            );
                            return;
                          }
                          futureInvoiceSave(true, userId).then((value) {
                            if (value != null) {
                              if (value.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(value.message),
                                  ),
                                );
                                _noWaController.text = value.data.noTelp;
                                c.cancelEdit();
                                c.setSalesman("");
                                c.setPelanggan("");
                                c.setStatusBayar("");

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: Text("Konfirmasi Whatsapp"),
                                        // content: Text(
                                        //     "Apakah anda yakin ingin mengirim invoice ini?"),
                                        // Input no Whatsapp
                                        content: SizedBox(
                                          height: 100,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller: _noWaController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: "No Whatsapp",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              c.setActiveBayar(false);
                                              Navigator.pop(
                                                  context, 'redirect');
                                            },
                                            child: Text("Batal"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await futureSendWa(
                                                      value.data.invoiceId)
                                                  .then((value) {
                                                if (value.success) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Invoice berhasil dikirim"),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ));
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Invoice gagal dikirim"),
                                                    backgroundColor: Colors.red,
                                                  ));
                                                }
                                                Navigator.pop(context);
                                              }).onError((error, stackTrace) {
                                                print(error);
                                                print(stackTrace);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Invoice gagal dikirim"),
                                                  backgroundColor: Colors.red,
                                                ));
                                                Navigator.pop(context);
                                              });
                                              c.setActiveBayar(false);
                                              Navigator.pop(context, 'success');
                                            },
                                            child: Text("Kirim"),
                                          ),
                                        ],
                                      );
                                    });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(value.message),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Gagal menyimpan invoice"),
                                ),
                              );
                            }
                          }).catchError((onError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Terjadi kesalahan"),
                              ),
                            );
                          });
                        },
                        icon: Icon(Icons.save),
                        label: Text('DRAFT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tombol Back & Cancel
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                        ),
                        onPressed: () {
                          c.setActiveBayar(false);
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                        label: Text('BACK'),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey.shade600,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                        ),
                        onPressed: () {
                          c.cancelEdit();
                          c.setSalesman("");
                          c.setPelanggan("");
                          c.setStatusBayar("");
                          c.setActiveBayar(false);
                          Navigator.pop(context, 'cancel');
                        },
                        icon: Icon(Icons.cancel),
                        label: Text('BATAL'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 10),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width * 0.7,
            //   child: Row(
            //     children: [
            //       Row(
            //         children: [
            //           // Lunas atau belum
            //           Text('Lunas'),
            //           Checkbox(
            //             value: isLunas,
            //             onChanged: (bool value) {
            //               setState(() {
            //                 isLunas = value;
            //                 if (isLunas) {
            //                   // total = widget.args.totalHarga.toInt() -
            //                   //     widget.args.diskon;
            //                   total = widget.args.totalHarga.toInt();
            //                   _textEditingController.text = total.toString();
            //                   if (_textDiskonController.text.isNotEmpty) {
            //                     ppn = ((total -
            //                                 int.parse(
            //                                     _textDiskonController.text)) *
            //                             0.11)
            //                         .toInt();
            //                   } else {
            //                     ppn = (total * 0.11).toInt();
            //                   }
            //                 } else {
            //                   total = totalHarga;
            //                   _textEditingController.text = "";
            //                   ppn = (total * 0.11).toInt();
            //                 }
            //               });
            //             },
            //             visualDensity:
            //                 VisualDensity(horizontal: -4, vertical: -4),
            //           ),
            //         ],
            //       ),
            //       SizedBox(width: 10),
            //       Expanded(
            //         child: TextFormField(
            //           controller: _textEditingController,
            //           decoration: InputDecoration(
            //             labelText: isLunas ? 'Lunas' : 'Penerimaan Tunai',
            //             border: OutlineInputBorder(),
            //             isDense: true,
            //             contentPadding: EdgeInsets.all(16),
            //           ),
            //           keyboardType: TextInputType.number,
            //           onChanged: (value) {
            //             if (isLunas) {
            //               setState(() {
            //                 total = totalHarga;
            //                 if (_textDiskonController.text.isNotEmpty) {
            //                   ppn = ((total -
            //                               int.parse(
            //                                   _textDiskonController.text)) *
            //                           0.11)
            //                       .toInt();
            //                 } else {
            //                   ppn = ((total - 0) * 0.11).toInt();
            //                 }
            //               });
            //             } else {
            //               if (value.isNotEmpty) {
            //                 int val = int.parse(value);
            //                 if (val > totalHarga) {
            //                   // show snackbar
            //                   ScaffoldMessenger.of(context).showSnackBar(
            //                     SnackBar(
            //                       backgroundColor: Colors.red,
            //                       content: Text(
            //                           'Jika penerimaan tunai lebih besar dari total, maka akan dianggap lunas'),
            //                       duration: Duration(seconds: 5),
            //                     ),
            //                   );
            //                   // Dismiss keyboard
            //                   FocusScope.of(context).unfocus();
            //                   setState(() {
            //                     isLunas = true;
            //                     total = totalHarga;
            //                     if (_textDiskonController.text.isNotEmpty) {
            //                       ppn = ((totalHarga -
            //                                   int.parse(
            //                                       _textDiskonController.text)) *
            //                               0.11)
            //                           .toInt();
            //                     } else {
            //                       ppn = ((totalHarga - 0) * 0.11).toInt();
            //                     }
            //                   });
            //                   return;
            //                 } else {
            //                   setState(() {
            //                     total = totalHarga;
            //                     if (_textDiskonController.text.isEmpty) {
            //                       ppn = ((total - 0) * 0.11).toInt();
            //                     } else {
            //                       ppn = ((total -
            //                                   int.parse(
            //                                       _textDiskonController.text)) *
            //                               0.11)
            //                           .toInt();
            //                     }
            //                   });
            //                 }
            //                 // setState(() {
            //                 //   total = int.parse(value);
            //                 //   _textDiskonController.text = "0";
            //                 //   ppn = ((total -
            //                 //               int.parse(
            //                 //                   _textDiskonController.text)) *
            //                 //           0.11)
            //                 //       .toInt();
            //                 // });
            //               } else {
            //                 setState(() {
            //                   total = totalHarga;
            //                   if (_textDiskonController.text.isEmpty) {
            //                     ppn = ((total - 0) * 0.11).toInt();
            //                   } else {
            //                     ppn = ((total -
            //                                 int.parse(
            //                                     _textDiskonController.text)) *
            //                             0.11)
            //                         .toInt();
            //                   }
            //                 });
            //               }
            //             }
            //           },
            //           enabled: !isLunas,
            //         ),
            //       ),
            //       SizedBox(width: 10),
            //       Expanded(
            //         child: TextFormField(
            //           controller: _textDiskonController,
            //           decoration: InputDecoration(
            //             labelText: "Diskon",
            //             border: OutlineInputBorder(),
            //             isDense: true,
            //             contentPadding: EdgeInsets.all(16),
            //           ),
            //           keyboardType: TextInputType.number,
            //           onChanged: (value) {
            //             if (value.isNotEmpty) {
            //               setState(() {
            //                 total = widget.args.totalHarga.toInt() -
            //                     int.parse(value);
            //                 ppn = ((total -
            //                             int.parse(_textDiskonController.text)) *
            //                         0.11)
            //                     .toInt();
            //               });
            //             } else {
            //               setState(() {
            //                 total = totalHarga;
            //                 ppn = ((total - 0) * 0.11).toInt();
            //               });
            //             }
            //           },
            //           enabled: _textEditingController.text.isNotEmpty,
            //         ),
            //       ),
            //       // SizedBox(width: 10),
            //       // Row(
            //       //   children: [
            //       //     // Lunas atau belum
            //       //     Text('Publish'),
            //       //     Checkbox(
            //       //       value: isPublish,
            //       //       onChanged: (bool value) {
            //       //         setState(() {
            //       //           isPublish = value;
            //       //         });
            //       //       },
            //       //       visualDensity:
            //       //           VisualDensity(horizontal: -4, vertical: -4),
            //       //     ),
            //       //   ],
            //       // ),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 10),
            // Expanded(
            //   child: metodeBayar.isNotEmpty
            //       ? SizedBox(
            //           // height: 160,
            //           child: Padding(
            //             padding: EdgeInsets.symmetric(horizontal: 16),
            //             child: AlignedGridView.count(
            //               crossAxisCount: 3,
            //               mainAxisSpacing: 4.0,
            //               crossAxisSpacing: 4.0,
            //               itemCount: metodeBayar.length,
            //               itemBuilder: (context, index) {
            //                 return InkWell(
            //                   onTap: () {
            //                     setState(() {
            //                       metodeBayarSelected = metodeBayar[index].alias;
            //                     });
            //                   },
            //                   child: Container(
            //                     padding: EdgeInsets.all(5),
            //                     decoration: BoxDecoration(
            //                       color: metodeBayarSelected ==
            //                               metodeBayar[index].alias
            //                           ? Colors.blue.withOpacity(0.6)
            //                           : Colors.grey[200],
            //                       borderRadius: BorderRadius.circular(5),
            //                     ),
            //                     child: Row(
            //                       children: [
            //                         SizedBox(width: 10),
            //                         Icon(
            //                           Icons.payment,
            //                           size: 18,
            //                           color: metodeBayarSelected ==
            //                                   metodeBayar[index].alias
            //                               ? Colors.white
            //                               : Colors.grey.shade600,
            //                         ),
            //                         SizedBox(width: 5),
            //                         Text(
            //                           metodeBayar[index].alias,
            //                           style: TextStyle(
            //                             fontSize: 14,
            //                             fontWeight: FontWeight.bold,
            //                             color: metodeBayarSelected ==
            //                                     metodeBayar[index].alias
            //                                 ? Colors.white
            //                                 : Colors.grey.shade600,
            //                           ),
            //                         ),
            //                         SizedBox(width: 10),
            //                       ],
            //                     ),
            //                   ),
            //                 );
            //               },
            //             ),
            //           ),
            //         )
            //       : SizedBox(),
            // ),
            SizedBox(height: 10),
            if (penerimaanTunai > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   "${total >= widget.args.totalHarga.toInt() ? 'Kembalian' : 'Terhutang'} : " +
                  //       CurrencyFormat.convertToIdr(
                  //         penerimaanTunai - widget.args.totalHarga.toInt(),
                  //         0,
                  //       ),
                  //   style: TextStyle(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: total >= widget.args.totalHarga.toInt()
                  //         ? Colors.green
                  //         : Colors.red,
                  //   ),
                  // ),
                  // SizedBox(width: 10),
                  Text(
                    'Page otomatis kembali dalam ${myDuration.inSeconds} detik',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
