// To parse this JSON data, do
//
//     final invoiceDeleteRes = invoiceDeleteResFromMap(jsonString);

import 'dart:convert';

class InvoiceDeleteRes {
  bool success;
  String message;

  InvoiceDeleteRes({
    this.success,
    this.message,
  });

  factory InvoiceDeleteRes.fromJson(String str) =>
      InvoiceDeleteRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InvoiceDeleteRes.fromMap(Map<String, dynamic> json) =>
      InvoiceDeleteRes(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
      };
}
