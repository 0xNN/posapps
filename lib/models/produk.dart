// To parse this JSON data, do
//
//     final produkRes = produkResFromMap(jsonString);

import 'dart:convert';

class ProdukRes {
  bool success;
  String message;
  List<ProdukData> data;

  ProdukRes({
    this.success,
    this.message,
    this.data,
  });

  factory ProdukRes.fromJson(String str) => ProdukRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProdukRes.fromMap(Map<String, dynamic> json) => ProdukRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ProdukData>.from(
                json["data"].map((x) => ProdukData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class ProdukData {
  String produkId;
  String produk;
  String kodeProduk;
  String gudangId;
  String hargaBeli;
  String hargaJual;
  String uom;
  String noSerial;
  String stok;
  String expDate;
  String produkKategoriId;
  String kodeReff;
  String rowUniqueId;

  ProdukData({
    this.produkId,
    this.produk,
    this.kodeProduk,
    this.gudangId,
    this.hargaBeli,
    this.hargaJual,
    this.uom,
    this.noSerial,
    this.stok,
    this.expDate,
    this.produkKategoriId,
    this.kodeReff,
    this.rowUniqueId,
  });

  factory ProdukData.fromJson(String str) =>
      ProdukData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProdukData.fromMap(Map<String, dynamic> json) => ProdukData(
        produkId: json["ProdukId"] == null ? "-" : json["ProdukId"].toString(),
        produk: json["Produk"] == null ? "-" : json["Produk"].toString(),
        kodeProduk:
            json["KodeProduk"] == null ? "-" : json["KodeProduk"].toString(),
        gudangId: json["GudangId"] == null ? "-" : json["GudangId"].toString(),
        hargaBeli:
            json["HargaBeli"] == null ? "-" : json["HargaBeli"].toString(),
        hargaJual:
            json["HargaJual"] == null ? "-" : json["HargaJual"].toString(),
        uom: json["Uom"] == null ? "-" : json["Uom"].toString(),
        noSerial: json["NoSerial"] == null ? null : json["NoSerial"].toString(),
        stok: json["Stok"] == null ? "-" : json["Stok"].toString(),
        expDate: json["ExpDate"] == null ? "-" : json["ExpDate"].toString(),
        produkKategoriId: json["ProdukKategoriId"] == null
            ? "-"
            : json["ProdukKategoriId"].toString(),
        kodeReff: json["KodeReff"] == null ? "-" : json["KodeReff"].toString(),
        rowUniqueId:
            json["RowUniqueId"] == null ? "-" : json["RowUniqueId"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "ProdukId": produkId,
        "Produk": produk,
        "KodeProduk": kodeProduk,
        "GudangId": gudangId,
        "HargaBeli": hargaBeli,
        "HargaJual": hargaJual,
        "Uom": uom,
        "NoSerial": noSerial,
        "Stok": stok,
        "ExpDate": expDate,
        "ProdukKategoriId": produkKategoriId,
        "KodeReff": kodeReff,
        "RowUniqueId": rowUniqueId,
      };
}
