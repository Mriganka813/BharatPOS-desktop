import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
//import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/models/input/sign_up_input.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/services/api_v1.dart';

class AuthService {
  const AuthService();

  ///
  /// Send verification code
  Future<bool> sendVerificationCode(String phoneNumber) async {
    final response = await ApiV1Service.postRequest('/api/v1/sendOtp');
    if ((response.statusCode ?? 400) < 300) {
      return true;
    }
    return false;
  }

  ///
  /// Send login request
  Future<User?> signUpRequest(SignUpInput input) async {
    final response = await ApiV1Service.postRequest(
      '/registration',
      data: input.toMap(),
    );
    if ((response.statusCode ?? 400) > 300) {
      return null;
    }
    await saveCookie(response);
    return User.fromMap(response.data['user']);
  }

  /// Save cookies after sign in/up
  Future<void> saveCookie(Response response) async {
    List<Cookie> cookies = [Cookie("token", response.data['token'])];
    if(response.data['token_subuser'] != null && response.data['token_subuser'] != ""){
      // ck += ' token_subuser=${response.data['token_subuser']};';
      // _dio.options.headers.addAll({"Authorization_subuser" : "Bearer_subuser ${response.data['token_subuser']}"});
      cookies= [Cookie("token", response.data['token']), Cookie("token_subuser", response.data['token_subuser'])];
      // cookies= [Cookie("token", 'abc'), Cookie("token_subuser", 'def')];
    }
    final cj = await ApiV1Service.getCookieJar();
    await cj.saveFromResponse(Uri.parse(Const.apiUrl), cookies);
    ApiV1Service().intercept(CookieManager(cj));
  }

  ///
  // Future<void> signOut() async {
  //   await clearCookies();
  //   await fb.FirebaseAuth.instance.signOut();
  // }

  /// Clear cookies before log out
  Future<void> clearCookies() async {
    final cj = await ApiV1Service.getCookieJar();
    await cj.deleteAll();
    ApiV1Service().remIntercept();
  }

  /// Send sign in request
  ///
  Future<User?> signInRequest(String email, String password) async {
    await clearCookies();
    final response = await ApiV1Service.postRequest(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    if ((response.statusCode ?? 400) > 300) {
      return null;
    }
    print('res = ${response.data}');
    await saveCookie(response);
    return User.fromMap(response.data['user']);
  }
  Future<void> signOut() async {
    await clearCookies();
    //await fb.FirebaseAuth.instance.signOut();
  }

  ///password change request
  ///
  Future<bool> PasswordChangeRequest(
      String oldPassword, String newPassword, String confirmPassword) async {
    final response = await ApiV1Service.putRequest(
      '/password/update',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    if ((response.statusCode ?? 400) > 300) {
      return false;
    }
    return true;
  }

  ///password change request
  ///
  Future<bool> ForgotPasswordChangeRequest(
      String newPassword, String confirmPassword, String phoneNumber) async {
    // print(newPassword + " " + confirmPassword + " " + phoneNumber);
    final response = await ApiV1Service.putRequest(
      '/password/reset',
      data: {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber,
      },
    );
    if ((response.statusCode ?? 400) > 300) {
      return false;
    }
    return true;
  }
}
