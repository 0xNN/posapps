import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posapps/models/invoice.dart';
import 'package:http/http.dart' as http;
import 'package:posapps/resources/string.dart';
import 'package:intl/intl.dart';
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

class TransaksiPage extends StatefulWidget {
  final Function refresh;
  const TransaksiPage({Key key, this.refresh}) : super(key: key);
  static const String routeName = '/transaksi';

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final c = Get.put(Controller());
  List<InvoiceData> invoiceData = [];
  List<InvoiceData> invoiceDataFiltered = [];

  InvoiceData invoiceDataSelected;
  Set<DetailInvoice> detailInvoice = <DetailInvoice>{};

  Future<InvoiceRes> futureInvoice() async {
    String url = '${API_URL}PosApps/Invoice';
    print(url);
    Map<String, dynamic> body = {
      "InvoiceId": "",
      "Status": "",
      "StatusLunas": "",
    };
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

  @override
  void initState() {
    futureInvoice().then((value) {
      if (value.success) {
        setState(() {
          invoiceData = value.data;
          invoiceDataFiltered = value.data;
        });
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
    super.initState();
  }

  @override
  void didUpdateWidget(TransaksiPage oldWidget) {
    futureInvoice().then((value) {
      if (value.success) {
        setState(() {
          invoiceData = value.data;
        });
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
                ),
              ),
              child: Column(
                children: [
                  // Search
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Pelanggan',
                      prefixIcon: Icon(Icons.search),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey[100],
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          invoiceDataFiltered = invoiceData;
                        } else {
                          invoiceDataFiltered = invoiceData
                              .where((element) => element.pelanggan
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: invoiceDataFiltered.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              invoiceDataSelected = invoiceDataFiltered[index];
                              detailInvoice.clear();
                              for (DetailInvoice element
                                  in invoiceDataFiltered[index].detailInvoice) {
                                // check unique
                                if (detailInvoice
                                    .where((e) =>
                                        e.rowUniqueId == element.rowUniqueId)
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
                              title: Text(invoiceDataFiltered[index].pelanggan),
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
                                      borderRadius: BorderRadius.circular(5),
                                      color: invoiceDataFiltered[index]
                                                  .status ==
                                              'DRAFT'
                                          ? Colors.pink[100].withOpacity(.5)
                                          : Colors.indigo[100].withOpacity(.5),
                                    ),
                                    child: Text(
                                      invoiceDataFiltered[index].status,
                                      style: TextStyle(
                                        color:
                                            invoiceDataFiltered[index].status ==
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    CurrencyFormat.convertToIdr(
                                      invoiceDataFiltered[index].grandTotal,
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
                                      borderRadius: BorderRadius.circular(5),
                                      color: invoiceDataFiltered[index]
                                                  .statusLunas ==
                                              '0'
                                          ? Colors.orange[100].withOpacity(.5)
                                          : Colors.green[100].withOpacity(.5),
                                    ),
                                    child: Text(
                                      invoiceDataFiltered[index].statusLunas ==
                                              '0'
                                          ? 'Belum Lunas'
                                          : 'Lunas',
                                      style: TextStyle(
                                        color: invoiceDataFiltered[index]
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
                        vertical: 10,
                        horizontal: 10,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        invoiceDataSelected.tglDokumenFormat,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: invoiceDataSelected.status ==
                                                  'DRAFT'
                                              ? Colors.pink[100].withOpacity(.5)
                                              : Colors.indigo[100]
                                                  .withOpacity(.5),
                                        ),
                                        child: Text(
                                          invoiceDataSelected.status,
                                          style: TextStyle(
                                            color: invoiceDataSelected.status ==
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
                                          color:
                                              invoiceDataSelected.statusLunas ==
                                                      '0'
                                                  ? Colors.orange[100]
                                                      .withOpacity(.5)
                                                  : Colors.green[100]
                                                      .withOpacity(.5),
                                        ),
                                        child: Text(
                                          invoiceDataSelected.statusLunas == '0'
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
                                          color:
                                              Colors.blue[100].withOpacity(.5),
                                        ),
                                        child: Text(
                                          invoiceDataSelected.metodeBayar,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        invoiceDataSelected.pelanggan,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
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
                                        CurrencyFormat.convertToIdr(
                                          invoiceDataSelected.grandTotal,
                                          0,
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Divider(),
                                  // if Draft add Button Edit
                                  if (invoiceDataSelected.status == 'DRAFT')
                                    ElevatedButton(
                                      onPressed: () {
                                        c.edit(invoiceDataSelected.id);
                                        print(c.isEdit);
                                        print(c.invoiceId);
                                        c.setActivePage("penjualan");
                                        widget.refresh();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.indigo,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: Text('Edit'),
                                    )
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
                        bottom: 10,
                        left: 10,
                        right: 10,
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
                                                .produkId,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            length.toString() +
                                                ' x ' +
                                                CurrencyFormat.convertToIdr(
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
    );
  }
}
