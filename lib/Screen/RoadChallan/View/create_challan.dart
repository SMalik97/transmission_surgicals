import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' as getX;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:pdf/pdf.dart';
import 'package:transmission_surgicals/Screen/RoadChallan/Model/editableChallanModel.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../Utils/urls.dart';
import '../Model/noteditableChallanModel.dart';

class CreateChallan extends StatefulWidget {
  const CreateChallan({Key? key}) : super(key: key);

  @override
  State<CreateChallan> createState() => _CreateChallanState();
}

class _CreateChallanState extends State<CreateChallan> {

  bool isGenerateViewShowing=true;
  bool isDownloadViewShowing=false;
  bool isGenerating=false;
  late Uint8List pdf_bytes;
  Widget placeHolder=Container();
  final recipient_controller=TextEditingController();
  final gst_no_controller=TextEditingController();
  final vehicle_no_controller=TextEditingController();
  final supply_place_controller=TextEditingController();
  final received_by_controller=TextEditingController();
  final delivery_by_controller=TextEditingController();

  List<editableChallanModel> editable_challan_list=[];

  int total_quantity=0;
  String purpose="";
  late pw.Document pdf;

  String selectedChallanId="", selectedChallanNumber="", selectedChallanDate="", selectedChallanRecipientDetails="", selectedChallanGstno="", selectedChallanVehicleno="", selectedChallanSupplyPlace="", selectedTotalQuantity="", selectedReceivedBy="", selectedDeliveryBy="";
  List<notEditableChallanItem> challan_list=[];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            color: Color(0xff004d4d),
            child: Row(
              children: [
                SizedBox(width: 15,),
                Text("Generate Road Challan", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                       if(isGenerateViewShowing==true)
                         purpose=="edit" ? InkWell(
                           onTap: (){
                             updateChallan();
                           },
                           child: Opacity(
                             opacity: isGenerating==true? 0.7:1,
                             child: Container(
                               height: 30,
                               padding: EdgeInsets.symmetric(horizontal: 10),
                               decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(3),
                                   color: Color(0xff00802b)
                               ),
                               child: Center(child: Text(isGenerating==true ? "Saving..." :"Save Challan", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                             ),
                           ),
                         ) :
                       InkWell(
                            onTap: (){
                              createChallan();
                              // List<notEditableChallanItem> challan_items = [];
                              // notEditableChallanItem a= notEditableChallanItem(description: "description", quantity: "2", hsn: "hsn", totalAmount: "14");
                              // challan_list.add(a);
                              // generatePdf("selectedChallanId", DateFormat('dd/MM/yyyy').format(DateTime.now()), "recipient_controller.text", "gst number", "vehicle number", "place of supply", challan_list, "total_quantity", "received by", "delivery by");
                              },
                            child: Opacity(
                              opacity: isGenerating==true? 0.7:1,
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Color(0xff00802b)
                                ),
                                child: Center(child: Text(isGenerating==true ? "Generating..." :"Generate Challan", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                              ),
                            ),
                          ),

                       if(isDownloadViewShowing==true)
                       Row(
                         children: [
                           /// Download ------------
                           InkWell(
                                onTap: (){
                                  final blob = html.Blob([pdf_bytes], 'application/pdf');
                                  final url = html.Url.createObjectUrlFromBlob(blob);
                                  final anchor = html.document.createElement('a') as html.AnchorElement
                                    ..href = url
                                    ..download = "Challan$selectedChallanNumber.pdf";
                                  html.document.body?.children.add(anchor);
                                  anchor.click();
                                  html.document.body?.children.remove(anchor);
                                  html.Url.revokeObjectUrl(url);
                                  MotionToast.error(
                                    title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                    description:  Text("Downloading..."),
                                  ).show(context);

                                },
                                child: Opacity(
                                  opacity: isGenerating==true? 0.7:1,
                                  child: Container(
                                    height: 30,
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: Color(0xff00802b)
                                    ),
                                    child: Center(child: Text("Download", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                                  ),
                                ),
                              ),
                           SizedBox(width: 20,),

                           /// Print ------------
                           InkWell(
                             onTap: (){
                               final blob = html.Blob([pdf_bytes], 'application/pdf');
                               final url = html.Url.createObjectUrlFromBlob(blob);
                               final windowFeatures = 'resizable,scrollbars,status,titlebar';
                               html.window.open(url, "Print Challan", windowFeatures);
                               html.Url.revokeObjectUrl(url);

                               MotionToast.error(
                                 title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                 description:  Text("Initializing printer..."),
                               ).show(context);


                             },
                             child: Opacity(
                               opacity: isGenerating==true? 0.7:1,
                               child: Container(
                                 height: 30,
                                 padding: EdgeInsets.symmetric(horizontal: 15),
                                 decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(3),
                                     color: Colors.blue
                                 ),
                                 child: Center(child: Text("Print", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                               ),
                             ),
                           ),
                            ],
                       ),

                        SizedBox(width: 15,),
                        InkWell(
                          onTap: (){
                            if(getX.Get.parameters['id'] == null){
                              getX.Get.offAndToNamed("/create-challan");
                            }else{
                              getX.Get.offAndToNamed("/create-challan?purpose=$purpose&id=$selectedChallanId",);
                            }
                            MotionToast.error(
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
                        SizedBox(width: 15,),
                        InkWell(
                          onTap: (){
                            getX.Get.back();
                          },
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.red,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 18,),
                          ),
                        ),
                      ],
                    )
                ),
                SizedBox(width: 15,),
              ],
            ),
          ),

          placeHolder

        ],
      ),
    );
  }

  @override
  void initState() {
    if(getX.Get.parameters['id'] == null){
      editableChallanModel eii=editableChallanModel(description: "", quantity: 0, hsn: "", totalAmount: 0.00, des_controller: TextEditingController(), hsn_controller: TextEditingController(), quantity_controller: TextEditingController(),amount_controller: TextEditingController());
      editable_challan_list.add(eii);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          placeHolder=createChallanView("########",DateFormat('dd/MM/yyyy').format(DateTime.now()));
        });
      });

    }else{
      purpose = getX.Get.parameters['purpose']!;
      selectedChallanId = getX.Get.parameters['id']!;
      placeHolder=Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 25,height: 25,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 5,),
              Text("Getting ready...", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600,fontSize: 15),)
            ],
          ),
        ),
      );

      fetch_challan_details(selectedChallanId);
    }

    super.initState();
  }

  ///Editable challan view
  Widget createChallanView(String challan_no, String challan_date){
    return StatefulBuilder(
      builder: (context, setState) {
        return Expanded(
          child: Center(
            child: Container(
              width:800,
              decoration: BoxDecoration(
                color: Colors.white,
              ),

              child: Padding(
                padding: EdgeInsets.symmetric(horizontal:60),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset("assets/logo/logo.png",width: 50,height:50,),
                                  SizedBox(width: 8,),
                                  Text("Transmission Surgicals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.lightBlue),),
                                ],
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
                              Text("Challan Number: $challan_no",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              Text("Challan Date: "+challan_date,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Text("Delivery Challan for :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
                      SizedBox(height: 3,),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            width:300,
                            constraints: BoxConstraints(
                              minHeight: 100,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1),
                                border: Border.all(color: Colors.black.withOpacity(0.5),width: 1)
                            ),
                            child: TextField(
                              controller: recipient_controller,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: "Recipient Name\nRecipient Address\nRecipient Phone\nRecipient Email",
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              maxLines: null,
                              style: TextStyle(height: 1.2, color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text("GSTIN", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),),
                              SizedBox(height: 15,),
                              Text("Vehicle Number", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),),
                              SizedBox(height: 15,),
                              Text("Place of Supply", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),),
                            ],
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(" : ", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),),
                              ),
                              SizedBox(height: 15,),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(" : ", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),),
                              ),
                              SizedBox(height: 15,),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(" : ", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black),),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black87, width: 0.5),
                                    borderRadius: BorderRadius.circular(2)
                                ),
                                width: 210,
                                child: TextField(
                                  controller: gst_no_controller,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none
                                  ),
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black87, width: 0.5),
                                    borderRadius: BorderRadius.circular(2)
                                ),
                                width: 210,
                                child: TextField(
                                  controller: vehicle_no_controller,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none
                                  ),
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),

                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                padding: EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black87, width: 0.5),
                                    borderRadius: BorderRadius.circular(2)
                                ),
                                width: 210,
                                child: TextField(
                                  controller: supply_place_controller,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none
                                  ),
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),

                                ),
                              ),
                            ],
                          )
                        ],
                      ),

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
                                color: Colors.blue.shade100
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
                                    color: Colors.blue.shade100
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
                                    color: Colors.blue.shade100
                                ),
                                child: Center(
                                    child: Text("HSN/SAC", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),)
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
                              color: Colors.blue.shade100
                          ),
                          child: Center(
                              child: Text("MRP", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),)
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
                                      right: BorderSide(color: Colors.blue, width: 1),
                                    ),
                                    color: Colors.blue.shade100
                                ),
                                child: Center(
                                    child: Text("Quantity", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),)
                                ),
                              )),

                        ],
                      ),
                      ListView.builder(
                          itemCount: editable_challan_list.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index){
                            return Row(
                              children: [
                                /// Sl. No. ....................
                                Container(
                                  width: 60,
                                  constraints: BoxConstraints(
                                      minHeight: 30
                                  ),
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

                                ///Description ............
                                Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 30
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: editable_challan_list[index].des_controller,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        onChanged: (v){
                                          editable_challan_list[index].description = editable_challan_list[index].des_controller!.text;
                                        },
                                      ),
                                    )),

                                ///HSN ..............
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 30
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: editable_challan_list[index].hsn_controller,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        onChanged: (v){
                                          if(editable_challan_list[index].hsn_controller!.text.isNotEmpty){
                                            editable_challan_list[index].hsn =editable_challan_list[index].hsn_controller!.text;
                                          }

                                        },
                                      ),
                                    )),

                                /// MRP .............
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 30
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: TextField(
                                        controller: editable_challan_list[index].amount_controller,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        onChanged: (v){
                                          if(editable_challan_list[index].amount_controller!.text.isNotEmpty){
                                            setState((){
                                              editable_challan_list[index].totalAmount =double.parse(editable_challan_list[index].amount_controller!.text);
                                              calculateChallan();
                                            });
                                          }


                                        },
                                      ),
                                    )),

                                ///Quantity .......
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 30
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                          right: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: TextField(
                                        controller: editable_challan_list[index].quantity_controller,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        onChanged: (v){
                                          if(editable_challan_list[index].quantity_controller!.text.isNotEmpty){
                                            editable_challan_list[index].quantity = int.parse(editable_challan_list[index].quantity_controller!.text);
                                          }
                                          calculateChallan();
                                        },
                                      ),
                                    )),
                              ],
                            );
                          }
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: InkWell(
                              onTap: (){
                                editableChallanModel eii=editableChallanModel(description: "", quantity: 0, hsn: "", totalAmount: 0.00, des_controller: TextEditingController(), hsn_controller: TextEditingController(), quantity_controller: TextEditingController(), amount_controller: TextEditingController());
                                setState(() {
                                  editable_challan_list.add(eii);
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.add,color: Colors.blue,size: 18,),
                                  SizedBox(width: 3,),
                                  Text("Add new row", style: TextStyle(color: Colors.blue,fontSize: 14,fontWeight: FontWeight.w500),)
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Quantity", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),

                              Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),

                              Text(total_quantity.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Received By:", style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),),
                              SizedBox(height: 3,),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                width: 250,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54, width: 0.7)
                                ),
                                child: TextField(
                                  controller: received_by_controller,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: "Type details here",
                                    hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 14,)
                                  ),
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,),
                                  maxLines: 5,
                                ),
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
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                width: 250,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black54, width: 0.7)
                                ),
                                child: TextField(
                                  controller: delivery_by_controller,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: "Type details here",
                                      hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 14,)
                                  ),
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,),
                                  maxLines: 5,
                                ),
                              ),
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

            ),
          ),
        );
      },
    );
  }

  calculateChallan(){
      total_quantity = 0;
      for(int i=0; i<editable_challan_list.length; i++){
          total_quantity = total_quantity + editable_challan_list[i].quantity!;
      }
  }


  ///not editable challan view
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
                              Text("Challan Number : "+challan_no,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              Text("Challan Date : "+formattedDate(challan_date),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Text("Delivery Challan for :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
                      Text(recipient_details,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),

                      SizedBox(height: 15,),
                      Text("GSTIN : $gst_no",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),
                      Text("Vehicle Number : $vehicle_no",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),
                      Text("Place of Supply : $supply_place",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: Colors.black),),

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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Received By:", style: TextStyle(fontSize: 14,color: Colors.black,fontWeight: FontWeight.w600),),
                              SizedBox(height: 3,),
                              Text(received_by,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,),
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
                              Text(delivery_by,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14,)),
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


  /// create challan api
  createChallan() async {
    setState(() {
      isGenerating = true;
    });
    List<notEditableChallanItem> challan_items = [];
    for (int i = 0; i < editable_challan_list.length; i++) {
      notEditableChallanItem a = notEditableChallanItem(
          description: editable_challan_list[i].description.toString(),
          quantity: editable_challan_list[i].quantity.toString(),
          hsn: editable_challan_list[i].hsn!,
          totalAmount: editable_challan_list[i].totalAmount!.toStringAsFixed(
              2));
      challan_items.add(a);
    }
    String challan_item_list = jsonEncode(challan_items);
    print(challan_item_list);
    var url = Uri.parse(create_challan);
    Map<String, String> body = {
      "recipient_address": recipient_controller.text.trim(),
      "gst_number": gst_no_controller.text,
      "vehicle_number": vehicle_no_controller.text,
      "supply_place": supply_place_controller.text,
      "received_by": received_by_controller.text,
      "delivery_by": delivery_by_controller.text,
      "total_quantity": total_quantity.toStringAsFixed(2),
      "challan_items": challan_item_list
    };
    Response response = await post(url, body: body);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      if (jsonData['status'] == "success") {
        selectedChallanNumber = jsonData['challan_no'];
        generatePdf(selectedChallanId, DateFormat('dd/MM/yyyy').format(DateTime.now()), recipient_controller.text, gst_no_controller.text, vehicle_no_controller.text, supply_place_controller.text, challan_items, total_quantity.toString(),received_by_controller.text, delivery_by_controller.text);
        setState(() {
          placeHolder = challanView(
              selectedChallanNumber,
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
              recipient_controller.text.trim(),
              gst_no_controller.text,
              vehicle_no_controller.text,
              supply_place_controller.text,
              challan_items,
              total_quantity.toString(),
              received_by_controller.text,
              delivery_by_controller.text);
        });
      } else {
        setState(() {
          isGenerating = false;
        });
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Some error has occurred"),
        ).show(context);
      }
    }else{
      setState(() {
        isGenerating = false;
      });
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }


  }



  generatePdf(String challan_no, String challan_date, String recipient_details, String gst_no, String vehicle_no, String supply_place, List<notEditableChallanItem> challan_item_list, String total_qty, String received_by, String delivery_by) async {
    pdf= pw.Document();
    final invoiceLogo = await getAssetsImage("assets/logo/logo.png");
    List<pw.Widget> widgets = [];
    widgets.add(pw.SizedBox(height: 60,),);


    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
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
                  pw.Text("Road Challan",style: pw.TextStyle(fontSize: 16,fontWeight:pw.FontWeight.bold,color: PdfColors.black),),
                  pw.SizedBox(height: 5,),
                  pw.Text("Challan Number $challan_no",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                  pw.Text("Challan Date "+challan_date,style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                ],
              ),
            ],
          ),
        )
    );


    widgets.add( pw.SizedBox(height: 30,),);

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Text("Delivery Challan For :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12,color: PdfColors.black),),
        )
    );

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Text(recipient_details,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 12,color: PdfColors.black),),
        )
    );

    widgets.add(pw.SizedBox(height: 30,),);

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("GSTIN : $gst_no"),
                      pw.Text("Vehicle Number : $vehicle_no"),
                      pw.Text("Place of Supply : $supply_place"),
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
              pw.Text("Total Quantity", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
              pw.Text(" : ", style:pw. TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),

              pw.Text(total_qty, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
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
        )
    );



    widgets.add(pw.SizedBox(height: 15,),);

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
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
      description:  Text("Downloading..."),
    ).show(context);


    setState(() {
      isGenerating = false;
      isGenerateViewShowing=false;
      isDownloadViewShowing=true;
    });

    MotionToast.success(
      title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
      description:  Text("Challan Generated!"),
    ).show(context);





  }

  Future<Uint8List> getAssetsImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }


  fetch_challan_details(String challan_id) async {
    var url = Uri.parse(get_challan_details);
    Map<String, String> body = {"challan_id": challan_id};
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


        for(int i = 0; i<challan_list.length; i++){
          editableChallanModel a =editableChallanModel(description: challan_list[i].description, quantity: int.parse(challan_list[i].quantity.toString()), hsn: challan_list[i].hsn!, totalAmount: double.parse(challan_list[i].totalAmount!), des_controller: TextEditingController(), hsn_controller: TextEditingController(), quantity_controller: TextEditingController(), amount_controller: TextEditingController());
          editable_challan_list .add(a);
          editable_challan_list[i].des_controller!.text=challan_list[i].description.toString();
          editable_challan_list[i].quantity_controller!.text=challan_list[i].quantity.toString();
          editable_challan_list[i].hsn_controller!.text=challan_list[i].hsn.toString();
        }


        setState(() {
          recipient_controller.text = selectedChallanRecipientDetails;
          gst_no_controller.text=selectedChallanGstno;
          vehicle_no_controller.text=selectedChallanVehicleno;
          supply_place_controller.text=selectedChallanSupplyPlace;
          delivery_by_controller.text=selectedDeliveryBy;
          received_by_controller.text=selectedReceivedBy;

          placeHolder=createChallanView("########",DateFormat('dd/MM/yyyy').format(DateTime.now()));

        });

      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }
  }


  updateChallan() async {
    setState(() {
      isGenerating = true;
    });
    List<notEditableChallanItem> not_challan_items=[];
    for(int i =0; i<editable_challan_list.length; i++){
      notEditableChallanItem a = notEditableChallanItem(description: editable_challan_list[i].description.toString(),quantity: editable_challan_list[i].quantity.toString(),hsn: editable_challan_list[i].hsn!,totalAmount: editable_challan_list[i].totalAmount!.toStringAsFixed(2));
      not_challan_items.add(a);
    }
    String challan_item_list=jsonEncode(not_challan_items);
    var url = Uri.parse(update_road_challan);
    Map<String, String> body = {
      "challan_id":selectedChallanId,
      "recipient_address": recipient_controller.text.trim(),
      "gst_number": gst_no_controller.text,
      "vehicle_number": vehicle_no_controller.text,
      "supply_place": supply_place_controller.text,
      "received_by": received_by_controller.text,
      "delivery_by": delivery_by_controller.text,
      "total_quantity": total_quantity.toStringAsFixed(2),
      "challan_items": challan_item_list
    };
    Response response = await post(url, body: body);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      if (jsonData['status'] == "success") {
        generatePdf(selectedChallanNumber, formattedDate(selectedChallanDate), recipient_controller.text,  gst_no_controller.text, vehicle_no_controller.text, supply_place_controller.text,not_challan_items, total_quantity.toString(), received_by_controller.text, delivery_by_controller.text);
        setState(() {
          placeHolder = challanView(
              selectedChallanNumber,
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
              recipient_controller.text.trim(),
              gst_no_controller.text,
              vehicle_no_controller.text,
              supply_place_controller.text,
              not_challan_items,
              total_quantity.toString(),
              received_by_controller.text,
              delivery_by_controller.text);
        });
      } else {
        setState(() {
          isGenerating = false;
        });
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Some error has occurred"),
        ).show(context);
      }
    }else{
      setState(() {
        isGenerating = false;
      });
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("PSome error has occurred"),
      ).show(context);

    }
  }





}
