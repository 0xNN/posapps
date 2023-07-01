import 'package:flutter/material.dart';
import 'package:posapps/models/produk.dart';
import 'package:posapps/pages/bayar.dart';
import 'package:posapps/pages/models/bayar.dart';
import 'package:posapps/pages/penjualan.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case PenjualanPage.routeName:
      return MaterialPageRoute(
        builder: (context) => PenjualanPage(
          produkDatas: settings.arguments as List<ProdukData>,
        ),
      );
    case BayarPage.routeName:
      return MaterialPageRoute(
        builder: (context) => BayarPage(
          args: settings.arguments as ProdukDatasArgs,
        ),
      );
  }
}
