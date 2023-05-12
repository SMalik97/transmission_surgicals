import 'package:get/get.dart';

import '../Utils/shared_preferences.dart';

class AuthService extends GetxService {
  String isLogin="0";

  @override
  onInit() {
    readSharedPreferences(ISLOGIN, "0").then((value) {
      isLogin=value;
    });
    return super.onInit();
  }

}