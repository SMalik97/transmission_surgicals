import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getX;
import 'package:http/http.dart';
import 'package:transmission_surgicals/Utils/shared_preferences.dart';
import 'package:transmission_surgicals/Utils/urls.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isPasswordHide=true;
  final user_id_controller=TextEditingController();
  final password_controller=TextEditingController();
  bool isLogging=false;
  FocusNode email_focus=FocusNode();
  FocusNode password_focus=FocusNode();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/image/9712.png", width: 400, height: 400,),
            SizedBox(width: 50,),
            Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 40),
              width: 370,
              height: 400,
              decoration: BoxDecoration(
                color: Color(0xff004080).withOpacity(0.9),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Column(
                children: [
                  Text("Transmision Surgicals", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22),),

                  SizedBox(height: 40,),

                  Text("Admin Login", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),

                  SizedBox(height: 30,),

                  Row(
                    children: [
                      Text("Enter User ID", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13),),
                    ],
                  ),
                  SizedBox(height: 3,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white70, width: 1)
                            ),
                            child: TextField(
                              focusNode: email_focus,
                              controller: user_id_controller,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none
                              ),
                              onSubmitted: (v){
                                password_focus.requestFocus();
                              },
                              style: TextStyle(
                                  color: Colors.white
                              ),
                            )
                        ),
                      )
                    ],
                  ),



                  SizedBox(height: 15,),

                  Row(
                    children: [
                      Text("Enter Password", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13),),
                    ],
                  ),
                  SizedBox(height: 3,),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.white70, width: 1)
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    focusNode: password_focus,
                                    controller: password_controller,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    obscureText: isPasswordHide,
                                    onSubmitted: (v){
                                      if(user_id_controller.text.isEmpty){
                                        Fluttertoast.showToast(
                                            msg: "Please enter user id",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM_RIGHT,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                            fontSize: 16.0
                                        );
                                      }else  if(password_controller.text.isEmpty){
                                        Fluttertoast.showToast(
                                            msg: "Please enter password",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM_RIGHT,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                            fontSize: 16.0
                                        );
                                      }else{
                                        ///Call api
                                        userLogin();
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        isPasswordHide = !isPasswordHide;
                                      });
                                    },
                                      child: Icon(isPasswordHide?Icons.visibility : Icons.visibility_off_outlined, color: Colors.white,size: 18,)
                                  ),
                                )
                              ],
                            )
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 30,),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: isLogging?null:(){
                          if(user_id_controller.text.isEmpty){
                            Fluttertoast.showToast(
                                msg: "Please enter user id",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM_RIGHT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                fontSize: 16.0
                            );
                          }else  if(password_controller.text.isEmpty){
                            Fluttertoast.showToast(
                                msg: "Please enter password",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM_RIGHT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                fontSize: 16.0
                            );
                          }else{
                            ///Call api
                            userLogin();
                          }

                        },
                        child: Opacity(
                          opacity: isLogging?0.7:1,
                          child: Container(
                            width: 150,
                            height: 37,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Color(0xff0039e6)
                            ),
                            child: Center(
                              child: Text(isLogging?"Logging...":"Login", style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w500),),
                            ),
                          ),
                        ),
                      )
                    ],
                  )

                ],
              ),

            )
          ],
        ),
      ),
    );
  }
  userLogin() async {
    setState(() {
      isLogging=true;
    });
    var url = Uri.parse(user_login);
    Map<String, String> body = {"email": user_id_controller.text.trim(),"password":md5.convert(utf8.encode(password_controller.text)).toString()};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        Fluttertoast.showToast(
            msg: "Successfully logged in",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM_RIGHT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            webBgColor: "linear-gradient(to right, #1da241, #1da241)",
            fontSize: 16.0
        );
        writeSharedPreferences(ISLOGIN, "1");
        writeSharedPreferences(USER_ID, jsonData['id']);
        writeSharedPreferences(USER_EMAIL, jsonData['email']);
        writeSharedPreferences(USER_NAME, jsonData['name']);
        getX.Get.toNamed("/dashboard");

      }else{
        Fluttertoast.showToast(
            msg: "Wrong user id or password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM_RIGHT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            webBgColor: "linear-gradient(to right, #C62828, #C62828)",
            fontSize: 16.0
        );
      }
    }else{
      Fluttertoast.showToast(
          msg: "Some error has occurred",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          webBgColor: "linear-gradient(to right, #C62828, #C62828)",
          fontSize: 16.0
      );
    }
    setState(() {
      isLogging=false;
    });
  }
}
