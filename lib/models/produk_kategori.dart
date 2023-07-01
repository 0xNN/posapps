// To parse this JSON data, do
//
//     final produkKategoriRes = produkKategoriResFromMap(jsonString);

import 'dart:convert';

class ProdukKategoriRes {
  bool success;
  String message;
  List<ProdukKategoriData> data;

  ProdukKategoriRes({
    this.success,
    this.message,
    this.data,
  });

  factory ProdukKategoriRes.fromJson(String str) =>
      ProdukKategoriRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProdukKategoriRes.fromMap(Map<String, dynamic> json) =>
      ProdukKategoriRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<ProdukKategoriData>.from(
                json["data"].map((x) => ProdukKategoriData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class ProdukKategoriData {
  String id;
  String kode;
  String nama;
  String deksripsi;
  String status;
  String rowStatus;
  String createdAt;
  String createdById;
  String updatedAt;
  String updatedById;
  String parentId;
  String isDefault;

  ProdukKategoriData({
    this.id,
    this.kode,
    this.nama,
    this.deksripsi,
    this.status,
    this.rowStatus,
    this.createdAt,
    this.createdById,
    this.updatedAt,
    this.updatedById,
    this.parentId,
    this.isDefault,
  });

  factory ProdukKategoriData.fromJson(String str) =>
      ProdukKategoriData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProdukKategoriData.fromMap(Map<String, dynamic> json) =>
      ProdukKategoriData(
        id: json["Id"].toString(),
        kode: json["Kode"].toString(),
        nama: json["Nama"].toString(),
        deksripsi: json["Deksripsi"].toString(),
        status: json["Status"].toString(),
        rowStatus: json["RowStatus"].toString(),
        createdAt: json["CreatedAt"].toString(),
        createdById: json["CreatedById"].toString(),
        updatedAt: json["UpdatedAt"].toString(),
        updatedById: json["UpdatedById"].toString(),
        parentId: json["ParentId"].toString(),
        isDefault: json["IsDefault"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Kode": kode,
        "Nama": nama,
        "Deksripsi": deksripsi,
        "Status": status,
        "RowStatus": rowStatus,
        "CreatedAt": createdAt,
        "CreatedById": createdById,
        "UpdatedAt": updatedAt,
        "UpdatedById": updatedById,
        "ParentId": parentId,
        "IsDefault": isDefault,
      };
}
