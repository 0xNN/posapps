// To parse this JSON data, do
//
//     final sendWaRes = sendWaResFromMap(jsonString);

import 'dart:convert';

class SendWaRes {
  bool success;
  String message;

  SendWaRes({
    this.success,
    this.message,
  });

  factory SendWaRes.fromJson(String str) => SendWaRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SendWaRes.fromMap(Map<String, dynamic> json) => SendWaRes(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
      };
}
