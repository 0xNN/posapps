// To parse  this JSON data, do
//
//     final invoiceSaveRes = invoiceSaveResFromMap(jsonString);

import 'dart:convert';

class InvoiceSaveRes {
  bool success;
  String message;
  InvoiceSaveData data;

  InvoiceSaveRes({
    this.success,
    this.message,
    this.data,
  });

  factory InvoiceSaveRes.fromJson(String str) =>
      InvoiceSaveRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceSaveRes.fromMap(Map<String, dynamic> json) => InvoiceSaveRes(
        success: json["success"],
        message: json["message"],
        data:
            json["data"] == null ? null : InvoiceSaveData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": data.toMap(),
      };
}

class InvoiceSaveData {
  String kode;
  String tglDokumen;
  String salesmanId;
  String pelangganId;
  String diskonNominal;
  String subTotal;
  String ppn;
  String nominalBayar;
  String rekeningId;
  String status;
  String statusLunas;
  int rowStatus;
  String updatedBy;
  String updatedAt;
  String noTelp;
  String invoiceId;
  List<InvoiceSaveDetailInvoice> detailInvoice;

  InvoiceSaveData({
    this.kode,
    this.tglDokumen,
    this.salesmanId,
    this.pelangganId,
    this.diskonNominal,
    this.subTotal,
    this.ppn,
    this.nominalBayar,
    this.rekeningId,
    this.status,
    this.statusLunas,
    this.rowStatus,
    this.updatedBy,
    this.updatedAt,
    this.noTelp,
    this.invoiceId,
    this.detailInvoice,
  });

  factory InvoiceSaveData.fromJson(String str) =>
      InvoiceSaveData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceSaveData.fromMap(Map<String, dynamic> json) => InvoiceSaveData(
        kode: json["Kode"] == null ? null : json["Kode"].toString(),
        tglDokumen:
            json["TglDokumen"] == null ? null : json["TglDokumen"].toString(),
        salesmanId:
            json["SalesmanId"] == null ? null : json["SalesmanId"].toString(),
        pelangganId:
            json["PelangganId"] == null ? null : json["PelangganId"].toString(),
        diskonNominal: json["DiskonNominal"] == null
            ? null
            : json["DiskonNominal"].toString(),
        subTotal: json["SubTotal"] == null ? null : json["SubTotal"].toString(),
        ppn: json["PPN"] == null ? null : json["PPN"].toString(),
        nominalBayar: json["NominalBayar"] == null
            ? null
            : json["NominalBayar"].toString(),
        rekeningId:
            json["RekeningId"] == null ? null : json["RekeningId"].toString(),
        status: json["Status"] == null ? null : json["Status"].toString(),
        statusLunas:
            json["StatusLunas"] == null ? null : json["StatusLunas"].toString(),
        rowStatus: json["RowStatus"] == null ? null : json["RowStatus"],
        updatedBy:
            json["UpdatedBy"] == null ? null : json["UpdatedBy"].toString(),
        updatedAt:
            json["UpdatedAt"] == null ? null : json["UpdatedAt"].toString(),
        noTelp: json["NoTelp"] == null ? null : json["NoTelp"].toString(),
        invoiceId:
            json["InvoiceId"] == null ? null : json["InvoiceId"].toString(),
        detailInvoice: json["InvoiceSaveDetailInvoice"] == null
            ? []
            : List<InvoiceSaveDetailInvoice>.from(
                json["InvoiceSaveDetailInvoice"]
                    .map((x) => InvoiceSaveDetailInvoice.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "Kode": kode,
        "TglDokumen": tglDokumen,
        "SalesmanId": salesmanId,
        "PelangganId": pelangganId,
        "DiskonNominal": diskonNominal,
        "SubTotal": subTotal,
        "PPN": ppn,
        "NominalBayar": nominalBayar,
        "RekeningId": rekeningId,
        "Status": status,
        "StatusLunas": statusLunas,
        "RowStatus": rowStatus,
        "UpdatedBy": updatedBy,
        "UpdatedAt": updatedAt,
        "NoTelp": noTelp,
        "InvoiceId": invoiceId,
        "InvoiceSaveDetailInvoice": detailInvoice == null
            ? []
            : List<dynamic>.from(detailInvoice.map((x) => x.toMap())),
      };
}

class InvoiceSaveDetailInvoice {
  String invoiceId;
  String rowUniqueId;
  String produkId;
  String gudangId;
  String qty;
  String harga;
  String diskonNominal;
  String noSerial;
  String tglKadaluarsa;

  InvoiceSaveDetailInvoice({
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

  factory InvoiceSaveDetailInvoice.fromJson(String str) =>
      InvoiceSaveDetailInvoice.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceSaveDetailInvoice.fromMap(Map<String, dynamic> json) =>
      InvoiceSaveDetailInvoice(
        invoiceId:
            json["InvoiceId"] == null ? null : json["InvoiceId"].toString(),
        rowUniqueId:
            json["RowUniqueId"] == null ? null : json["RowUniqueId"].toString(),
        produkId: json["ProdukId"] == null ? null : json["ProdukId"].toString(),
        gudangId: json["GudangId"] == null ? null : json["GudangId"].toString(),
        qty: json["Qty"] == null ? null : json["Qty"].toString(),
        harga: json["Harga"] == null ? null : json["Harga"].toString(),
        diskonNominal: json["DiskonNominal"] == null
            ? null
            : json["DiskonNominal"].toString(),
        noSerial: json["NoSerial"] == null ? null : json["NoSerial"].toString(),
        tglKadaluarsa: json["TglKadaluarsa"] == null
            ? null
            : json["TglKadaluarsa"].toString(),
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
