import 'dart:convert';
import 'package:http/http.dart' as http;

class UserModel {
  final int? userId;
  final String? userName;
  final String? userFullName;
  final int? unitDeptNo;
  final String? userStatus;
  final String? status;

  UserModel({
    this.userId,
    this.userName,
    this.userFullName,
    this.unitDeptNo,
    this.userStatus,
    this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      userName: json['user_name'],
      userFullName: json['user_full_name'],
      unitDeptNo: json['unit_dept_no'],
      userStatus: json['USER_STATUS'],
      status: json['STATUS'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_full_name': userFullName,
      'unit_dept_no': unitDeptNo,
      'USER_STATUS': userStatus,
      'STATUS': status,
    };
  }
}


