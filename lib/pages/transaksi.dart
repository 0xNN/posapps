import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:posapps/models/invoice.dart';
import 'package:http/http.dart' as http;
import 'package:posapps/models/invoice_cancel.dart';
import 'package:posapps/models/invoice_delete.dart';
import 'package:posapps/models/send_wa.dart';
import 'package:posapps/resources/string.dart';
import 'package:intl/intl.dart';
import 'package:posapps/store/store.dart';
import 'package:date_time_picker/date_time_picker.dart';

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

class TransaksiPage extends StatefulWidget {
  final Function refresh;
  final bool isUpdate;
  const TransaksiPage({Key key, this.refresh, this.isUpdate}) : super(key: key);
  static const String routeName = '/transaksi';

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final c = Get.put(Controller());
  List<ListInvoice> invoiceData = [];
  List<ListInvoice> invoiceDataFiltered = [];

  final TextEditingController _noWaController = TextEditingController(text: '');

  String date = "";

  DataSummary summary;

  String search = '';

  ListInvoice invoiceDataSelected;
  Set<DetailInvoice> detailInvoice = <DetailInvoice>{};

  Future<InvoiceRes> futureInvoice() async {
    String url = '${API_URL}PosApps/Invoice';
    print(url);
    Map<String, dynamic> body = {
      "InvoiceId": "",
      // "Status": "",
      // "StatusLunas": "",
      "StatusBayar": c.statusBayar.value.toString(),
      "SalesmanId": c.salesmanId.value.toString(),
      "TglInvoiceAwal": c.tanggal.value.toString(),
      "TglInvoiceAkhir": c.tanggalTo.value.toString(),
    };
    print(body.toString());
    url = url + '?' + Uri(queryParameters: body).query;
    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      print(response.body);
      return InvoiceRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load invoice');
    }
  }

  Future<InvoiceDeleteRes> futureInvoiceDelete(String invoiceId) async {
    String url = '${API_URL}PosApps/InvoiceDelete';
    print(url);
    Map<String, dynamic> body = {
      "InvoiceId": invoiceId,
    };
    print(body.toString());
    url = url + '?' + Uri(queryParameters: body).query;
    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      print(response.body);
      return InvoiceDeleteRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete invoice');
    }
  }

  Future<InvoiceCancelRes> futureInvoiceCancel(String invoiceId) async {
    String url = '${API_URL}PosApps/InvoiceCancel';
    print(url);
    Map<String, dynamic> body = {
      "InvoiceId": invoiceId,
    };
    print(body.toString());
    url = url + '?' + Uri(queryParameters: body).query;
    final response = await http.get(
      Uri.parse(url),
      headers: {"Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      print(response.body);
      return InvoiceCancelRes.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to cancel invoice');
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

  @override
  void initState() {
    print("INIT TRANSAKSI");
    futureInvoice().then((value) {
      if (value.success) {
        if (value.data == null) {
          setState(() {
            invoiceData = [];
            invoiceDataFiltered = [];
            summary = null;
          });
        } else {
          setState(() {
            invoiceData = value.data.listInvoice;
            invoiceDataFiltered = invoiceData;
            summary = value.data.summary;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.message),
          ),
        );
      }
    }).onError((onError, stackTrace) {
      print("ERRRORRRRRR");
      print(onError.toString());
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onError.toString()),
        ),
      );
    });
    super.initState();
  }

  @override
  void didUpdateWidget(TransaksiPage oldWidget) {
    print("UPDATE TRANSAKSI");
    futureInvoice().then((value) {
      if (value.success) {
        if (value.data == null) {
          setState(() {
            invoiceData = [];
            invoiceDataFiltered = [];
            summary = null;
          });
        } else {
          print("LENGTH INVOICE : ${value.data.listInvoice.length}");
          setState(() {
            invoiceData = value.data.listInvoice;
            if (search.isNotEmpty) {
              invoiceDataFiltered = invoiceData
                  .where((element) => element.pelanggan
                      .toLowerCase()
                      .contains(search.toLowerCase()))
                  .toList();
            } else {
              invoiceDataFiltered = invoiceData;
            }
            summary = value.data.summary;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.message),
          ),
        );
      }
    }).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onError.toString()),
        ),
      );
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  // Total Tagihan
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey[300],
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: Colors.grey[300],
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Tagihan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            invoiceDataFiltered.isEmpty
                                ? "-"
                                : CurrencyFormat.convertToIdr(
                                    int.parse(summary.totalTagihan),
                                    0,
                                  ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Total Bayar
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey[300],
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: Colors.grey[300],
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Bayar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            invoiceDataFiltered.isEmpty
                                ? "-"
                                : CurrencyFormat.convertToIdr(
                                    int.parse(summary.totalBayar),
                                    0,
                                  ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sisa Tagihan
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey[300],
                            width: 1,
                          ),
                          bottom: BorderSide(
                            color: Colors.grey[300],
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sisa Tagihan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            invoiceDataFiltered.isEmpty
                                ? "-"
                                : CurrencyFormat.convertToIdr(
                                    int.parse(summary.sisaTagihan),
                                    0,
                                  ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey[300],
                          width: 1,
                        ),
                        // top: BorderSide(
                        //   color: Colors.grey[300],
                        //   width: 1,
                        // ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Search
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Cari Pelanggan',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[400],
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 20,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey[100],
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  print("SEARCH");
                                  setState(() {
                                    search = value;
                                    if (value.isEmpty) {
                                      invoiceDataFiltered = invoiceData;
                                    } else {
                                      invoiceDataFiltered = invoiceData
                                          .where((element) => element.pelanggan
                                              .toLowerCase()
                                              .contains(search.toLowerCase()))
                                          .toList();
                                    }
                                    print(invoiceDataFiltered.length);
                                  });
                                },
                              ),
                            ),
                            // InkWell(
                            //   onTap: () {
                            //     showDialog(
                            //         context: context,
                            //         builder: (BuildContext context) {
                            //           return StatefulBuilder(
                            //               builder: (context, updateState) {
                            //             return AlertDialog(
                            //               title: Text("Filter Invoice By Date"),
                            //               contentPadding: EdgeInsets.fromLTRB(
                            //                   24, 20, 24, 0),
                            //               content: DateTimePicker(
                            //                 initialValue: '',
                            //                 type: DateTimePickerType.date,
                            //                 initialDate: DateTime.now(),
                            //                 firstDate: DateTime(2000),
                            //                 lastDate: DateTime(2100),
                            //                 dateLabelText: 'Tanggal',
                            //                 dateMask: 'yyyy-MM-dd',
                            //                 onChanged: (val) {
                            //                   print(val);
                            //                   print("CHANGED");
                            //                   setState(() {
                            //                     date = val;
                            //                   });
                            //                 },
                            //                 validator: (val) {
                            //                   print(val);
                            //                   return null;
                            //                 },
                            //                 onSaved: (val) {
                            //                   print(val);
                            //                   print("SAVED");
                            //                 },
                            //               ),
                            //               actionsPadding:
                            //                   MediaQuery.of(context).viewInsets,
                            //               actionsOverflowDirection:
                            //                   VerticalDirection
                            //                       .up, // button will be aligned to the top
                            //               actions: [
                            //                 TextButton(
                            //                   onPressed: () {
                            //                     Navigator.pop(context);
                            //                   },
                            //                   child: Text("Batal"),
                            //                 ),
                            //                 TextButton(
                            //                   onPressed: () {
                            //                     Navigator.pop(context);
                            //                     print(date);
                            //                     futureInvoice().then((value) {
                            //                       if (value.success) {
                            //                         if (value.data == null) {
                            //                           setState(() {
                            //                             invoiceData = [];
                            //                             invoiceDataFiltered =
                            //                                 [];
                            //                             summary = null;
                            //                           });
                            //                         } else {
                            //                           setState(() {
                            //                             invoiceData = value
                            //                                 .data.listInvoice;
                            //                             invoiceDataFiltered =
                            //                                 invoiceData;
                            //                             summary =
                            //                                 value.data.summary;
                            //                           });
                            //                         }
                            //                       } else {
                            //                         ScaffoldMessenger.of(
                            //                                 context)
                            //                             .showSnackBar(
                            //                           SnackBar(
                            //                             content:
                            //                                 Text(value.message),
                            //                           ),
                            //                         );
                            //                       }
                            //                     }).onError(
                            //                         (onError, stackTrace) {
                            //                       print("ERRRORRRRRR");
                            //                       print(onError.toString());
                            //                       print(stackTrace);
                            //                       ScaffoldMessenger.of(context)
                            //                           .showSnackBar(
                            //                         SnackBar(
                            //                           content: Text(
                            //                               onError.toString()),
                            //                         ),
                            //                       );
                            //                     });
                            //                   },
                            //                   child: Text("Simpan"),
                            //                 ),
                            //               ],
                            //             );
                            //           });
                            //         });
                            //   },
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.filter_list,
                            //         color: Colors.grey[400],
                            //       ),
                            //       Text(
                            //         date.isEmpty ? 'Date' : date,
                            //         style: TextStyle(
                            //           color: Colors.grey[400],
                            //         ),
                            //       ),
                            //       SizedBox(width: 3),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                        invoiceDataFiltered.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: invoiceDataFiltered.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          invoiceDataSelected =
                                              invoiceDataFiltered[index];
                                          detailInvoice.clear();
                                          _noWaController.text =
                                              invoiceDataSelected
                                                  .noTelpPelanggan;
                                          for (DetailInvoice element
                                              in invoiceDataFiltered[index]
                                                  .detailInvoice) {
                                            // check unique
                                            if (detailInvoice
                                                .where((e) =>
                                                    e.rowUniqueId ==
                                                    element.rowUniqueId)
                                                .isEmpty) {
                                              detailInvoice.add(element);
                                            }
                                          }
                                          print(detailInvoice.length);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey[300],
                                              width: 1,
                                            ),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: ListTile(
                                          title: Text(invoiceDataFiltered[index]
                                              .pelanggan),
                                          enabled: invoiceDataSelected != null
                                              ? invoiceDataFiltered[index].id ==
                                                  invoiceDataSelected.id
                                              : false,
                                          subtitle: Row(
                                            children: [
                                              Text(invoiceDataFiltered[index]
                                                  .tglDokumenFormat),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color:
                                                      invoiceDataFiltered[index]
                                                                  .status ==
                                                              'DRAFT'
                                                          ? Colors.pink[100]
                                                              .withOpacity(.5)
                                                          : Colors.indigo[100]
                                                              .withOpacity(.5),
                                                ),
                                                child: Text(
                                                  invoiceDataFiltered[index]
                                                      .status,
                                                  style: TextStyle(
                                                    color: invoiceDataFiltered[
                                                                    index]
                                                                .status ==
                                                            'DRAFT'
                                                        ? Colors.pink
                                                        : Colors.indigo,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          trailing: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                CurrencyFormat.convertToIdr(
                                                  int.parse(
                                                      invoiceDataFiltered[index]
                                                          .grandTotal),
                                                  0,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: invoiceDataFiltered[
                                                                  index]
                                                              .statusLunas ==
                                                          '0'
                                                      ? Colors.orange[100]
                                                          .withOpacity(.5)
                                                      : Colors.green[100]
                                                          .withOpacity(.5),
                                                ),
                                                child: Text(
                                                  invoiceDataFiltered[index]
                                                              .statusLunas ==
                                                          '0'
                                                      ? 'Belum Lunas'
                                                      : 'Lunas',
                                                  style: TextStyle(
                                                    color: invoiceDataFiltered[
                                                                    index]
                                                                .statusLunas ==
                                                            '0'
                                                        ? Colors.orange
                                                        : Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                child: Center(
                                  child: Text(
                                    'Data tidak ditemukan',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.grey[200],
                                width: 1,
                              ),
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            padding: EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                            ),
                            child: invoiceDataSelected != null
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              invoiceDataSelected
                                                  .tglDokumenFormat,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Icon(
                                              Icons.access_time_outlined,
                                              color: Colors.grey,
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: invoiceDataSelected
                                                            .status ==
                                                        'DRAFT'
                                                    ? Colors.pink[100]
                                                        .withOpacity(.5)
                                                    : Colors.indigo[100]
                                                        .withOpacity(.5),
                                              ),
                                              child: Text(
                                                invoiceDataSelected.status,
                                                style: TextStyle(
                                                  color: invoiceDataSelected
                                                              .status ==
                                                          'DRAFT'
                                                      ? Colors.pink
                                                      : Colors.indigo,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: invoiceDataSelected
                                                            .statusLunas ==
                                                        '0'
                                                    ? Colors.orange[100]
                                                        .withOpacity(.5)
                                                    : Colors.green[100]
                                                        .withOpacity(.5),
                                              ),
                                              child: Text(
                                                invoiceDataSelected
                                                            .statusLunas ==
                                                        '0'
                                                    ? 'BELUM LUNAS'
                                                    : 'LUNAS',
                                                style: TextStyle(
                                                  color: invoiceDataSelected
                                                              .statusLunas ==
                                                          '0'
                                                      ? Colors.orange
                                                      : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.blue[100]
                                                    .withOpacity(.5),
                                              ),
                                              child: Text(
                                                invoiceDataSelected
                                                        .metodeBayar ??
                                                    '-',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            // send to whatsapp
                                            // if (invoiceDataSelected.status ==
                                            //     "DRAFT")
                                            Material(
                                              child: InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return WillPopScope(
                                                          onWillPop: () async =>
                                                              false,
                                                          child: AlertDialog(
                                                            scrollable: true,
                                                            title: Text(
                                                                "Konfirmasi Whatsapp"),
                                                            // content: Text(
                                                            //     "Apakah anda yakin ingin mengirim invoice ini?"),
                                                            // Input no Whatsapp
                                                            content: SizedBox(
                                                              height: 100,
                                                              child: Column(
                                                                children: [
                                                                  TextFormField(
                                                                    controller:
                                                                        _noWaController,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .number,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "No Whatsapp",
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                    "Batal"),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  // Navigator.pop(
                                                                  //     context);
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      .unfocus();
                                                                  await EasyLoading
                                                                      .show(
                                                                    status:
                                                                        'loading...',
                                                                    maskType:
                                                                        EasyLoadingMaskType
                                                                            .black,
                                                                    dismissOnTap:
                                                                        false,
                                                                  );
                                                                  await futureSendWa(
                                                                          invoiceDataSelected
                                                                              .id)
                                                                      .then(
                                                                          (value) {
                                                                    if (value
                                                                        .success) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        content:
                                                                            Text("Invoice berhasil dikirim"),
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                      ));
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                              SnackBar(
                                                                        content:
                                                                            Text("Invoice gagal dikirim"),
                                                                        backgroundColor:
                                                                            Colors.red,
                                                                      ));
                                                                    }
                                                                    if (EasyLoading
                                                                        .isShow) {
                                                                      EasyLoading
                                                                          .dismiss();
                                                                    }
                                                                    Navigator.pop(
                                                                        context);
                                                                  }).onError((error,
                                                                          stackTrace) {
                                                                    print(
                                                                        error);
                                                                    print(
                                                                        stackTrace);
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                            SnackBar(
                                                                      content: Text(
                                                                          "Invoice gagal dikirim"),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
                                                                    ));
                                                                    if (EasyLoading
                                                                        .isShow) {
                                                                      EasyLoading
                                                                          .dismiss();
                                                                    }
                                                                    Navigator.pop(
                                                                        context);
                                                                  });
                                                                  if (EasyLoading
                                                                      .isShow) {
                                                                    await EasyLoading
                                                                        .dismiss();
                                                                  }
                                                                },
                                                                child: Text(
                                                                    "Kirim"),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: Container(
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Colors.green[600]
                                                        .withOpacity(.8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.green
                                                            .withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 2,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Share to: ",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      Image.asset(
                                                        'images/whatsapp.png',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          invoiceDataSelected.kode ?? '-',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.pink.shade300,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                  size: 14,
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
                                                Text(
                                                  invoiceDataSelected.pelanggan,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Icon(
                                            //       Icons.person,
                                            //       color: Colors.black,
                                            //       size: 14,
                                            //     ),
                                            //     SizedBox(
                                            //       width: 3,
                                            //     ),
                                            //     Text(
                                            //       invoiceDataSelected.pelanggan,
                                            //       style: TextStyle(
                                            //         fontWeight: FontWeight.bold,
                                            //         fontSize: 16,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total Tagihan: " +
                                                  CurrencyFormat.convertToIdr(
                                                    int.parse(
                                                        invoiceDataSelected
                                                            .grandTotal),
                                                    0,
                                                  ),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "Nominal Bayar: " +
                                              CurrencyFormat.convertToIdr(
                                                int.parse(invoiceDataSelected
                                                    .nominalBayar),
                                                0,
                                              ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "Sisa Tagihan: " +
                                              CurrencyFormat.convertToIdr(
                                                int.parse(invoiceDataSelected
                                                    .sisaTagihan),
                                                0,
                                              ),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // Divider(),
                                        // if Draft add Button Edit
                                        if (invoiceDataSelected.status ==
                                            'DRAFT')
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  c.edit(
                                                      invoiceDataSelected.id);
                                                  print(c.isEdit);
                                                  print(c.invoiceId);
                                                  c.setActivePage("penjualan");
                                                  c.setReload(false);
                                                  c.setResetProduk(false);
                                                  widget.refresh();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.indigo,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                child: Text('EDIT'),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          scrollable: true,
                                                          title: Text(
                                                              "Konfirmasi"),
                                                          content: Text(
                                                              "Apakah anda yakin ingin menghapus invoice ini?"),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                                  Text("Batal"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text("Ya"),
                                                              onPressed: () {
                                                                futureInvoiceDelete(
                                                                        invoiceDataSelected
                                                                            .id)
                                                                    .then(
                                                                        (value) async {
                                                                  if (value
                                                                      .success) {
                                                                    setState(
                                                                        () {
                                                                      invoiceData =
                                                                          [];
                                                                      invoiceDataFiltered =
                                                                          [];
                                                                      summary =
                                                                          null;
                                                                      invoiceDataSelected =
                                                                          null;
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          value
                                                                              .message,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                    await futureInvoice().then(
                                                                        (value) {
                                                                      if (value
                                                                          .success) {
                                                                        if (value.data ==
                                                                            null) {
                                                                          setState(
                                                                              () {
                                                                            invoiceData =
                                                                                [];
                                                                            invoiceDataFiltered =
                                                                                [];
                                                                            summary =
                                                                                null;
                                                                          });
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            invoiceData =
                                                                                value.data.listInvoice;
                                                                            invoiceDataFiltered =
                                                                                invoiceData;
                                                                            summary =
                                                                                value.data.summary;
                                                                          });
                                                                        }
                                                                      } else {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                            content:
                                                                                Text(value.message),
                                                                          ),
                                                                        );
                                                                      }
                                                                    }).onError(
                                                                        (onError,
                                                                            stackTrace) {
                                                                      print(
                                                                          "ERRRORRRRRR");
                                                                      print(onError
                                                                          .toString());
                                                                      print(
                                                                          stackTrace);
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text(onError.toString()),
                                                                        ),
                                                                      );
                                                                    });
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          value
                                                                              .message,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                }).catchError(
                                                                        (onError) {
                                                                  print(
                                                                      "ERRRORRRR");
                                                                  print(onError
                                                                      .toString());
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        onError
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.red,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                child: Text('DELETE'),
                                              ),
                                            ],
                                          ),
                                        if (invoiceDataSelected.status ==
                                                'PUBLISHED' &&
                                            invoiceDataSelected.isSinkron ==
                                                '0')
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          scrollable: true,
                                                          title: Text(
                                                              "Konfirmasi"),
                                                          content: Text(
                                                              "Apakah anda yakin ingin membatalkan invoice ini?"),
                                                          actions: [
                                                            TextButton(
                                                              child:
                                                                  Text("Batal"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text("Ya"),
                                                              onPressed: () {
                                                                futureInvoiceCancel(
                                                                        invoiceDataSelected
                                                                            .id)
                                                                    .then(
                                                                        (value) async {
                                                                  if (value
                                                                      .success) {
                                                                    setState(
                                                                        () {
                                                                      invoiceData =
                                                                          [];
                                                                      invoiceDataFiltered =
                                                                          [];
                                                                      summary =
                                                                          null;
                                                                      invoiceDataSelected =
                                                                          null;
                                                                    });
                                                                    c.setReload(
                                                                        true);
                                                                    Navigator.pop(
                                                                        context);
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          value
                                                                              .message,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                    await futureInvoice().then(
                                                                        (value) {
                                                                      if (value
                                                                          .success) {
                                                                        if (value.data ==
                                                                            null) {
                                                                          setState(
                                                                              () {
                                                                            invoiceData =
                                                                                [];
                                                                            invoiceDataFiltered =
                                                                                [];
                                                                            summary =
                                                                                null;
                                                                          });
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            invoiceData =
                                                                                value.data.listInvoice;
                                                                            invoiceDataFiltered =
                                                                                invoiceData;
                                                                            summary =
                                                                                value.data.summary;
                                                                          });
                                                                        }
                                                                      } else {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                            content:
                                                                                Text(value.message),
                                                                          ),
                                                                        );
                                                                      }
                                                                    }).onError(
                                                                        (onError,
                                                                            stackTrace) {
                                                                      print(
                                                                          "ERRRORRRRRR");
                                                                      print(onError
                                                                          .toString());
                                                                      print(
                                                                          stackTrace);
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text(onError.toString()),
                                                                        ),
                                                                      );
                                                                    });
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                          value
                                                                              .message,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                }).catchError(
                                                                        (onError) {
                                                                  print(
                                                                      "ERRRORRRR");
                                                                  print(onError
                                                                      .toString());
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        onError
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.orange,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                child: Text('CANCEL'),
                                              ),
                                            ],
                                          ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.info,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Pilih Invoice'),
                                    ],
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.grey[200],
                                width: 1,
                              ),
                            ),
                            margin: EdgeInsets.only(
                              bottom: 5,
                              left: 5,
                              right: 5,
                            ),
                            padding: EdgeInsets.all(10),
                            child: invoiceDataSelected != null
                                ? Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: detailInvoice.length,
                                          itemBuilder: (context, index) {
                                            int length = invoiceDataSelected
                                                .detailInvoice
                                                .where((element) =>
                                                    element.rowUniqueId ==
                                                    detailInvoice
                                                        .elementAt(index)
                                                        .rowUniqueId)
                                                .length;
                                            print("LENGTH");
                                            print(length);
                                            return Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Colors.blue[200],
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: ListTile(
                                                dense: true,
                                                title: Text(
                                                  detailInvoice
                                                      .elementAt(index)
                                                      .produk,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  length.toString() +
                                                      ' x ' +
                                                      CurrencyFormat
                                                          .convertToIdr(
                                                        int.parse(detailInvoice
                                                            .elementAt(index)
                                                            .harga),
                                                        0,
                                                      ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: Text(
                                                  CurrencyFormat.convertToIdr(
                                                    int.parse(detailInvoice
                                                            .elementAt(index)
                                                            .harga) *
                                                        length,
                                                    0,
                                                  ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.info,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Pilih Invoice'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
