// To parse this JSON data, do
//
//     final salesmanRes = salesmanResFromMap(jsonString);

import 'dart:convert';

class SalesmanRes {
  bool success;
  String message;
  List<SalesmanData> data;

  SalesmanRes({
    this.success,
    this.message,
    this.data,
  });

  factory SalesmanRes.fromJson(String str) =>
      SalesmanRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesmanRes.fromMap(Map<String, dynamic> json) => SalesmanRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SalesmanData>.from(
                json["data"].map((x) => SalesmanData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class SalesmanData {
  String id;
  String kode;
  String nama;
  String organisasiId;
  String titleId;
  String alamat;
  String kotaId;
  String noTelp;
  String email;
  String noPajak;
  String status;
  String rowStatus;
  String createdAt;
  String createdById;
  String updatedAt;
  String updatedById;
  String isSales;
  String maxAr;
  String maxStok;
  String maxNp;
  String isBlokir;
  String keteranganBlacklist;
  String supervisorId;

  SalesmanData({
    this.id,
    this.kode,
    this.nama,
    this.organisasiId,
    this.titleId,
    this.alamat,
    this.kotaId,
    this.noTelp,
    this.email,
    this.noPajak,
    this.status,
    this.rowStatus,
    this.createdAt,
    this.createdById,
    this.updatedAt,
    this.updatedById,
    this.isSales,
    this.maxAr,
    this.maxStok,
    this.maxNp,
    this.isBlokir,
    this.keteranganBlacklist,
    this.supervisorId,
  });

  factory SalesmanData.fromJson(String str) =>
      SalesmanData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesmanData.fromMap(Map<String, dynamic> json) => SalesmanData(
        id: json["Id"].toString(),
        kode: json["Kode"].toString(),
        nama: json["Nama"].toString(),
        organisasiId: json["OrganisasiId"].toString(),
        titleId: json["TitleId"].toString(),
        alamat: json["Alamat"].toString(),
        kotaId: json["KotaId"].toString(),
        noTelp: json["NoTelp"].toString(),
        email: json["Email"].toString(),
        noPajak: json["NoPajak"].toString(),
        status: json["Status"].toString(),
        rowStatus: json["RowStatus"].toString(),
        createdAt: json["CreatedAt"].toString(),
        createdById: json["CreatedById"].toString(),
        updatedAt: json["UpdatedAt"].toString(),
        updatedById: json["UpdatedById"].toString(),
        isSales: json["IsSales"].toString(),
        maxAr: json["MaxAR"].toString(),
        maxStok: json["MaxStok"].toString(),
        maxNp: json["MaxNP"].toString(),
        isBlokir: json["IsBlokir"].toString(),
        keteranganBlacklist: json["KeteranganBlacklist"].toString(),
        supervisorId: json["SupervisorId"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Kode": kode,
        "Nama": nama,
        "OrganisasiId": organisasiId,
        "TitleId": titleId,
        "Alamat": alamat,
        "KotaId": kotaId,
        "NoTelp": noTelp,
        "Email": email,
        "NoPajak": noPajak,
        "Status": status,
        "RowStatus": rowStatus,
        "CreatedAt": createdAt,
        "CreatedById": createdById,
        "UpdatedAt": updatedAt,
        "UpdatedById": updatedById,
        "IsSales": isSales,
        "MaxAR": maxAr,
        "MaxStok": maxStok,
        "MaxNP": maxNp,
        "IsBlokir": isBlokir,
        "KeteranganBlacklist": keteranganBlacklist,
        "SupervisorId": supervisorId,
      };
}
