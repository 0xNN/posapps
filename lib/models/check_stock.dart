// To parse this JSON data, do
//
//     final checkStockRes = checkStockResFromMap(jsonString);

import 'dart:convert';

class CheckStockRes {
  bool success;
  String message;

  CheckStockRes({
    this.success,
    this.message,
  });

  factory CheckStockRes.fromJson(String str) =>
      CheckStockRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CheckStockRes.fromMap(Map<String, dynamic> json) => CheckStockRes(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
      };
}
