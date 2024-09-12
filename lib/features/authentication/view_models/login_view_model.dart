import 'dart:convert';
import 'dart:developer';
import '../models/login_model.dart';
import 'package:http/http.dart' as http;

class LoginModel {
  final String username;
  final String password;

  LoginModel({required this.username, required this.password});


  Future<dynamic> login() async {
    try {
      final Uri url = Uri.parse(
        'http://118.179.223.41:7007/ords/xact_erp/user/login?USER_NAME=$username&USER_PASSWORD=$password',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // return {'status': true, 'data': data};
        return UserModel.fromJson(data);
      }
      else {
        // return {'status': false, 'message': 'Server error: ${response.statusCode}'};
        log('${response.statusCode}');
        throw Exception('login error');
      }
    } catch (e) {
      // return Exception(e.toString());
      throw Exception(e.toString());
    }
  }
}
