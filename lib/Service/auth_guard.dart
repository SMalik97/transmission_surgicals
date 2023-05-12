import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';

class AuthGuard extends GetMiddleware {
//   Get the auth service
  final authService = Get.find<AuthService>();

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if(authService.isLogin=="0"){
      /// Not Login ---------------------------------
      /// if user is navigating to login screen or splash screen
      /// then allow navigating
      if(route=="/login" || route=="/splash-screen"){
        return null;
      }else{
        /// if user is trying to navigating to other pages
        /// redirect back them to login screen
        return RouteSettings(name: "/login");
      }

    }else{
      /// User Logged in ---------------------------------
      /// then allow navigating to any pages except login page
      /// because user is already logged in
      if(route == "/login"){
        return RouteSettings(name: "/dashboard");
      }else{
        return null;
      }

    }



  }
}
