import 'package:posapps/models/produk.dart';

class ProdukDatasArgs {
  final List<ProdukData> jumlahProduk;
  final Set<ProdukData> produkDatas;
  final double totalHarga;
  final int diskon;
  final String salesmanId;
  final String pelangganId;
  final String invoiceDetail;

  ProdukDatasArgs(
    this.jumlahProduk,
    this.produkDatas,
    this.totalHarga,
    this.diskon,
    this.salesmanId,
    this.pelangganId,
    this.invoiceDetail,
  );
}

class BayarDatasArgs {
  final double totalHarga;
  final int penerimaanTunai;
  final int kembalian;

  BayarDatasArgs(this.totalHarga, this.penerimaanTunai, this.kembalian);
}
