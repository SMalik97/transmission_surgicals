import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:motion_toast/motion_toast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' as getX;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'package:transmission_surgicals/Screen/RoadChallan/Model/noteditableChallanModel.dart';
import 'package:transmission_surgicals/Screen/RoadChallan/Model/challan_list_model.dart';

import '../../../Utils/global_variable.dart';
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
  late pw.Document pdf;

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
                            MotionToast.success(
                              title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                              description:  Text("Refreshing..."),
                            ).show(context);

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
                                /// Challan Number -------------------------------
                                Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                                    decoration: BoxDecoration(
                                        color: Color(0xff003366).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text("Challan #"+selectedChallanNumber, style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black, fontSize: 12),)
                                ),
                                SizedBox(width: 20,),

                                ///Copy Challa ------------------------------------
                                InkWell(
                                  onTap: () async {
                                    await getX.Get.toNamed("/create-challan?purpose=edit&id=$selectedChallanId");
                                    fetch_challan_list();
                                  },
                                  child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Color(0xff006666),
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Center(
                                          child: Text("Edit Challan", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                      )
                                  ),
                                ),
                                SizedBox(width: 20,),


                                ///Copy Challan ---------------------------
                                InkWell(
                                  onTap: () async {
                                    await getX.Get.toNamed("/create-challan?purpose=copy&id=$selectedChallanId");
                                    fetch_challan_list();

                                  },
                                  child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Color(0xff003366),
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Center(
                                          child: Text("Copy Challan", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                      )
                                  ),
                                ),
                                SizedBox(width: 20,),


                                ///Download -----------------------------
                                InkWell(
                                  onTap: (){
                                    MotionToast.success(
                                      title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                      description:  Text("Please wait, downloading..."),
                                    ).show(context);
                                    Timer(Duration(milliseconds: 300),(){
                                      generatePdf("download",selectedChallanNumber, selectedChallanDate, selectedChallanRecipientDetails, selectedChallanGstno, selectedChallanVehicleno, selectedChallanSupplyPlace, challan_list, selectedTotalQuantity, selectedReceivedBy, selectedDeliveryBy);
                                    });
                                  },
                                  child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Color(0xff00802b),
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Center(
                                          child: Text("Download", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                      )
                                  ),
                                ),
                                SizedBox(width: 20,),

                                ///Print -----------------------------
                                InkWell(
                                  onTap: (){
                                    MotionToast.success(
                                      title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                      description:  Text("Initialing printer ..."),
                                    ).show(context);

                                    Timer(Duration(milliseconds: 300),(){
                                      generatePdf("print",selectedChallanNumber, selectedChallanDate, selectedChallanRecipientDetails, selectedChallanGstno, selectedChallanVehicleno, selectedChallanSupplyPlace, challan_list, selectedTotalQuantity, selectedReceivedBy, selectedDeliveryBy);

                                    });
                                  },
                                  child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Center(
                                          child: Text("Print", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                      )
                                  ),
                                ),
                                SizedBox(width: 20,),

                                ///Delete -------------------------------
                                InkWell(
                                  onTap: (){
                                    deleteChallan();
                                  },
                                  child: Container(
                                      width: 90,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Center(
                                          child: Text("Delete", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                      )
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15,),
                            challanView(selectedChallanNumber, selectedChallanDate, selectedChallanRecipientDetails, selectedChallanGstno, selectedChallanVehicleno, selectedChallanSupplyPlace, challan_list, selectedTotalQuantity, selectedReceivedBy, selectedDeliveryBy)
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

  Widget challanView(String challan_no, String challan_date, String recipient_details, String gst_no, String vehicle_no, String supply_place, List<notEditableChallanItem> challan_list, String total_quantity, String received_by, String delivery_by){
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset("assets/logo/logo3.png",  height: 70,),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Transmission Surgicals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.teal),),

                              SizedBox(
                                  width: 230,
                                  child: Divider(height: 5,thickness: 2,color: Colors.teal,)
                              ),
                              SizedBox(height: 2,),
                              SizedBox(
                                width: 230,
                                child:
                                Center(child: Text("Sales and Service", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.teal),)),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 7,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black.withOpacity(0.7), width: 0.5)
                                ),
                                height: 150,
                                child: Text("$address \nOffice : $office_phone\nMobile : $phone_number\nEmail : $email_id\nPAN Number : $pan_no\nGST : $gst_no\nWebsite : $website",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),)),
                          ),
                          SizedBox(width: 50,),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black.withOpacity(0.7), width: 0.5)
                              ),
                              height: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("Delivery Challan",style: GoogleFonts.alata(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                                  SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        children: [
                                          Text("Challan Number",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                          Text("Challan Date",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(" : "+challan_no,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                          Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text("Kol/TS-"+challan_no,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                          Text(formattedDate(challan_date),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                        ],
                                      )
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            width: 300,
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5, color: Colors.black.withOpacity(0.7))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Delivery Challan for :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
                                Text(recipient_details,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),

                                SizedBox(height: 15,),
                                Text("GSTIN : $gst_no",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),
                                Text("Vehicle Number : $vehicle_no",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),
                                Text("Place of Supply : $supply_place",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),
                              ],
                            ),
                          ),
                        ],
                      ),


                      SizedBox(height: 30,),



                      DataTable(
                        columns: [
                          DataColumn(label: Text('Sl. No.'),),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('HSN/SAC')),
                          DataColumn(label: Text('Quantity')),
                        ],
                        rows: [
                          ...challan_list.asMap().entries.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text((item.key + 1).toString() + ".")),
                                DataCell(Text(item.value.description.toString())),
                                DataCell(Text(item.value.hsn.toString())),
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
                        children: [
                          Text("Total Quantity", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                          SizedBox(width: 10,),
                          Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                          SizedBox(width: 10,),
                          Text(total_quantity, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                        ],
                      ),

                      SizedBox(height: 50,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              width: 300,
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0.5, color: Colors.black.withOpacity(0.7))
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Received By:", style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),),
                                  SizedBox(height: 3,),
                                  Text(received_by,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,)),
                                ],
                              ))
                        ],
                      ),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              width: 300,
                              decoration: BoxDecoration(
                                  border: Border.all(width: 0.5, color: Colors.black.withOpacity(0.7))
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Delivery By:", style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),),
                                  SizedBox(height: 3,),
                                  Text(delivery_by,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,)),
                                ],
                              ))
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
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred!"),
      ).show(context);

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
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("No challan found"),
      ).show(context);

    }
  }




  generatePdf(String purpose,String challan_no, String challan_date, String recipient_details, String gst_no, String vehicle_no, String supply_place, List<notEditableChallanItem> challan_item_list, String total_qty, String received_by, String delivery_by) async {
    pdf= pw.Document();
    final Logo = await getAssetsImage("assets/logo/logo3.png");
    List<pw.Widget> widgets = [];
    widgets.add(pw.SizedBox(height: 10,),);


    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Image(pw.MemoryImage(Logo), height: 50),
                  pw.SizedBox(width: 7,),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Transmission Surgicals", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.teal),),

                      pw.SizedBox(
                          width: 190,
                          child: pw.Divider(height: 5,thickness: 2,color: PdfColors.teal,)
                      ),
                      pw.SizedBox(height: 2,),
                      pw.SizedBox(
                        width: 190,
                        child:
                        pw.Center(child: pw.Text("Sales and Service", style: pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 10, color: PdfColors.teal),)),
                      )
                    ],
                  )
                ],
              ),

              pw.SizedBox(height: 6,),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        height: 120,
                        padding: pw.EdgeInsets.all(5),
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 0.5)
                        ),
                        child:pw.Text("$address \nOffice : $office_phone\nMobile : $phone_number\nEmail : $email_id\nPAN Number : $pan_no\nGST : $gst_no\nWebsite : $website",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black),),
                      ),
                    ),
                    pw.SizedBox(width: 50),
                    pw.Expanded(
                        child:  pw.Container(
                          height: 120,
                          padding: pw.EdgeInsets.all(5),
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black, width: 0.5)
                          ),
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text("Delivery Challan",style: pw.TextStyle(fontSize: 13,fontWeight:pw.FontWeight.bold,color: PdfColors.black),),
                              pw.SizedBox(height: 5,),
                              pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Column(
                                        children: [
                                          pw.Text("Challan Number",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                                          pw.Text("Challan Date",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                                        ]
                                    ),
                                    pw.Column(
                                        children: [
                                          pw.Text(" : ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                                          pw.Text(" : ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                                        ]
                                    ),
                                    pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text("Kol/TS-$challan_no",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                                          pw.Text(challan_date,style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                                        ]
                                    )
                                  ]
                              ),
                            ],
                          ),
                        )
                    )
                  ]
              )


            ],
          ),
        )
    );


    widgets.add( pw.SizedBox(height: 30,),);

    widgets.add(
        pw.Container(
            width: 230,
            padding: pw.EdgeInsets.all(5),
            margin: pw.EdgeInsets.only(left: 15),
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5)
            ),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Delivery Challan For :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black),),
                  pw.Text(recipient_details,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black),),
                ]
            )
        )
    );



    widgets.add(pw.SizedBox(height: 5,),);

    widgets.add(
        pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 15),
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("GSTIN", style: pw.TextStyle(fontSize: 10)),
                        pw.Text("Vehicle Number", style: pw.TextStyle(fontSize: 10)),
                        pw.Text("Place of Supply", style: pw.TextStyle(fontSize: 10)),
                      ]
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(" : ", style: pw.TextStyle(fontSize: 10)),
                        pw.Text(" : ", style: pw.TextStyle(fontSize: 10)),
                        pw.Text(" : ", style: pw.TextStyle(fontSize: 10)),
                      ]
                  ),
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(gst_no, style: pw.TextStyle(fontSize: 10)),
                        pw.Text(vehicle_no, style: pw.TextStyle(fontSize: 10)),
                        pw.Text(supply_place, style: pw.TextStyle(fontSize: 10)),
                      ]
                  )
                ]
            )
        )
    );


    widgets.add(pw.SizedBox(height: 20,),);


    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Table.fromTextArray(
              data: [
                ['#','Item Description', 'HSN/SAC','Quantity'],
                ...challan_item_list.asMap().entries.map((item) => [
                  (item.key+1).toString()+".",
                  item.value.description.toString(),
                  item.value.hsn.toString(),
                  item.value.quantity.toString(),
                ]).toList(),
              ],
              cellAlignment: pw.Alignment.centerRight,
              cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 9),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue, fontSize: 9),
              border: pw.TableBorder.all(width: 1, color: PdfColors.blue),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blue100,
              ),
              columnWidths: {
                0:pw.FlexColumnWidth(1),
                1:pw.FlexColumnWidth(4),
                2:pw.FlexColumnWidth(3),
                3:pw.FlexColumnWidth(3),
              }
          ),
        )
    );



    widgets.add(pw.SizedBox(height: 5,),);

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Total Quantity", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black),),
              pw.Text(" : ", style:pw. TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black),),

              pw.Text(total_qty, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.black),),
            ],
          ),
        )
    );




    widgets.add(
      pw.SizedBox(height: 15),
    );


    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Container(
                  width: 230,
                  padding: pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.5)
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Received By:", style: pw.TextStyle(fontSize: 10,color: PdfColors.black,fontWeight: pw.FontWeight.bold),),
                      pw.SizedBox(height: 3,),
                      pw.Text(received_by,style: pw.TextStyle(color: PdfColors.black,fontWeight: pw.FontWeight.normal, fontSize: 10,),
                      ),
                    ],
                  )
              )

            ],
          ),
        )
    );



    widgets.add(pw.SizedBox(height: 15,),);

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Container(
                  width: 230,
                  padding: pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.5)
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Delivery By:", style: pw.TextStyle(fontSize: 10,color: PdfColors.black,fontWeight: pw.FontWeight.bold),),
                      pw.SizedBox(height: 3,),
                      pw.Text(delivery_by,style: pw.TextStyle(color: PdfColors.black,fontWeight: pw.FontWeight.normal,fontSize: 10,)),
                    ],
                  )
              )
            ],
          ),
        )
    );



    widgets.add(pw.SizedBox(height: 20,),);

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Text("Thanks for your business!", style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
        )
    );
    widgets.add(pw.SizedBox(height: 30,),);



    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          buildBackground: (context){
            return pw.Container(
                width: double.infinity,
                height: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: PdfColors.black,
                      width: 0.5
                  ),
                )
            );
          },

          pageFormat: PdfPageFormat.a4,

          margin: pw.EdgeInsets.all(30),
        ),
        build: (context) => widgets,
      ),
    );

    pdf_bytes=await pdf.save();




    if(purpose=="download"){
      final blob = html.Blob([pdf_bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = "Challan$selectedChallanNumber.pdf";
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);


      MotionToast.success(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Challan Downloaded!"),
      ).show(context);

    }

    if(purpose=="print"){
      final blob = html.Blob([pdf_bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final windowFeatures = 'resizable,scrollbars,status,titlebar';
      html.window.open(url, "Print Challan", windowFeatures);
      html.Url.revokeObjectUrl(url);
    }






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
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Error while loading"),
        ).show(context);

      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }
  }

}
