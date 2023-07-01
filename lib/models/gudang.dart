// To parse this JSON data, do
//
//     final gudangRes = gudangResFromMap(jsonString);

import 'dart:convert';

class GudangRes {
  bool success;
  String message;
  List<GudangData> data;

  GudangRes({
    this.success,
    this.message,
    this.data,
  });

  factory GudangRes.fromJson(String str) => GudangRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GudangRes.fromMap(Map<String, dynamic> json) => GudangRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<GudangData>.from(
                json["data"].map((x) => GudangData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class GudangData {
  String Id;
  String OrganisasiId;
  String PelangganId;
  String Kode;
  String Nama;
  String Alamat;
  String KotaId;
  String KodePos;
  String NoTelp;
  String Status;
  String RowStatus;
  String CreatedAt;
  String CreatedById;
  String UpdatedAt;
  String UpdatedById;

  GudangData({
    this.Id,
    this.OrganisasiId,
    this.PelangganId,
    this.Kode,
    this.Nama,
    this.Alamat,
    this.KotaId,
    this.KodePos,
    this.NoTelp,
    this.Status,
    this.RowStatus,
    this.CreatedAt,
    this.CreatedById,
    this.UpdatedAt,
    this.UpdatedById,
  });

  factory GudangData.fromJson(String str) =>
      GudangData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GudangData.fromMap(Map<String, dynamic> json) => GudangData(
        Id: json["Id"].toString(),
        OrganisasiId: json["OrganisasiId"].toString(),
        PelangganId: json["PelangganId"].toString(),
        Kode: json["Kode"].toString(),
        Nama: json["Nama"].toString(),
        Alamat: json["Alamat"].toString(),
        KotaId: json["KotaId"].toString(),
        KodePos: json["KodePos"].toString(),
        NoTelp: json["NoTelp"].toString(),
        Status: json["Status"].toString(),
        RowStatus: json["RowStatus"].toString(),
        CreatedAt: json["CreatedAt"].toString(),
        CreatedById: json["CreatedById"].toString(),
        UpdatedAt: json["UpdatedAt"].toString(),
        UpdatedById: json["UpdatedById"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "Id": Id,
        "OrganisasiId": OrganisasiId,
        "PelangganId": PelangganId,
        "Kode": Kode,
        "Nama": Nama,
        "Alamat": Alamat,
        "KotaId": KotaId,
        "KodePos": KodePos,
        "NoTelp": NoTelp,
        "Status": Status,
        "RowStatus": RowStatus,
        "CreatedAt": CreatedAt,
        "CreatedById": CreatedById,
        "UpdatedAt": UpdatedAt,
        "UpdatedById": UpdatedById,
      };

  @override
  String toString() {
    return 'GudangData(Id: $Id, OrganisasiId: $OrganisasiId, PelangganId: $PelangganId, Kode: $Kode, Nama: $Nama, Alamat: $Alamat, KotaId: $KotaId, KodePos: $KodePos, NoTelp: $NoTelp, Status: $Status, RowStatus: $RowStatus, CreatedAt: $CreatedAt, CreatedById: $CreatedById, UpdatedAt: $UpdatedAt, UpdatedById: $UpdatedById)';
  }
}
