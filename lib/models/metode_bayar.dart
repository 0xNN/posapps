// To parse this JSON data, do
//
//     final metodeBayarRes = metodeBayarResFromMap(jsonString);

import 'dart:convert';

class MetodeBayarRes {
  bool success;
  String message;
  List<MetodeBayarData> data;

  MetodeBayarRes({
    this.success,
    this.message,
    this.data,
  });

  factory MetodeBayarRes.fromJson(String str) =>
      MetodeBayarRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MetodeBayarRes.fromMap(Map<String, dynamic> json) => MetodeBayarRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<MetodeBayarData>.from(
                json["data"].map((x) => MetodeBayarData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class MetodeBayarData {
  String id;
  String alias;

  MetodeBayarData({
    this.id,
    this.alias,
  });

  factory MetodeBayarData.fromJson(String str) =>
      MetodeBayarData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MetodeBayarData.fromMap(Map<String, dynamic> json) => MetodeBayarData(
        id: json["Id"],
        alias: json["Alias"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "Alias": alias,
      };
}
