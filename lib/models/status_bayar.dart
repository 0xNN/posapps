// To parse this JSON data, do
//
//     final statusBayarRes = statusBayarResFromMap(jsonString);

import 'dart:convert';

class StatusBayarRes {
  bool success;
  String message;
  List<StatusBayarData> data;

  StatusBayarRes({
    this.success,
    this.message,
    this.data,
  });

  factory StatusBayarRes.fromJson(String str) =>
      StatusBayarRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StatusBayarRes.fromMap(Map<String, dynamic> json) => StatusBayarRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<StatusBayarData>.from(
                json["data"].map((x) => StatusBayarData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class StatusBayarData {
  String id;
  String nama;
  String isDefault;

  StatusBayarData({
    this.id,
    this.nama,
    this.isDefault,
  });

  factory StatusBayarData.fromJson(String str) =>
      StatusBayarData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory StatusBayarData.fromMap(Map<String, dynamic> json) => StatusBayarData(
        id: json["Id"],
        nama: json["Nama"],
        isDefault: json["IsDefault"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Nama": nama,
        "IsDefault": isDefault,
      };
}
