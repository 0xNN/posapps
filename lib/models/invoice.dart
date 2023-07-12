// To parse  this JSON data, do
//
//     final invoiceRes = invoiceResFromMap(jsonString);

import 'dart:convert';

class InvoiceRes {
  bool success;
  String message;
  InvoiceData data;

  InvoiceRes({
    this.success,
    this.message,
    this.data,
  });

  factory InvoiceRes.fromJson(String str) =>
      InvoiceRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceRes.fromMap(Map<String, dynamic> json) => InvoiceRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : InvoiceData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": data.toMap(),
      };
}

class InvoiceData {
  DataSummary summary;
  List<ListInvoice> listInvoice;

  InvoiceData({
    this.summary,
    this.listInvoice,
  });

  factory InvoiceData.fromJson(String str) =>
      InvoiceData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceData.fromMap(Map<String, dynamic> json) => InvoiceData(
        summary: json["summary"] == null
            ? null
            : DataSummary.fromMap(json["summary"]),
        listInvoice: json["list_invoice"] == null
            ? []
            : List<ListInvoice>.from(
                json["list_invoice"].map((x) => ListInvoice.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "summary": summary.toMap(),
        "list_invoice": listInvoice == null
            ? []
            : List<dynamic>.from(listInvoice.map((x) => x.toMap())),
      };
}

class ListInvoice {
  String id;
  String tglDokumenFormat;
  String salesmanId;
  String pelangganId;
  String rekeningId;
  String diskonNominal;
  double diskonPersen;
  String pembulatan;
  String subTotal;
  String ppn;
  String noTelpPelanggan;
  String nominalBayar;
  String status;
  String statusLunas;
  String salesman;
  String pelanggan;
  String metodeBayar;
  String kode;
  String grandTotal;
  String sisaTagihan;
  List<DetailInvoice> detailInvoice;

  ListInvoice({
    this.id,
    this.tglDokumenFormat,
    this.salesmanId,
    this.pelangganId,
    this.rekeningId,
    this.diskonNominal,
    this.diskonPersen,
    this.pembulatan,
    this.subTotal,
    this.ppn,
    this.noTelpPelanggan,
    this.nominalBayar,
    this.status,
    this.statusLunas,
    this.salesman,
    this.pelanggan,
    this.metodeBayar,
    this.kode,
    this.grandTotal,
    this.sisaTagihan,
    this.detailInvoice,
  });

  factory ListInvoice.fromJson(String str) =>
      ListInvoice.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ListInvoice.fromMap(Map<String, dynamic> json) => ListInvoice(
        id: json["Id"],
        tglDokumenFormat: json["TglDokumenFormat"].toString(),
        salesmanId: json["SalesmanId"].toString(),
        pelangganId: json["PelangganId"].toString(),
        rekeningId: json["RekeningId"].toString(),
        diskonNominal: json["DiskonNominal"].toString(),
        diskonPersen: json["DiskonPersen"].toDouble(),
        pembulatan: json["Pembulatan"].toString(),
        subTotal: json["SubTotal"].toString(),
        ppn: json["PPN"].toString(),
        noTelpPelanggan: json["NoTelpPelanggan"].toString(),
        nominalBayar: json["NominalBayar"].toString(),
        status: json["Status"].toString(),
        statusLunas: json["StatusLunas"],
        salesman: json["Salesman"],
        pelanggan: json["Pelanggan"],
        metodeBayar: json["MetodeBayar"],
        kode: json["Kode"],
        grandTotal: json["GrandTotal"].toString(),
        sisaTagihan: json["SisaTagihan"].toString(),
        detailInvoice: json["DetailInvoice"] == null
            ? []
            : List<DetailInvoice>.from(
                json["DetailInvoice"].map((x) => DetailInvoice.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "TglDokumenFormat": tglDokumenFormat,
        "SalesmanId": salesmanId,
        "PelangganId": pelangganId,
        "RekeningId": rekeningId,
        "DiskonNominal": diskonNominal,
        "DiskonPersen": diskonPersen,
        "Pembulatan": pembulatan,
        "SubTotal": subTotal,
        "PPN": ppn,
        "NoTelpPelanggan": noTelpPelanggan,
        "NominalBayar": nominalBayar,
        "Status": status,
        "StatusLunas": statusLunas,
        "Salesman": salesman,
        "Pelanggan": pelanggan,
        "MetodeBayar": metodeBayar,
        "Kode": kode,
        "GrandTotal": grandTotal,
        "SisaTagihan": sisaTagihan,
        "DetailInvoice": detailInvoice == null
            ? []
            : List<dynamic>.from(detailInvoice.map((x) => x.toMap())),
      };
}

class DetailInvoice {
  String invoiceId;
  String rowUniqueId;
  String produkId;
  String produk;
  String gudangId;
  String qty;
  String harga;
  String diskonNominal;
  String noSerial;
  String tglKadaluarsa;

  DetailInvoice({
    this.invoiceId,
    this.rowUniqueId,
    this.produkId,
    this.produk,
    this.gudangId,
    this.qty,
    this.harga,
    this.diskonNominal,
    this.noSerial,
    this.tglKadaluarsa,
  });

  factory DetailInvoice.fromJson(String str) =>
      DetailInvoice.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DetailInvoice.fromMap(Map<String, dynamic> json) => DetailInvoice(
        invoiceId: json["InvoiceId"],
        rowUniqueId: json["RowUniqueId"],
        produkId: json["ProdukId"],
        produk: json["Produk"],
        gudangId: json["GudangId"],
        qty: json["Qty"].toString(),
        harga: json["Harga"],
        diskonNominal: json["DiskonNominal"],
        noSerial: json["NoSerial"],
        tglKadaluarsa: json["TglKadaluarsa"],
      );

  Map<String, dynamic> toMap() => {
        "InvoiceId": invoiceId,
        "RowUniqueId": rowUniqueId,
        "ProdukId": produkId,
        "Produk": produk,
        "GudangId": gudangId,
        "Qty": qty,
        "Harga": harga,
        "DiskonNominal": diskonNominal,
        "NoSerial": noSerial,
        "TglKadaluarsa": tglKadaluarsaValues.reverse[tglKadaluarsa],
      };
}

enum TglKadaluarsa { THE_00000000000000000000 }

final tglKadaluarsaValues = EnumValues(
    {"0000-00-00 00:00:00.000000": TglKadaluarsa.THE_00000000000000000000});

enum Status { DRAFT, PUBLISHED }

final statusValues =
    EnumValues({"DRAFT": Status.DRAFT, "PUBLISHED": Status.PUBLISHED});

class DataSummary {
  String totalTagihan;
  String totalBayar;
  String sisaTagihan;

  DataSummary({
    this.totalTagihan,
    this.totalBayar,
    this.sisaTagihan,
  });

  factory DataSummary.fromJson(String str) =>
      DataSummary.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DataSummary.fromMap(Map<String, dynamic> json) => DataSummary(
        totalTagihan: json["TotalTagihan"],
        totalBayar: json["TotalBayar"],
        sisaTagihan: json["SisaTagihan"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "TotalTagihan": totalTagihan,
        "TotalBayar": totalBayar,
        "SisaTagihan": sisaTagihan,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
