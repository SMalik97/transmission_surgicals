import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'Invoice/View/invoice_list.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  Widget placeHolder=Container();

  bool isDrawerSelected=true;
  bool isQuotationSelected=false;
  bool isRoadTaxSelected=false;
  bool isInvoiceSelected=false;
  bool isProductSelected=false;

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
                        Text("Subrata Malik", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 14),),
                        SizedBox(height: 3,),
                        Text("subratamalik1997@gmail.com", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 12),),
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
                              isRoadTaxSelected=false;
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
                            setState(() {
                              isDrawerSelected=false;
                              isQuotationSelected=true;
                              isRoadTaxSelected=false;
                              isInvoiceSelected=false;
                              isProductSelected=false;
                            });
                          },
                            child: drawerItem(isQuotationSelected, "Quotations", Icons.inventory_outlined)
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                            onTap: (){
                              setState(() {
                                isDrawerSelected=false;
                                isQuotationSelected=false;
                                isRoadTaxSelected=true;
                                isInvoiceSelected=false;
                                isProductSelected=false;
                              });
                            },
                            child: drawerItem(isRoadTaxSelected, "Road Tax", Icons.taxi_alert)
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                            onTap: (){
                              setState(() {
                                isDrawerSelected=false;
                                isQuotationSelected=false;
                                isRoadTaxSelected=false;
                                isInvoiceSelected=true;
                                isProductSelected=false;

                                placeHolder = InvoiceList();
                              });
                            },
                            child: drawerItem(isInvoiceSelected, "Invoice", Icons.sticky_note_2_outlined)
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                            onTap: (){
                              setState(() {
                                isDrawerSelected=false;
                                isQuotationSelected=false;
                                isRoadTaxSelected=false;
                                isInvoiceSelected=false;
                                isProductSelected=true;
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
                                Container(
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        placeHolder=dashboard();
      });
    });
    super.initState();
  }


  Widget drawerItem(bool isSelect, String title, IconData icon){
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
  }


  Widget dashboard(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
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
                    Container(
                      height: 35,
                      width: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xff003366).withOpacity(0.8)
                      ),
                      child: Center(
                        child: Text("Manage Quotation", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),),
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
                    Text("ROAD TAX", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),),
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
                                        Text("35",style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600)),
                                        SizedBox(height: 5,),
                                        Text("Total Tax Number",style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
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
                                        Text("₹1458",style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
                                        SizedBox(height: 5,),
                                        Text("Total Amount Tax",style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
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
                    Container(
                      height: 35,
                      width: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xff003366).withOpacity(0.8)
                      ),
                      child: Center(
                        child: Text("Manage Road Tax", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),),
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
                    Text("INVOICE", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),),
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
                                Text("Invoice Number", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),),
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
                                        Text("₹3578",style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
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
                        setState(() {
                          isDrawerSelected=false;
                          isQuotationSelected=false;
                          isRoadTaxSelected=false;
                          isInvoiceSelected=true;
                          isProductSelected=false;

                          placeHolder = InvoiceList();
                        });
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
                    Container(
                      height: 35,
                      width: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xff003366).withOpacity(0.8)
                      ),
                      child: Center(
                        child: Text("Manage Products", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),),
                      ),
                    )
                  ],
                ),

              ),
            ],
          )
        ],
      ),
    );
  }

}
