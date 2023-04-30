import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' as getX;

class InvoiceList extends StatefulWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            color: Color(0xff004d4d),
            child: Row(
              children: [
                SizedBox(width: 15,),
                Text("Invoice", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (){
                            getX.Get.toNamed("/create-invoice");
                          },
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Color(0xff00802b)
                            ),
                            child: Center(child: Text("Create New Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                          ),
                        ),
                        SizedBox(width: 25,),
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                              color: Colors.green,
                            shape: BoxShape.circle
                          ),
                          child: Icon(Icons.refresh, color: Colors.white, size: 18,),
                        ),
                      ],
                    )
                ),
                SizedBox(width: 15,)
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      color: Color(0xffb3b3ff),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Container(
                            width: 180,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Color(0xff006666),
                              borderRadius: BorderRadius.circular(20)
                            ),
                              child: Center(
                                  child: Text("Generated Invoices", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                              )
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: 5,
                                itemBuilder: (context, index){
                                  return Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(8),
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: Color(0xff990099)
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Invoice No. #78965412", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),),
                                            Text("30 April 2023", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 11),),
                                          ],
                                        ),
                                        SizedBox(height: 15,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Subrata Malik", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.90), fontSize: 13),),
                                                SizedBox(height: 2,),
                                                Text("Recipient's Address", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.90), fontSize: 13),),
                                                SizedBox(height: 2,),
                                                Text("Recipient's Contact", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.90), fontSize: 13),),

                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text("₹1458", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),)
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }
                            ),
                          )
                        ],
                      ),
                    )
                ),
                Expanded(
                    flex: 7,
                    child: Container(
                      color: Color(0xffccccff),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15,vertical: 7),
                                  decoration: BoxDecoration(
                                      color: Color(0xff003366).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text("Invoice #412546", style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black, fontSize: 16),)
                              ),
                              SizedBox(width: 20,),
                              Container(
                                  width: 150,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Color(0xff006666),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Center(
                                      child: Text("Edit Invoice", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                                  )
                              ),
                              SizedBox(width: 20,),
                              Container(
                                  width: 150,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Color(0xff003366),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Center(
                                      child: Text("Copy Invoice", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                                  )
                              ),
                              SizedBox(width: 20,),
                              Container(
                                  width: 130,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Color(0xff00802b),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Center(
                                      child: Text("Download", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                                  )
                              ),
                              SizedBox(width: 20,),
                              Container(
                                  width: 130,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Center(
                                      child: Text("Delete", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                                  )
                              ),
                            ],
                          ),
                          SizedBox(height: 15,),
                          Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                  children: [
                                    invoiceView()
                                  ]
                              )
                          )
                        ],
                      ),
                    )
                )
              ],
            ),
          )
        ],
      ),
    );
  }



  Widget invoiceView(){
    return Container(
      width:double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
      ),

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal:40),
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 60,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: Offset(-10.0, 0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset("assets/logo/logo.png",width: 50,height:50,),
                          SizedBox(width: 8,),
                          Text("Transmission Surgicals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.lightBlue),),
                        ],
                      ),
                    ),
                    SizedBox(height: 2,),
                    Text("333 J.C. Bose Road, PallyShree\nSodepur, Kolkata - 700110 \nPhone : +91 0333335980722 / 7278360630 / 9836947573\nEmail : surgicaltrans@gmail.com",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),

                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("INVOICE",style: GoogleFonts.alata(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
                    SizedBox(height: 5,),
                    Text("Invoice Number ########",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                    Text("Invoice Date #########",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                  ],
                ),
              ],
            ),

            SizedBox(height: 30,),
            Text("TO :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
            Text("Customer Name",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),
            Text("Customer Address",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),
            Text("Phone : +91 1234567890",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),
            Text("Email : example@mail.com",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),

            SizedBox(height: 30,),

            Row(
              children: [
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.blue, width: 1),
                        top: BorderSide(color: Colors.blue, width: 1),
                        bottom: BorderSide(color: Colors.blue, width: 1),
                      ),
                      color: Colors.blue.withOpacity(0.3)
                  ),
                  child: Center(
                      child: Text("Sl. No.", style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w600),)
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.blue, width: 1),
                            top: BorderSide(color: Colors.blue, width: 1),
                            bottom: BorderSide(color: Colors.blue, width: 1),
                          ),
                          color: Colors.blue.withOpacity(0.3)
                      ),
                      child: Center(
                          child: Text("Description", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),)
                      ),
                    )),

                Expanded(
                    flex: 3,
                    child: Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.blue, width: 1),
                            top: BorderSide(color: Colors.blue, width: 1),
                            bottom: BorderSide(color: Colors.blue, width: 1),
                          ),
                          color: Colors.blue.withOpacity(0.3)
                      ),
                      child: Center(
                          child: Text("Price", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),)
                      ),
                    )),

                Expanded(
                    flex: 3,
                    child: Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.blue, width: 1),
                            top: BorderSide(color: Colors.blue, width: 1),
                            bottom: BorderSide(color: Colors.blue, width: 1),
                          ),
                          color: Colors.blue.withOpacity(0.3)
                      ),
                      child: Center(
                          child: Text("Quantity", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),)
                      ),
                    )),

                Expanded(
                    flex: 3,
                    child: Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.blue, width: 1),
                            right: BorderSide(color: Colors.blue, width: 1),
                            top: BorderSide(color: Colors.blue, width: 1),
                            bottom: BorderSide(color: Colors.blue, width: 1),
                          ),
                          color: Colors.blue.withOpacity(0.3)
                      ),
                      child: Center(
                          child: Text("Total", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),)
                      ),
                    )),
              ],
            ),
            ListView.builder(
                itemCount: 4,
                shrinkWrap: true,
                itemBuilder: (context, index){
                  return Row(
                    children: [
                      Container(
                        width: 60,
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.blue, width: 1),
                              bottom: BorderSide(color: Colors.blue, width: 1),
                            ),
                        ),
                        child: Center(
                            child: Text((index+1).toString()+".", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),)
                        ),
                      ),
                      Expanded(
                          flex: 5,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 1),
                                bottom: BorderSide(color: Colors.blue, width: 1),
                              ),

                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("It's a test description",style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                              ],
                            ),
                          )),

                      Expanded(
                          flex: 3,
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 1),
                                bottom: BorderSide(color: Colors.blue, width: 1),
                              ),

                            ),
                          )),

                      Expanded(
                          flex: 3,
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 1),
                                bottom: BorderSide(color: Colors.blue, width: 1),
                              ),

                            ),
                          )),

                      Expanded(
                          flex: 3,
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 1),
                                right: BorderSide(color: Colors.blue, width: 1),
                                bottom: BorderSide(color: Colors.blue, width: 1),
                              ),

                            ),
                          )),
                    ],
                  );
                }
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Subtotal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("GST", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("Other charges", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("Grand Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("Paid", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("Due", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("0.00", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("0.00", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("0.00", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("0.00", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("0.00", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                    Text("0.00", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50,),

            Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
            SizedBox(height: 3,),
            Text("If you have any questions concerning this invoice, contact name, phone or amount please contact us at contact@bafets.com",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black),),

            SizedBox(height: 30,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("THANK YOU FOR YOUR BUSINESS!",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),

              ],
            ),

            SizedBox(height: 80,),
          ],
        ),
      ),

    );
  }

}
