import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getX;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isPasswordHide=true;
  final user_id_controller=TextEditingController();
  final password_controller=TextEditingController();


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
                color: Color(0xff004080),
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
                              controller: user_id_controller,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none
                              ),
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
                                    controller: password_controller,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    obscureText: isPasswordHide,
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
                        onTap: (){
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
                            getX.Get.toNamed("/dashboard");
                          }

                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Color(0xff0039e6)
                          ),
                          child: Center(
                            child: Text("Login", style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w500),),
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
}
