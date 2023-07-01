import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posapps/models/invoice_save.dart';
import 'package:posapps/models/metode_bayar.dart';
import 'package:posapps/models/produk.dart';
import 'package:posapps/pages/models/bayar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:posapps/resources/string.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:posapps/store/store.dart';

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

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textDiskonController = TextEditingController();

  int totalHarga = 0;
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

  Future<InvoiceSaveRes> futureInvoiceSave() async {
    String url = "${API_URL}PosApps/InvoiceSave";
    Map<String, dynamic> body = {
      "SalesmanId": widget.args.salesmanId,
      "PelangganId": widget.args.pelangganId,
      "DiskonNominal":
          _textDiskonController.text.isEmpty ? "0" : _textDiskonController.text,
      "SubTotal": ((total -
                  (_textDiskonController.text.isEmpty
                      ? 0
                      : int.parse(_textDiskonController.text))) +
              ppn)
          .toString(),
      "PPN": ppn.toString(),
      "NominalBayar": _textEditingController.text,
      "RekeningId": metodeBayarSelectedMap[metodeBayarSelected].id,
      // "IsStatusInvoice": isPublish ? "PUBLISHED" : "DRAFT",
      "IsStatusInvoice": "PUBLISHED",
      "StatusLunas": isLunas ? "1" : "0",
      "InvoiceId": c.isEdit ? c.invoiceId : "",
      "InvoiceDetail": widget.args.invoiceDetail,
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

  List<MetodeBayarData> metodeBayar = [];
  Map<String, MetodeBayarData> metodeBayarSelectedMap = {};
  String metodeBayarSelected = "";

  @override
  void initState() {
    print("Diskon");
    print(widget.args.diskon);
    // totalHarga = widget.args.totalHarga.toInt() - widget.args.diskon;
    totalHarga = widget.args.totalHarga.toInt();
    ppn = (totalHarga * 0.11).toInt();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Kembali'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Diskon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      // Percentage discount
                      if (_textDiskonController.text != "") ...[
                        Text(
                          '(${((int.parse(_textDiskonController.text) / totalHarga) * 100).toStringAsFixed(2)}%) ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ] else ...[
                        Text(
                          ' (0%)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                      Text(
                        // _textDiskonController.text,
                        _textDiskonController.text == ""
                            ? CurrencyFormat.convertToIdr(0, 0)
                            : CurrencyFormat.convertToIdr(
                                int.parse(_textDiskonController.text), 0),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PPN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
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
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Grand Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    CurrencyFormat.convertToIdr(
                        (totalHarga -
                                (_textDiskonController.text.isEmpty
                                    ? 0
                                    : int.parse(_textDiskonController.text))) +
                            ppn,
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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 2,
                  ),
                ),
                onPressed: () {
                  if (_textEditingController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              "Nominal bayar tidak boleh kosong",
                              style: TextStyle(
                                fontSize: 18,
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
                              "Metode bayar tidak boleh kosong",
                              style: TextStyle(
                                fontSize: 18,
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
                  futureInvoiceSave().then((value) {
                    if (value != null) {
                      if (value.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Berhasil menyimpan invoice"),
                          ),
                        );
                        c.cancelEdit();
                        Navigator.pop(context, 'success');
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
            SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Row(
                children: [
                  Row(
                    children: [
                      // Lunas atau belum
                      Text('Lunas'),
                      Checkbox(
                        value: isLunas,
                        onChanged: (bool value) {
                          setState(() {
                            isLunas = value;
                            if (isLunas) {
                              // total = widget.args.totalHarga.toInt() -
                              //     widget.args.diskon;
                              total = widget.args.totalHarga.toInt();
                              _textEditingController.text = total.toString();
                              if (_textDiskonController.text.isNotEmpty) {
                                ppn = ((total -
                                            int.parse(
                                                _textDiskonController.text)) *
                                        0.11)
                                    .toInt();
                              } else {
                                ppn = (total * 0.11).toInt();
                              }
                            } else {
                              total = totalHarga;
                              _textEditingController.text = "";
                              ppn = (total * 0.11).toInt();
                            }
                          });
                        },
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        labelText: isLunas ? 'Lunas' : 'Penerimaan Tunai',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (isLunas) {
                          setState(() {
                            total = totalHarga;
                            if (_textDiskonController.text.isNotEmpty) {
                              ppn = ((total -
                                          int.parse(
                                              _textDiskonController.text)) *
                                      0.11)
                                  .toInt();
                            } else {
                              ppn = ((total - 0) * 0.11).toInt();
                            }
                          });
                        } else {
                          if (value.isNotEmpty) {
                            int val = int.parse(value);
                            if (val > totalHarga) {
                              // show snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      'Jika penerimaan tunai lebih besar dari total, maka akan dianggap lunas'),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                              // Dismiss keyboard
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isLunas = true;
                                total = totalHarga;
                                if (_textDiskonController.text.isNotEmpty) {
                                  ppn = ((totalHarga -
                                              int.parse(
                                                  _textDiskonController.text)) *
                                          0.11)
                                      .toInt();
                                } else {
                                  ppn = ((totalHarga - 0) * 0.11).toInt();
                                }
                              });
                              return;
                            } else {
                              setState(() {
                                total = totalHarga;
                                if (_textDiskonController.text.isEmpty) {
                                  ppn = ((total - 0) * 0.11).toInt();
                                } else {
                                  ppn = ((total -
                                              int.parse(
                                                  _textDiskonController.text)) *
                                          0.11)
                                      .toInt();
                                }
                              });
                            }
                            // setState(() {
                            //   total = int.parse(value);
                            //   _textDiskonController.text = "0";
                            //   ppn = ((total -
                            //               int.parse(
                            //                   _textDiskonController.text)) *
                            //           0.11)
                            //       .toInt();
                            // });
                          } else {
                            setState(() {
                              total = totalHarga;
                              if (_textDiskonController.text.isEmpty) {
                                ppn = ((total - 0) * 0.11).toInt();
                              } else {
                                ppn = ((total -
                                            int.parse(
                                                _textDiskonController.text)) *
                                        0.11)
                                    .toInt();
                              }
                            });
                          }
                        }
                      },
                      enabled: !isLunas,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _textDiskonController,
                      decoration: InputDecoration(
                        labelText: "Diskon",
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            total = widget.args.totalHarga.toInt() -
                                int.parse(value);
                            ppn = ((total -
                                        int.parse(_textDiskonController.text)) *
                                    0.11)
                                .toInt();
                          });
                        } else {
                          setState(() {
                            total = totalHarga;
                            ppn = ((total - 0) * 0.11).toInt();
                          });
                        }
                      },
                      enabled: _textEditingController.text.isNotEmpty,
                    ),
                  ),
                  // SizedBox(width: 10),
                  // Row(
                  //   children: [
                  //     // Lunas atau belum
                  //     Text('Publish'),
                  //     Checkbox(
                  //       value: isPublish,
                  //       onChanged: (bool value) {
                  //         setState(() {
                  //           isPublish = value;
                  //         });
                  //       },
                  //       visualDensity:
                  //           VisualDensity(horizontal: -4, vertical: -4),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: metodeBayar.isNotEmpty
                  ? SizedBox(
                      // height: 160,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: AlignedGridView.count(
                          crossAxisCount: 3,
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
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.payment,
                                      size: 18,
                                      color: metodeBayarSelected ==
                                              metodeBayar[index].alias
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      metodeBayar[index].alias,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: metodeBayarSelected ==
                                                metodeBayar[index].alias
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
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
                      fontSize: 16,
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
