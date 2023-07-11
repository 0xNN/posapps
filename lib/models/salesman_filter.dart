// To parse  this JSON data, do
//
//     final salesmanFilterRes = salesmanFilterResFromMap(jsonString);

import 'dart:convert';

class SalesmanFilterRes {
  bool success;
  String message;
  List<SalesmanFilterData> data;

  SalesmanFilterRes({
    this.success,
    this.message,
    this.data,
  });

  factory SalesmanFilterRes.fromJson(String str) =>
      SalesmanFilterRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesmanFilterRes.fromMap(Map<String, dynamic> json) =>
      SalesmanFilterRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SalesmanFilterData>.from(
                json["data"].map((x) => SalesmanFilterData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class SalesmanFilterData {
  String id;
  String nama;
  int isDefault;

  SalesmanFilterData({
    this.id,
    this.nama,
    this.isDefault,
  });

  factory SalesmanFilterData.fromJson(String str) =>
      SalesmanFilterData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesmanFilterData.fromMap(Map<String, dynamic> json) =>
      SalesmanFilterData(
        id: json["Id"].toString(),
        nama: json["Nama"],
        isDefault: json["IsDefault"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Nama": nama,
        "IsDefault": isDefault,
      };
}
