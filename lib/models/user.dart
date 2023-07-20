// To parse this JSON data, do
//
//     final userRes = userResFromMap(jsonString);

import 'dart:convert';

class UserRes {
  bool success;
  String message;
  List<UserData> data;

  UserRes({
    this.success,
    this.message,
    this.data,
  });

  factory UserRes.fromJson(String str) => UserRes.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserRes.fromMap(Map<String, dynamic> json) => UserRes(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<UserData>.from(json["data"].map((x) => UserData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data":
            data == null ? [] : List<dynamic>.from(data.map((x) => x.toMap())),
      };
}

class UserData {
  String id;
  String pegawaiId;
  String nama;
  String userId;
  String password;
  String email;
  String noTelp;
  String roleId;
  String status;
  String rowStatus;
  String createdAt;
  String createdById;
  String updatedAt;
  String updatedById;

  UserData({
    this.id,
    this.pegawaiId,
    this.nama,
    this.userId,
    this.password,
    this.email,
    this.noTelp,
    this.roleId,
    this.status,
    this.rowStatus,
    this.createdAt,
    this.createdById,
    this.updatedAt,
    this.updatedById,
  });

  factory UserData.fromJson(String str) => UserData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserData.fromMap(Map<String, dynamic> json) => UserData(
        id: json["Id"],
        pegawaiId: json["PegawaiId"],
        nama: json["Nama"],
        userId: json["UserId"],
        password: json["Password"],
        email: json["Email"],
        noTelp: json["NoTelp"],
        roleId: json["RoleId"],
        status: json["Status"],
        rowStatus: json["RowStatus"],
        createdAt: json["CreatedAt"],
        createdById: json["CreatedById"],
        updatedAt: json["UpdatedAt"],
        updatedById: json["UpdatedById"],
      );

  Map<String, dynamic> toMap() => {
        "Id": id,
        "PegawaiId": pegawaiId,
        "Nama": nama,
        "UserId": userId,
        "Password": password,
        "Email": email,
        "NoTelp": noTelp,
        "RoleId": roleId,
        "Status": status,
        "RowStatus": rowStatus,
        "CreatedAt": createdAt,
        "CreatedById": createdById,
        "UpdatedAt": updatedAt,
        "UpdatedById": updatedById,
      };
}
