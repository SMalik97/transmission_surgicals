import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getX;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:transmission_surgicals/Screen/RoadChallan/Model/challan_item_model.dart';

class ChallanList extends StatefulWidget {
  const ChallanList({Key? key}) : super(key: key);

  @override
  State<ChallanList> createState() => _ChallanListState();
}

class _ChallanListState extends State<ChallanList> {

  bool isListLoading=false;
  bool isChallanLoading=false;
  String selectedChallanId="4", selectedChallanNumber="", selectedChallanDate="", selectedChallanRecipientDetails="", selectedChallanGstno="", selectedChallanVehicleno="", selectedChallanSupplyPlace="";

  List<notEditableChallanItem> challan_list=[];

  double selectedChallanSubtotal=0.00, selectedChallanGst=0.00, selectedChallanOther_charges=0.00, selectedChallanGrand_total=0.00;



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
                Text("Road Challan", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            await getX.Get.toNamed("/create-challan");
                            fetch_challan_list();
                          },
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Color(0xff00802b)
                            ),
                            child: Center(child: Text("Create New Challan", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                          ),
                        ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: (){

                            Fluttertoast.showToast(
                                msg: "Refreshing...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM_RIGHT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                webBgColor: "linear-gradient(to right, #1da241, #1da241)",
                                fontSize: 16.0
                            );
                          },
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle
                            ),
                            child: Icon(Icons.refresh, color: Colors.white, size: 18,),
                          ),
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
                        child: isListLoading==true ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(color: Colors.green.shade700,),
                            ),
                            SizedBox(height: 5,),
                            Text("Getting challan list ...", style: TextStyle(color: Colors.green.shade700,fontWeight: FontWeight.w600, fontSize: 15),)
                          ],
                        ) : Column(
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
                                    child: Text("List of Challan", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                                )
                            ),
                            SizedBox(height: 10,),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: 5,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.all(8),
                                        height: 120,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2),
                                            color: Color(0xff0077b3)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Challan No. #789647", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),),
                                                Text("06 Mar 2023", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 11),),
                                              ],
                                            ),
                                            SizedBox(height: 15,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("this is multiline\n details of \n recipient", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.90), fontSize: 13),),
                                                  ],
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text("₹"+"4587", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),)
                                                  ],
                                                )
                                              ],
                                            )
                                          ],
                                        ),
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
                        child: isChallanLoading==true? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(color: Colors.green.shade700,),
                              ),
                              SizedBox(height: 5,),
                              Text("Loading challan details ...", style: TextStyle(color: Colors.green.shade700,fontWeight: FontWeight.w600, fontSize: 15),)
                            ],
                          ),
                        ) : selectedChallanId.isEmpty ? Center(
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sticky_note_2_outlined,size: 50,color: Colors.deepPurpleAccent,),
                                SizedBox(height: 10,),
                                Text("Click on a challan to view details", style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.w600, fontSize: 15),),
                                SizedBox(height: 5,),
                                Text("OR", style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.w600, fontSize: 15),),
                                SizedBox(height: 5,),
                                InkWell(
                                  onTap: () async {
                                    await getX.Get.toNamed("/create-challan");
                                    fetch_challan_list();
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 30,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Color(0xff00802b)
                                    ),
                                    child: Center(child: Text("Create New Challan", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) : Column(
                          children: [
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                                    decoration: BoxDecoration(
                                        color: Color(0xff003366).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text("Challan #"+selectedChallanId, style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black, fontSize: 14),)
                                ),
                                SizedBox(width: 20,),
                                InkWell(
                                  onTap: () async {
                                    await getX.Get.toNamed("/create-challan?purpose=edit&id=$selectedChallanId");
                                    fetch_challan_list();
                                  },
                                  child: Container(
                                      width: 120,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          color: Color(0xff006666),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Center(
                                          child: Text("Edit Challan", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 14),)
                                      )
                                  ),
                                ),
                                SizedBox(width: 20,),
                                InkWell(
                                  onTap: () async {
                                    await getX.Get.toNamed("/create-challan?purpose=copy&id=$selectedChallanId");
                                    fetch_challan_list();

                                  },
                                  child: Container(
                                      width: 120,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          color: Color(0xff003366),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Center(
                                          child: Text("Copy Challan", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 14),)
                                      )
                                  ),
                                ),
                                SizedBox(width: 20,),
                                InkWell(
                                  onTap: (){
                                    Fluttertoast.showToast(
                                        msg: "Please wait, downloading...",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM_RIGHT,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        webBgColor: "linear-gradient(to right, #1da241, #1da241)",
                                        fontSize: 16.0
                                    );
                                    // Timer(Duration(milliseconds: 100),(){
                                    //   generatePdf(selectedInvoiceNumber, selectedInvoiceRecipientDetails,  invoice_details_list, selectedInvoiceSubtotal, selectedInvoiceGst_percentage, selectedInvoiceGst, selectedInvoiceOther_charges, selectedInvoiceGrand_total, selectedInvoicePaid, selectedInvoiceDue, selectedInvoiceCustom_note);
                                    // });
                                  },
                                  child: Container(
                                      width: 120,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          color: Color(0xff00802b),
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Center(
                                          child: Text("Download", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 14),)
                                      )
                                  ),
                                ),
                                SizedBox(width: 20,),
                                InkWell(
                                  onTap: (){
                                    // deleteInvoice();
                                  },
                                  child: Container(
                                      width: 120,
                                      height: 35,
                                      decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Center(
                                          child: Text("Delete", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 14),)
                                      )
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            challanView()
                          ],
                        ),
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }

  @override
  void initState() {

    super.initState();
  }

  String formattedDate(String inputDate) {
    try {
      DateFormat format = DateFormat("yyyy-MM-dd");
      var inDate = format.parse(inputDate);
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      final String formatted = formatter.format(inDate);
      return formatted;
    } catch (e) {
      return inputDate;
    }
  }

  Widget challanView(){
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width:MediaQuery.of(context).size.width*0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),

                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:40),
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
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
                              Text("Road Challan",style: GoogleFonts.alata(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                              SizedBox(height: 5,),
                              Text("Challan Number : "+selectedChallanNumber,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              Text("Challan Date : "+formattedDate(selectedChallanDate),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Text("TO :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
                      Text(selectedChallanRecipientDetails,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),

                      SizedBox(height: 15,),
                      Text("GSTIN : $selectedChallanGstno",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),
                      Text("Vehicle Number : $selectedChallanVehicleno",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),
                      Text("Place of Supply : $selectedChallanSupplyPlace",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),

                      SizedBox(height: 30,),



                      DataTable(
                        columns: [
                          DataColumn(label: Text('Sl. No.'),),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Quantity')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Total')),
                        ],
                        rows: [
                          ...challan_list.asMap().entries.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text((item.key + 1).toString() + ".")),
                                DataCell(Text(item.value.description.toString())),
                                DataCell(Text(item.value.quantity.toString())),
                                DataCell(Text(item.value.rate.toString())),
                                DataCell(Text(item.value.totalAmount.toString())),
                              ],
                            );
                          }).toList(),
                        ],

                        columnSpacing: 10,
                        headingRowColor: MaterialStateProperty.resolveWith<Color?>((states) => Colors.black54),
                        border: TableBorder.all(color: Colors.black87,width: 1),
                        headingRowHeight: 30,
                        headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),


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
                              SizedBox(height: 2,),
                              Text("GST (5%)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text("Other charges", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text("Grand Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),

                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),

                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(selectedChallanSubtotal.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedChallanGst.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedChallanOther_charges.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedChallanGrand_total.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                            width: 250,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Total Amount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  ],
                                ),
                                SizedBox(width: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  ],
                                ),
                                SizedBox(width: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(selectedChallanGrand_total.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50,),
                      

                      SizedBox(height: 80,),
                    ],
                  ),
                ),

              ),
            ],
          ),
        ],
      ),
    );
  }

  fetch_challan_list(){

  }

}
