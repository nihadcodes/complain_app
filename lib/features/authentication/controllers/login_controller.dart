import 'dart:developer';
import 'package:complain_management/features/authentication/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view_models/login_view_model.dart';

class LoginController {
  final LoginModel _loginModel;

  LoginController({required String username, required String password})
      : _loginModel = LoginModel(username: username, password: password);

  // Method to handle login through the model
  Future<UserModel> login() async {
    final result = await _loginModel.login();

    log('inside_login_controller: ${result}');

    _loginModel.login().then((result) async {
      if(result.status!.toLowerCase() == 'success'){

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _loginModel.username);
      }
    }).onError((error, stackTrace){
        log(error.toString());
    });




    // if (result['status']) {
    //   final data = result['data'];
    //   if (data['STATUS'] == 'Success') {
    //     // Store the login state in SharedPreferences
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     await prefs.setBool('isLoggedIn', true);
    //     await prefs.setString('username', _loginModel.username);
    //   }
      return result;
    }
    // else {
    //   return result;
    // }
  }

