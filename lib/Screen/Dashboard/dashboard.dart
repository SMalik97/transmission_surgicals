import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:transmission_surgicals/Utils/shared_preferences.dart';
import 'package:get/get.dart' as getX;
import '../../Service/auth_service.dart';
import '../../Utils/urls.dart';
import '../Invoice/View/invoice_list.dart';
import '../Product/View/products.dart';
import '../Quotation/View/quotation_list.dart';
import '../RoadChallan/View/challan_list.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  Widget placeHolder=Container();

  bool isDrawerSelected=true;
  bool isQuotationSelected=false;
  bool isRoadChallanSelected=false;
  bool isInvoiceSelected=false;
  bool isProductSelected=false;

  String user_name="", user_email="";
  String total_invoice="", total_invoice_amount="", total_challan="", total_challan_amount="";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Color(0xff19334d),
                    child: Column(
                      children: [
                        SizedBox(height: 50,),
                        Container(
                          width: 60,height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.lightBlue, width: 1.5)
                          ),
                          child: SvgPicture.asset("assets/icon/profile.svg"),
                        ),
                        SizedBox(height: 15,),
                        Text(user_name, style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 14),),
                        SizedBox(height: 3,),
                        Text(user_email, style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(
                            thickness: 1,
                            color: Colors.white30,
                            height: 50,
                          ),
                        ),



                        InkWell(
                          onTap: (){
                            setState(() {
                              isDrawerSelected=true;
                              isQuotationSelected=false;
                              isRoadChallanSelected=false;
                              isInvoiceSelected=false;
                              isProductSelected=false;

                              placeHolder=dashboard();
                            });
                          },
                            child: drawerItem(isDrawerSelected, "Dashboard", Icons.dashboard_outlined)
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                          onTap: (){
                            selectQuotation();
                          },
                            child: drawerItem(isQuotationSelected, "Quotations", Icons.inventory_outlined)
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                            onTap: (){
                              selectChallan();
                            },
                            child: drawerItem(isRoadChallanSelected, "Delivery Challan", Icons.taxi_alert)
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                            onTap: (){
                              selectInvoice();
                            },
                            child: drawerItem(isInvoiceSelected, "Tax Invoice", Icons.sticky_note_2_outlined)
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                            onTap: (){
                              setState(() {
                                selectProduct();
                              });
                            },
                            child: drawerItem(isProductSelected, "Product & Services", Icons.home_repair_service)
                        ),

                        SizedBox(height: 5,),

                        Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Divider(
                                  height: 20,
                                  thickness: 0.5,
                                  color: Colors.white30,
                                ),
                                InkWell(
                                  onTap: (){
                                    Dialog delete = Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Wrap(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20),
                                            width: 320,
                                            color: Colors.white,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 15,),
                                                Text("Confirmation?", style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                                                SizedBox(height: 15,),
                                                Text("Are you sure you want to logout from your account?",style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500)),
                                                SizedBox(height: 25,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    InkWell(
                                                      onTap: (){
                                                        getX.Get.back();
                                                      },
                                                      child: Container(
                                                        height: 30,
                                                        width: 80,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2),
                                                            border: Border.all(color: Colors.red, width: 0.7),
                                                            color: Colors.red.withOpacity(0.1)
                                                        ),
                                                        child: Center(child: Text("Cancel", style: TextStyle(color: Colors.red,fontSize: 14,fontWeight: FontWeight.w600))),
                                                      ),
                                                    ),

                                                    InkWell(
                                                      onTap: (){
                                                        clearAllData();
                                                        final authService = getX.Get.find<AuthService>();
                                                        authService.isLogin = "0";
                                                        getX.Get.offAndToNamed("/login");
                                                      },
                                                      child: Container(
                                                        height: 30,
                                                        width: 80,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(2),
                                                            border: Border.all(color: Colors.blue, width: 0.7),
                                                            color: Colors.blue.withOpacity(0.1)
                                                        ),
                                                        child: Center(child: Text("Logout", style: TextStyle(color: Colors.blue,fontSize: 14,fontWeight: FontWeight.w600))),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 15,),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                    showDialog(context: context, builder: (context)=>delete);
                                  },
                                  child: Container(
                                    height: 32,
                                    color: Colors.red.withOpacity(0.2),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10,),
                                        Icon(Icons.power_settings_new, color: Colors.red,size: 20,),
                                        SizedBox(width: 8,),
                                        Text("LOGOUT",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w600,fontSize: 14),)
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 15,)
                              ],
                            )
                        )



                      ],
                    ),
                  ),
                ),



                Expanded(
                  flex: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xffb3daff), Color(0xffffccff)]
                      )
                    ),

                    child: placeHolder,

                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    readSharedPreferences(USER_NAME, "").then((value){
      user_name=value;
    });
    readSharedPreferences(USER_EMAIL, "").then((value){
      user_email=value;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        placeHolder=dashboard();
      });
    });

    fetchInvoiceInfo();
    fetchChallanInfo();
    super.initState();
  }


  Widget drawerItem(bool isSelect, String title, IconData icon){
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          color: isSelect==true ? Color(0xff6666ff).withOpacity(0.2) : Colors.transparent,
          height: 40,
          child: Row(
            children: [
              SizedBox(width: 10,),
              Icon(icon,color: Colors.white,size: 20,),
              SizedBox(width: 10,),
              Text(title, style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)
            ],
          ),
        );
      },
    );
  }


  Widget dashboard(){
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: 30,),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    width: MediaQuery.of(context).size.width*0.30,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff00b3b3),Color(0xff8533ff)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      children: [
                        Text("QUOTATION", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white.withOpacity(0.3)
                                ),

                                child: Column(
                                  children: [
                                    SizedBox(height: 15,),
                                    Text("With Image", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Divider(
                                        height: 15,
                                        color: Colors.white54,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("35",style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 5,),
                                            Text("Total Quotation",style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                          ],
                                        )
                                    ),


                                  ],
                                ),

                              ),
                            ),
                            SizedBox(width: 30,),
                            Expanded(
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white.withOpacity(0.3)
                                ),

                                child: Column(
                                  children: [
                                    SizedBox(height: 15,),
                                    Text("Without Image", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Divider(
                                        height: 15,
                                        color: Colors.white54,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("35",style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 5,),
                                            Text("Total Quotation",style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                          ],
                                        )
                                    ),


                                  ],
                                ),

                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            selectQuotation();
                          },

                          child: Container(
                            height: 35,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff003366).withOpacity(0.8)
                            ),
                            child: Center(
                              child: Text("Manage Quotation", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),),
                            ),
                          ),
                        )
                      ],
                    ),

                  ),

                  SizedBox(width: 50,),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    width: MediaQuery.of(context).size.width*0.30,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff00b3b3),Color(0xff8533ff)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      children: [
                        Text("DELIVERY CHALLAN", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white.withOpacity(0.3)
                                ),

                                child: Column(
                                  children: [
                                    SizedBox(height: 15,),
                                    Text("Number", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Divider(
                                        height: 15,
                                        color: Colors.white54,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(total_challan,style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 5,),
                                            Text("Total Challan Number",style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                          ],
                                        )
                                    ),


                                  ],
                                ),

                              ),
                            ),
                            SizedBox(width: 30,),
                            Expanded(
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white.withOpacity(0.3)
                                ),

                                child: Column(
                                  children: [
                                    SizedBox(height: 15,),
                                    Text("Amount", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Divider(
                                        height: 15,
                                        color: Colors.white54,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("₹"+total_challan_amount,style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 5,),
                                            Text("Total Challan Amount",style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                                          ],
                                        )
                                    ),


                                  ],
                                ),

                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            selectChallan();
                          },
                          child: Container(
                            height: 35,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff003366).withOpacity(0.8)
                            ),
                            child: Center(
                              child: Text("Manage Delivery Challan", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),),
                            ),
                          ),
                        )
                      ],
                    ),

                  ),
                ],
              ),

              SizedBox(height: 50,),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    width: MediaQuery.of(context).size.width*0.30,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff00b3b3),Color(0xff8533ff)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      children: [
                        Text("TAX INVOICE", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white.withOpacity(0.3)
                                ),

                                child: Column(
                                  children: [
                                    SizedBox(height: 15,),
                                    Text("Invoice Number", style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500),),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Divider(
                                        height: 15,
                                        color: Colors.white54,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(total_invoice,style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 5,),
                                            Text("Total Invoice",style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                                          ],
                                        )
                                    ),


                                  ],
                                ),

                              ),
                            ),
                            SizedBox(width: 30,),
                            Expanded(
                              child: Container(
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white.withOpacity(0.3)
                                ),

                                child: Column(
                                  children: [
                                    SizedBox(height: 15,),
                                    Text("Invoice Amount", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: Divider(
                                        height: 15,
                                        color: Colors.white54,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("₹$total_invoice_amount",style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 5,),
                                            Text("Total Amount",style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
                                          ],
                                        )
                                    ),


                                  ],
                                ),

                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            selectInvoice();
                          },
                          child: Container(
                            height: 35,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff003366).withOpacity(0.8)
                            ),
                            child: Center(
                              child: Text("Manage Invoice", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),),
                            ),
                          ),
                        )
                      ],
                    ),

                  ),

                  SizedBox(width: 50,),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    width: MediaQuery.of(context).size.width*0.30,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff00b3b3),Color(0xff8533ff)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      children: [
                        Text("PRODUCT & SERVICES", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),),
                        SizedBox(height: 25,),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 15),
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.white.withOpacity(0.3)
                                ),

                                child: Column(
                                  children: [
                                    SizedBox(height: 15,),
                                    Row(
                                      children: [
                                        Text("Added Products : ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),),
                                        Text("153", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),),
                                      ],
                                    ),

                                    SizedBox(height: 15,),

                                    Row(
                                      children: [
                                        Text("Provided Services : ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),),
                                        Text("153", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),),
                                      ],
                                    )

                                  ],
                                ),

                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: (){
                            selectProduct();
                          },
                          child: Container(
                            height: 35,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xff003366).withOpacity(0.8)
                            ),
                            child: Center(
                              child: Text("Manage Products", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),),
                            ),
                          ),
                        )
                      ],
                    ),

                  ),
                ],
              ),

              SizedBox(height: 30,),
            ],
          ),
        );
      },
    );
  }

  fetchInvoiceInfo() async {
    var url = Uri.parse(dashboard_invoice);
    Response response = await post(url);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      setState(() {
        total_invoice=jsonData['number'].toString();
        total_invoice_amount=jsonData['total_sum'].toString();
      });

    }else{
      Fluttertoast.showToast(
          msg: "Some error has occurred!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          webBgColor: "linear-gradient(to right, #C62828, #C62828)",
          fontSize: 16.0
      );
    }
  }

  fetchChallanInfo() async {
    var url = Uri.parse(road_challan_dashboard);
    Response response = await post(url);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      setState(() {
        total_challan=jsonData['number'].toString();
        total_challan_amount=jsonData['total_sum'].toString();
      });

    }else{
      Fluttertoast.showToast(
          msg: "Some error has occurred!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          webBgColor: "linear-gradient(to right, #C62828, #C62828)",
          fontSize: 16.0
      );
    }
  }

  selectInvoice(){
    setState(() {
      isDrawerSelected=false;
      isQuotationSelected=false;
      isRoadChallanSelected=false;
      isInvoiceSelected=true;
      isProductSelected=false;

      placeHolder = InvoiceList();
    });
  }


  selectChallan(){
    setState(() {
      isDrawerSelected=false;
      isQuotationSelected=false;
      isRoadChallanSelected=true;
      isInvoiceSelected=false;
      isProductSelected=false;

      placeHolder = ChallanList();
    });
  }

  selectQuotation(){
    setState(() {
      isDrawerSelected=false;
      isQuotationSelected=true;
      isRoadChallanSelected=false;
      isInvoiceSelected=false;
      isProductSelected=false;

      placeHolder = QuotationList();
    });
  }

  selectProduct(){
    setState(() {
      isDrawerSelected=false;
      isQuotationSelected=false;
      isRoadChallanSelected=false;
      isInvoiceSelected=false;
      isProductSelected=true;

      placeHolder = Products();
    });
  }

}
