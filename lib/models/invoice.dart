// To parse this JSON data, do
//
//     final invoiceRes = invoiceResFromMap(jsonString);

import 'dart:convert';

class InvoiceRes {
  bool success;
  String message;
  List<InvoiceData> data;

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
        data: json["data"] == null
            ? []
            : List<InvoiceData>.from(
                json["data"].map((x) => InvoiceData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class InvoiceData {
  String id;
  String tglDokumenFormat;
  String salesmanId;
  String pelangganId;
  String rekeningId;
  String diskonNominal;
  String subTotal;
  String ppn;
  String nominalBayar;
  String status;
  String statusLunas;
  String salesman;
  String pelanggan;
  String metodeBayar;
  int grandTotal;
  List<DetailInvoice> detailInvoice;

  InvoiceData({
    this.id,
    this.tglDokumenFormat,
    this.salesmanId,
    this.pelangganId,
    this.rekeningId,
    this.diskonNominal,
    this.subTotal,
    this.ppn,
    this.nominalBayar,
    this.status,
    this.statusLunas,
    this.salesman,
    this.pelanggan,
    this.metodeBayar,
    this.grandTotal,
    this.detailInvoice,
  });

  factory InvoiceData.fromJson(String str) =>
      InvoiceData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceData.fromMap(Map<String, dynamic> json) => InvoiceData(
        id: json["Id"],
        tglDokumenFormat: json["TglDokumenFormat"],
        salesmanId: json["SalesmanId"],
        pelangganId: json["PelangganId"],
        rekeningId: json["RekeningId"],
        diskonNominal: json["DiskonNominal"],
        subTotal: json["SubTotal"],
        ppn: json["PPN"],
        nominalBayar: json["NominalBayar"],
        status: json["Status"],
        statusLunas: json["StatusLunas"],
        salesman: json["Salesman"],
        pelanggan: json["Pelanggan"] == null ? "-" : json["Pelanggan"],
        metodeBayar: json["MetodeBayar"],
        grandTotal: json["GrandTotal"],
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
        "SubTotal": subTotal,
        "PPN": ppn,
        "NominalBayar": nominalBayar,
        "Status": status,
        "StatusLunas": statusLunas,
        "Salesman": salesman,
        "Pelanggan": pelanggan,
        "MetodeBayar": metodeBayar,
        "GrandTotal": grandTotal,
        "DetailInvoice": detailInvoice == null
            ? []
            : List<dynamic>.from(detailInvoice.map((x) => x.toMap())),
      };
}

class DetailInvoice {
  String invoiceId;
  String rowUniqueId;
  String produkId;
  String gudangId;
  int qty;
  String harga;
  String diskonNominal;
  String noSerial;
  String tglKadaluarsa;

  DetailInvoice({
    this.invoiceId,
    this.rowUniqueId,
    this.produkId,
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
        gudangId: json["GudangId"],
        qty: json["Qty"],
        harga: json["Harga"],
        diskonNominal: json["DiskonNominal"],
        noSerial: json["NoSerial"],
        tglKadaluarsa: json["TglKadaluarsa"],
      );

  Map<String, dynamic> toMap() => {
        "InvoiceId": invoiceId,
        "RowUniqueId": rowUniqueId,
        "ProdukId": produkId,
        "GudangId": gudangId,
        "Qty": qty,
        "Harga": harga,
        "DiskonNominal": diskonNominal,
        "NoSerial": noSerial,
        "TglKadaluarsa": tglKadaluarsa,
      };
}
