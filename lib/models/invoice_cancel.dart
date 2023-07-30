// To parse this JSON data, do
//
//     final invoiceDeleteRes = invoiceDeleteResFromMap(jsonString);

import 'dart:convert';

class InvoiceCancelRes {
  bool success;
  String message;

  InvoiceCancelRes({
    this.success,
    this.message,
  });

  factory InvoiceCancelRes.fromJson(String str) =>
      InvoiceCancelRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceCancelRes.fromMap(Map<String, dynamic> json) =>
      InvoiceCancelRes(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
      };
}
