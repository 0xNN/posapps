// To parse  this JSON data, do
//
//     final pelangganRes = pelangganResFromMap(jsonString);

import 'dart:convert';

class PelangganRes {
  bool success;
  String message;
  List<PelangganData> data;

  PelangganRes({
    this.success,
    this.message,
    this.data,
  });

  factory PelangganRes.fromJson(String str) =>
      PelangganRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PelangganRes.fromMap(Map<String, dynamic> json) => PelangganRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<PelangganData>.from(
                json["data"].map((x) => PelangganData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class PelangganData {
  String id;
  String kode;
  String nama;
  String pelangganKategoriId;
  String organisasiId;
  String pegawaiId;
  String akunId;
  String akunFeeId;
  String noTelp;
  String fax;
  String email;
  String website;
  String noPajak;
  String namaAkunPajak;
  String alamatAkunPajak;
  String maxArQty;
  String maxArTotal;
  String maxArWaktu;
  String maxKonsinyasiWaktu;
  String tglKonsinyasi;
  String status;
  String rowStatus;
  String createdAt;
  String createdById;
  String updatedAt;
  String updatedById;
  String statusKonsinyasi;
  String statusPlgKonsinyasi;
  String statusKreditNote;
  String statusBlacklist;
  String statusSpesialBlacklist;
  String maxOpenedBlacklist;
  String hitungBukaBlacklist;
  String keterangan;
  String feeInternal;
  String keteranganBlacklist;
  String isCn;

  PelangganData({
    this.id,
    this.kode,
    this.nama,
    this.pelangganKategoriId,
    this.organisasiId,
    this.pegawaiId,
    this.akunId,
    this.akunFeeId,
    this.noTelp,
    this.fax,
    this.email,
    this.website,
    this.noPajak,
    this.namaAkunPajak,
    this.alamatAkunPajak,
    this.maxArQty,
    this.maxArTotal,
    this.maxArWaktu,
    this.maxKonsinyasiWaktu,
    this.tglKonsinyasi,
    this.status,
    this.rowStatus,
    this.createdAt,
    this.createdById,
    this.updatedAt,
    this.updatedById,
    this.statusKonsinyasi,
    this.statusPlgKonsinyasi,
    this.statusKreditNote,
    this.statusBlacklist,
    this.statusSpesialBlacklist,
    this.maxOpenedBlacklist,
    this.hitungBukaBlacklist,
    this.keterangan,
    this.feeInternal,
    this.keteranganBlacklist,
    this.isCn,
  });

  factory PelangganData.fromJson(String str) =>
      PelangganData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PelangganData.fromMap(Map<String, dynamic> json) => PelangganData(
        id: json["Id"].toString(),
        kode: json["Kode"].toString(),
        nama: json["Nama"].toString(),
        pelangganKategoriId: json["PelangganKategoriId"].toString(),
        organisasiId: json["OrganisasiId"].toString(),
        pegawaiId: json["PegawaiId"].toString(),
        akunId: json["AkunId"].toString(),
        akunFeeId: json["AkunFeeId"].toString(),
        noTelp: json["NoTelp"].toString(),
        fax: json["Fax"].toString(),
        email: json["Email"].toString(),
        website: json["Website"].toString(),
        noPajak: json["NoPajak"].toString(),
        namaAkunPajak: json["NamaAkunPajak"].toString(),
        alamatAkunPajak: json["AlamatAkunPajak"].toString(),
        maxArQty: json["MaxARQty"].toString(),
        maxArTotal: json["MaxARTotal"].toString(),
        maxArWaktu: json["MaxARWaktu"].toString(),
        maxKonsinyasiWaktu: json["MaxKonsinyasiWaktu"].toString(),
        tglKonsinyasi: json["TglKonsinyasi"].toString(),
        status: json["Status"].toString(),
        rowStatus: json["RowStatus"].toString(),
        createdAt: json["CreatedAt"].toString(),
        createdById: json["CreatedById"].toString(),
        updatedAt: json["UpdatedAt"].toString(),
        updatedById: json["UpdatedById"].toString(),
        statusKonsinyasi: json["StatusKonsinyasi"].toString(),
        statusPlgKonsinyasi: json["StatusPlgKonsinyasi"].toString(),
        statusKreditNote: json["StatusKreditNote"].toString(),
        statusBlacklist: json["StatusBlacklist"].toString(),
        statusSpesialBlacklist: json["StatusSpesialBlacklist"].toString(),
        maxOpenedBlacklist: json["MaxOpenedBlacklist"].toString(),
        hitungBukaBlacklist: json["HitungBukaBlacklist"].toString(),
        keterangan: json["Keterangan"].toString(),
        feeInternal: json["FeeInternal"].toString(),
        keteranganBlacklist: json["KeteranganBlacklist"].toString(),
        isCn: json["IsCN"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Kode": kode,
        "Nama": nama,
        "PelangganKategoriId": pelangganKategoriId,
        "OrganisasiId": organisasiId,
        "PegawaiId": pegawaiId,
        "AkunId": akunId,
        "AkunFeeId": akunFeeId,
        "NoTelp": noTelp,
        "Fax": fax,
        "Email": email,
        "Website": website,
        "NoPajak": noPajak,
        "NamaAkunPajak": namaAkunPajak,
        "AlamatAkunPajak": alamatAkunPajak,
        "MaxARQty": maxArQty,
        "MaxARTotal": maxArTotal,
        "MaxARWaktu": maxArWaktu,
        "MaxKonsinyasiWaktu": maxKonsinyasiWaktu,
        "TglKonsinyasi": tglKonsinyasi,
        "Status": status,
        "RowStatus": rowStatus,
        "CreatedAt": createdAt,
        "CreatedById": createdById,
        "UpdatedAt": updatedAt,
        "UpdatedById": updatedById,
        "StatusKonsinyasi": statusKonsinyasi,
        "StatusPlgKonsinyasi": statusPlgKonsinyasi,
        "StatusKreditNote": statusKreditNote,
        "StatusBlacklist": statusBlacklist,
        "StatusSpesialBlacklist": statusSpesialBlacklist,
        "MaxOpenedBlacklist": maxOpenedBlacklist,
        "HitungBukaBlacklist": hitungBukaBlacklist,
        "Keterangan": keterangan,
        "FeeInternal": feeInternal,
        "KeteranganBlacklist": keteranganBlacklist,
        "IsCN": isCn,
      };
}

// To parse  this JSON data, do
//
//     final pelangganSaveRes = pelangganSaveResFromMap(jsonString);

class PelangganSaveRes {
  bool success;
  String message;
  PelangganSaveData data;

  PelangganSaveRes({
    this.success,
    this.message,
    this.data,
  });

  factory PelangganSaveRes.fromJson(String str) =>
      PelangganSaveRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PelangganSaveRes.fromMap(Map<String, dynamic> json) =>
      PelangganSaveRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : PelangganSaveData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": data.toMap(),
      };
}

class PelangganSaveData {
  String nama;
  String pelangganKategoriId;
  String pegawaiId;
  String organisasiId;
  String noTelp;
  String rowStatus;
  String status;
  String createdById;
  String createdAt;

  PelangganSaveData({
    this.nama,
    this.pelangganKategoriId,
    this.pegawaiId,
    this.organisasiId,
    this.noTelp,
    this.rowStatus,
    this.status,
    this.createdById,
    this.createdAt,
  });

  factory PelangganSaveData.fromJson(String str) =>
      PelangganSaveData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PelangganSaveData.fromMap(Map<String, dynamic> json) =>
      PelangganSaveData(
        nama: json["Nama"] == null ? null : json["Nama"].toString(),
        pelangganKategoriId: json["PelangganKategoriId"] == null
            ? null
            : json["PelangganKategoriId"].toString(),
        pegawaiId:
            json["PegawaiId"] == null ? null : json["PegawaiId"].toString(),
        organisasiId: json["OrganisasiId"] == null
            ? null
            : json["OrganisasiId"].toString(),
        noTelp: json["NoTelp"] == null ? null : json["NoTelp"].toString(),
        rowStatus:
            json["RowStatus"] == null ? null : json["RowStatus"].toString(),
        status: json["Status"] == null ? null : json["Status"].toString(),
        createdById:
            json["CreatedById"] == null ? null : json["CreatedById"].toString(),
        createdAt: json["CreatedAt"] == null ? null : json["CreatedAt"],
      );

  Map<String, dynamic> toMap() => {
        "Nama": nama,
        "PelangganKategoriId": pelangganKategoriId,
        "PegawaiId": pegawaiId,
        "OrganisasiId": organisasiId,
        "NoTelp": noTelp,
        "RowStatus": rowStatus,
        "Status": status,
        "CreatedById": createdById,
        "CreatedAt": createdAt,
      };
}
