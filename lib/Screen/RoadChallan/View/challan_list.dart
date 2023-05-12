import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getX;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:transmission_surgicals/Screen/RoadChallan/Model/noteditableChallanModel.dart';
import 'package:transmission_surgicals/Screen/RoadChallan/Model/challan_list_model.dart';

import '../../../Utils/urls.dart';

class ChallanList extends StatefulWidget {
  const ChallanList({Key? key}) : super(key: key);

  @override
  State<ChallanList> createState() => _ChallanListState();
}

class _ChallanListState extends State<ChallanList> {

  bool isListLoading=true;
  bool isChallanLoading=false;
  String selectedChallanId="", selectedReceivedBy="", selectedDeliveryBy="", selectedChallanNumber="", selectedChallanDate="", selectedChallanRecipientDetails="", selectedChallanGstno="", selectedChallanVehicleno="", selectedChallanSupplyPlace="", selectedGstPercentage="";

  List<notEditableChallanItem> challan_list=[];
  List<ChallanListModel> road_challan_list=[];

  String selectedTotalQuantity="0.00";

  late Uint8List pdf_bytes;
  final pdf = pw.Document();

  int selectedIndex=0;


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
                Text("Delivery Challan", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),
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
                            fetch_challan_list();
                            setState(() {
                              isListLoading=true;
                              isChallanLoading=false;
                              selectedIndex=0;
                              selectedChallanId="";
                            });
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
                                    child: Text("List of Challans", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                                )
                            ),
                            SizedBox(height: 10,),
                            Expanded(
                              child: isListLoading? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 25, height: 25,
                                      child: CircularProgressIndicator(color: Colors.green,),
                                    ),
                                    SizedBox(height: 7,),
                                    Text("Getting challan list...", style: TextStyle(fontSize: 14,color: Colors.green,fontWeight: FontWeight.w500),)
                                  ],
                                ),
                              ) : ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: road_challan_list.length,
                                  itemBuilder: (context, index){
                                    return InkWell(
                                      onTap: (){
                                        setState(() {
                                          selectedChallanId=road_challan_list[index].id.toString();
                                          selectedChallanNumber=road_challan_list[index].challanNo.toString();
                                          selectedIndex=index;
                                          isChallanLoading=true;
                                        });

                                        fetch_challan_details();

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
                                                Text("Challan No. #"+road_challan_list[index].challanNo.toString(), style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),),
                                                Text(formattedDate(road_challan_list[index].date.toString()), style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 11),),
                                              ],
                                            ),
                                            SizedBox(height: 15,),
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(road_challan_list[index].recipientAddress.toString(), style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.90), fontSize: 12),overflow: TextOverflow.fade,),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 15,),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text("₹"+road_challan_list[index].total.toString(), style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                  SizedBox(width: 5,),
                                                ],
                                              ),
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
                                    Timer(Duration(milliseconds: 300),(){
                                      generatePdf(selectedChallanNumber, selectedChallanDate, selectedChallanRecipientDetails, challan_list, selectedTotalQuantity, selectedReceivedBy, selectedDeliveryBy);
                                    });
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
                                    deleteChallan();
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
    fetch_challan_list();
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
                              Text("Delivery Challan",style: GoogleFonts.alata(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                              SizedBox(height: 5,),
                              Text("Challan Number : "+selectedChallanNumber,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              Text("Challan Date : "+formattedDate(selectedChallanDate),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Text("Delivery Challan for :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
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
                          DataColumn(label: Text('HSN/SAC')),
                          DataColumn(label: Text('MRP')),
                          DataColumn(label: Text('Quantity')),
                        ],
                        rows: [
                          ...challan_list.asMap().entries.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text((item.key + 1).toString() + ".")),
                                DataCell(Text(item.value.description.toString())),
                                DataCell(Text(item.value.hsn.toString())),
                                DataCell(Text(item.value.totalAmount.toString())),
                                DataCell(Text(item.value.quantity.toString())),
                              ],
                            );
                          }).toList(),
                        ],

                        columnSpacing: 10,
                        headingRowColor: MaterialStateProperty.resolveWith<Color?>((states) => Colors.blue.shade100),
                        border: TableBorder.all(color: Colors.blue,width: 1),
                        headingRowHeight: 30,
                        headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),


                      ),

                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Quantity", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                          Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                          Text(selectedTotalQuantity, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                        ],
                      ),


                      SizedBox(height: 50,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Received By:", style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),),
                              SizedBox(height: 3,),
                              Text(selectedReceivedBy,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Delivery By:", style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),),
                              SizedBox(height: 3,),
                              Text(selectedDeliveryBy,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,)),
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 20,),
                      Text("Thanks for your business!", style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black),),

                      SizedBox(height: 50,),
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

  fetch_challan_list() async {
    var url = Uri.parse(get_challan_list);
    Response response = await post(url);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      road_challan_list.clear();
      jsonData['challan_list'].forEach((jsonResponse) {
        ChallanListModel obj = new ChallanListModel.fromJson(jsonResponse);
        setState(() {
          road_challan_list.add(obj);
        });
      });

      if(selectedChallanId.isNotEmpty){
        fetch_challan_details();
        refreshIndex();
      }

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
    setState(() {
      isListLoading=false;
    });

  }


  fetch_challan_details() async {
    var url = Uri.parse(get_challan_details);
    Map<String, String> body = {"challan_id": selectedChallanId};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        selectedChallanId = jsonData['id'].toString();
        selectedChallanNumber = jsonData['challan_no'].toString();
        selectedChallanDate = jsonData['date'].toString();
        selectedChallanRecipientDetails = jsonData['recipient_address'].toString();
        selectedChallanGstno = jsonData['gst_number'].toString();
        selectedChallanVehicleno = jsonData['vehicle_number'].toString();
        selectedChallanSupplyPlace = jsonData['supply_place'].toString();
        selectedTotalQuantity = jsonData['total_quantity'].toString();
        selectedReceivedBy = jsonData['received_by'].toString();
        selectedDeliveryBy = jsonData['delivery_by'].toString();

        challan_list.clear();
        jsonData['challan_items'].forEach((jsonResponse) {
          notEditableChallanItem obj = new notEditableChallanItem.fromJson(jsonResponse);
          setState(() {
            challan_list.add(obj);
          });
        });



        setState(() {
          isChallanLoading=false;
        });

      }
    }else{
      Fluttertoast.showToast(
          msg: "No challan found",
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


  generatePdf(String challan_no, String challan_date, String recipient_details, List<notEditableChallanItem> challan_item_list, String total_qty, String received_by, String delivery_by) async {
    final invoiceLogo = await getAssetsImage("assets/logo/logo.png");
    List<pw.Widget> widgets = [];
    widgets.add(pw.SizedBox(height: 60,),);


    widgets.add(pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Image(pw.MemoryImage(invoiceLogo), width: 50,height: 50),
                pw.SizedBox(width: 8,),
                pw. Text("Transmission Surgicals", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18,color: PdfColors.lightBlue),),
              ],
            ),
            pw.SizedBox(height: 2,),
            pw.Text("333 J.C. Bose Road, PallyShree\nSodepur, Kolkata - 700110 \nPhone : +91 0333335980722 / 7278360630 / 9836947573\nEmail : surgicaltrans@gmail.com",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black),),

          ],
        ),
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("Delivery Challan",style: pw.TextStyle(fontSize: 16,fontWeight:pw.FontWeight.bold,color: PdfColors.black),),
            pw.SizedBox(height: 5,),
            pw.Text("Challan Number : $challan_no",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
            pw.Text("Challan Date : "+challan_date,style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
          ],
        ),
      ],
    ));

    widgets.add( pw.SizedBox(height: 30,),);

    widgets.add(pw.Text("Delivery Challan for :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 11,color: PdfColors.black),),);
    widgets.add(pw.Text(recipient_details,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 12,color: PdfColors.black),),);
    widgets.add(pw.SizedBox(height: 30,),);
    widgets.add(
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("GSTIN : $selectedChallanGstno"),
                    pw.Text("Vehicle Number : $selectedChallanVehicleno"),
                    pw.Text("Place of Supply : $selectedChallanSupplyPlace"),
                  ]
              )
            ]
        )
    );
    widgets.add(pw.SizedBox(height: 20,),);


    widgets.add(pw.Table.fromTextArray(
        data: [
          ['Sl. No.','Description', 'HSN/SAC', 'MRP', 'Quantity'],
          ...challan_item_list.asMap().entries.map((item) => [
            (item.key+1).toString()+".",
            item.value.description.toString(),
            item.value.hsn.toString(),
            item.value.totalAmount.toString(),
            item.value.quantity.toString(),
          ]).toList(),
        ],
        cellAlignment: pw.Alignment.centerRight,
        cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue, fontSize: 10),
        border: pw.TableBorder.all(width: 1, color: PdfColors.blue),
        headerDecoration: pw.BoxDecoration(
          color: PdfColors.blue100,
        ),
        columnWidths: {
          0:pw.FlexColumnWidth(1),
          1:pw.FlexColumnWidth(3),
          2:pw.FlexColumnWidth(2),
          3:pw.FlexColumnWidth(2),
          4:pw.FlexColumnWidth(2),
        }
    ),);



    widgets.add(pw.SizedBox(height: 5,),);


    widgets.add(pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Total Quantity", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
        pw.Text(" : ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
        pw.Text(total_qty, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
      ],
    ),);


    widgets.add(pw.SizedBox(height: 10,),);


    widgets.add(
      pw.SizedBox(height: 15),
    );

    widgets.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Received By:", style: pw.TextStyle(fontSize: 10,color: PdfColors.black,fontWeight: pw.FontWeight.bold),),
              pw.SizedBox(height: 3,),
              pw.Text(received_by,style: pw.TextStyle(color: PdfColors.black,fontWeight: pw.FontWeight.normal, fontSize: 10,),
              ),
            ],
          )
        ],
      ),
    );

    widgets.add(pw.SizedBox(height: 15,),);

    widgets.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Delivery By:", style: pw.TextStyle(fontSize: 10,color: PdfColors.black,fontWeight: pw.FontWeight.bold),),
              pw.SizedBox(height: 3,),
              pw.Text(delivery_by,style: pw.TextStyle(color: PdfColors.black,fontWeight: pw.FontWeight.normal,fontSize: 10,)),
            ],
          )
        ],
      ),
    );

    widgets.add(pw.SizedBox(height: 20,),);

    widgets.add(pw.Text("Thanks for your business!", style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),);
    widgets.add(pw.SizedBox(height: 30,),);




    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => widgets,
      ),
    );

    pdf_bytes=await pdf.save();

    final blob = html.Blob([pdf_bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = "Challan$selectedChallanGstno.pdf";
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);


    Fluttertoast.showToast(
        msg: "Challan Downloaded!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        webBgColor: "linear-gradient(to right, #1da241, #1da241)",
        fontSize: 16.0
    );




  }


  Future<Uint8List> getAssetsImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }

  refreshIndex(){
    for(int i=0; i<road_challan_list.length; i++){
      if(road_challan_list[i].id == selectedChallanId){
        selectedIndex = i;
      }
    }
  }

  deleteChallan(){
    Dialog delete = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Wrap(
        children: [
          Container(
            width: 320,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: 15,),
                Text("Delete?", style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: 15,),
                Text("Are you sure you want to delete this challan?",style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500)),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: (){
                        getX.Get.back();
                      },
                      child: Container(
                        height: 32,
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
                        setState(() {
                          deleteChallanApi(selectedChallanId);
                          road_challan_list.removeAt(selectedIndex);
                          selectedChallanId="";
                        });
                        getX.Get.back();
                      },
                      child: Container(
                        height: 32,
                        width: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.blue, width: 0.7),
                            color: Colors.blue.withOpacity(0.1)
                        ),
                        child: Center(child: Text("Delete", style: TextStyle(color: Colors.blue,fontSize: 14,fontWeight: FontWeight.w600))),
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
  }



  deleteChallanApi(String challan_id) async {
    var url = Uri.parse(delete_road_challan);
    Map<String, String> body = {"challan_id": challan_id};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      print(myData);
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        setState(() {});
      }else{
        Fluttertoast.showToast(
            msg: "Error while loading",
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
  }

}
