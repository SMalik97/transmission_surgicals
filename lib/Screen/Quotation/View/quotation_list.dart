import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:transmission_surgicals/Screen/Quotation/Model/general_quotation_noteditable_model.dart';
import 'package:transmission_surgicals/Screen/Quotation/Model/image_quotation_noteditable_model.dart';
import 'package:transmission_surgicals/Utils/urls.dart';
import 'package:get/get.dart' as getX;
import '../../../Utils/global_variable.dart';
import '../Model/general_quotation_list_model.dart';
import 'dart:html' as html;

import '../Model/image_quotation_model.dart';
import '../Model/image_quotation_noteditable_url_model.dart';

class QuotationList extends StatefulWidget {
  const QuotationList({Key? key}) : super(key: key);

  @override
  State<QuotationList> createState() => _QuotationListState();
}

class _QuotationListState extends State<QuotationList> {

  late pw.Document pdf;
  late Uint8List pdf_bytes;
  int selectedTab = 1;
  List<GeneralQuotationModel> general_quotation_list = [];
  List<ImageQuotationModel> image_quotation_list = [];
  List<GeneralQuotationNotEditableModel> general_quotation_items_list = [];
  List<ImageQuotationNotEditableUrlModel> image_quotation_items_url_list = [];
  bool isListLoading = true;
  bool isQuotationLoading = false;
  String selectedQuotationId = "", selectedQuotationBuyerName="", selectedQuotationBuyerDetails="", selectedQuotationBuyerContactDetails="", selectedQuotationBuyerGst="";
  String selectedQuotationDate = "",selectedQuotationSellerContactDetails="", selectedQuotationPackagingFee="", selectedQuotationSubtotal="",selectedQuotationGst="",selectedQuotationTotalAmount="";
  String selectedQuotationNo = "", selectedQuotationTitle="",selectedQuotationTerms="", selectedQuotationDeliveryFee="";
  Widget detailsPlaceHolder=Container();
  int selectedIndex = 0;

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
                Text("Quotation", style: TextStyle(fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 18),),
                SizedBox(width: 15,),
                Icon(
                  Icons.double_arrow_outlined, color: Colors.white, size: 18,),
                SizedBox(width: 15,),

                ///General Quotation
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                        isListLoading=true;
                      });
                      fetchGeneralQuotations();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2
                      ),
                      decoration: BoxDecoration(
                          color: selectedTab == 1 ? Colors.blue : Colors
                              .transparent,
                          border: Border.all(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.circular(3)
                      ),
                      child: Center(
                        child: Text("General Quotation", style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15,),

                ///Image Quotation
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = 2;
                        isListLoading=true;
                      });
                      fetchImageQuotations();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2
                      ),
                      decoration: BoxDecoration(
                          color: selectedTab == 2 ? Colors.blue : Colors
                              .transparent,
                          border: Border.all(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.circular(3)
                      ),
                      child: Center(
                        child: Text("Image Quotation", style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15,),


                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (selectedTab == 1) {
                              await getX.Get.toNamed("/create-quotation?purpose=create&type=general");
                              fetchGeneralQuotations();
                            }else{
                              await getX.Get.toNamed("/create-quotation?purpose=create&type=image");
                              fetchImageQuotations();
                            }
                          },
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Color(0xff00802b)
                            ),
                            child: Center(child: Text("Create New Quotation",
                              style: TextStyle(color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),)),
                          ),
                        ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: () {
                            fetchGeneralQuotations();
                            setState(() {
                              isListLoading=true;
                              isQuotationLoading=false;
                              selectedIndex=0;
                              selectedQuotationId="";
                              selectedTab=1;
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
                            child: Icon(Icons.refresh, color: Colors.white,
                              size: 18,),
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
                      child: isListLoading ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.green.shade700,),
                            ),
                            SizedBox(height: 5,),
                            Text("Getting quotation list ...", style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),)
                          ],
                        ),
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
                                  child: Text("Quotations list",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),)
                              )
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: selectedTab == 1 ? ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: general_quotation_list.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      selectedIndex = index;
                                      selectedQuotationId = general_quotation_list[index].id.toString();
                                      fetchGeneralQuotationDetails();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(8),
                                      height: 120,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              2),
                                          color: Color(0xffac7339)
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Text("Quotation No. KOL/TS-" +
                                                  general_quotation_list[index]
                                                      .quotationNo.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 14),),
                                              Text(general_quotation_list[index]
                                                  .date.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 11),),
                                            ],
                                          ),
                                          SizedBox(height: 8,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(
                                                      general_quotation_list[index]
                                                          .quotationTitle.toString(),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          color: Colors.white,
                                                          fontSize: 13),),
                                                    SizedBox(height: 7,),
                                                    Text(
                                                      general_quotation_list[index].buyerDetails.toString(),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white.withOpacity(0.90),
                                                          fontSize: 13), overflow: TextOverflow.fade,
                                                    ),
                                                    SizedBox(height: 3,),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text("₹" +
                                                        general_quotation_list[index].totalAmount.toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight
                                                              .bold),)
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            ) : ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: image_quotation_list.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      selectedIndex = index;
                                      selectedQuotationId = image_quotation_list[index].id.toString();
                                      fetchImageQuotationDetails();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(8),
                                      height: 120,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              2),
                                          color: Color(0xffac7339)
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Text("Quotation No. KOL/TS-" +
                                                  image_quotation_list[index]
                                                      .imageQuotationId.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 14),),
                                              Text(image_quotation_list[index]
                                                  .date.toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 11),),
                                            ],
                                          ),
                                          SizedBox(height: 8,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  Text(
                                                    image_quotation_list[index]
                                                        .quotationTitle.toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .w500,
                                                        color: Colors.white,
                                                        fontSize: 13),),
                                                  SizedBox(height: 7,),
                                                  Text(
                                                    image_quotation_list[index]
                                                        .buyerName.toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .w500,
                                                        color: Colors.white
                                                            .withOpacity(0.90),
                                                        fontSize: 13),),
                                                  SizedBox(height: 3,),
                                                  Text(
                                                    image_quotation_list[index]
                                                        .buyerAddress
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .w500,
                                                        color: Colors.white
                                                            .withOpacity(0.90),
                                                        fontSize: 12),),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Text("₹" +
                                                      image_quotation_list[index]
                                                          .totalAmount
                                                          .toString(),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight
                                                            .bold),)
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
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      color: Color(0xffccccff),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: isQuotationLoading == true ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.green.shade700,),
                            ),
                            SizedBox(height: 5,),
                            Text(
                              "Loading quotation details ...", style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),)
                          ],
                        ),
                      ) : selectedQuotationId.isEmpty ? Center(
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
                              Icon(Icons.sticky_note_2_outlined, size: 50,
                                color: Colors.deepPurpleAccent,),
                              SizedBox(height: 10,),
                              Text("Click on a quotation to view details",
                                style: TextStyle(color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15),),
                              SizedBox(height: 5,),
                              Text("OR", style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),),
                              SizedBox(height: 5,),
                              InkWell(
                                onTap: () async {
                                  if (selectedTab == 1) {
                                    await getX.Get.toNamed("/create-quotation?purpose=create&type=general");
                                    fetchGeneralQuotations();
                                  }else{
                                    await getX.Get.toNamed("/create-quotation?purpose=create&type=image");
                                    fetchImageQuotations();
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  height: 30,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Color(0xff00802b)
                                  ),
                                  child: Center(child: Text("Create Quotation",
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),)),
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
                              /// Quotation number ------------------
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                                  decoration: BoxDecoration(
                                      color: Color(0xff003366).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text("Quotation KOL/TS-"+selectedQuotationNo, style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black, fontSize: 14),)
                              ),
                              SizedBox(width: 20,),

                              ///Edit Quotation ---------------------
                              InkWell(
                                onTap: () async {
                                  await getX.Get.toNamed("/create-quotation?purpose=edit&id=$selectedQuotationId&type=$selectedTab");
                                  if(selectedTab==1){
                                   fetchGeneralQuotations();
                                  }
                                },
                                child: Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: Color(0xff006666),
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Center(
                                        child: Text("Edit Quotation", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                    )
                                ),
                              ),
                              SizedBox(width: 20,),

                              ///Copy Quotation -------------------------
                              InkWell(
                                onTap: () async {
                                  await getX.Get.toNamed("/create-quotation?purpose=copy&id=$selectedQuotationId&type=$selectedTab");
                                  if(selectedTab==1){
                                    fetchGeneralQuotations();
                                  }

                                },
                                child: Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: Color(0xff003366),
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Center(
                                        child: Text("Copy Quotation", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                    )
                                ),
                              ),
                              SizedBox(width: 20,),


                              ///Download Quotation ---------------------
                              InkWell(
                                onTap: (){
                                  MotionToast.success(
                                    title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                    description:  Text("Please wait, downloading..."),
                                  ).show(context);

                                  Timer(Duration(milliseconds: 300),(){
                                    generateGeneralPdf("download", selectedQuotationTitle, selectedQuotationBuyerDetails, selectedQuotationNo, selectedQuotationDate, selectedQuotationBuyerGst, general_quotation_items_list, selectedQuotationDeliveryFee, selectedQuotationSubtotal, selectedQuotationGst, selectedQuotationTotalAmount, selectedQuotationTerms);
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

                              ///Print Quotation ---------------------
                              InkWell(
                                onTap: (){
                                  MotionToast.success(
                                    title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                    description:  Text("Initializing printer ..."),
                                  ).show(context);

                                  Timer(Duration(milliseconds: 300),(){
                                    generateGeneralPdf("print", selectedQuotationTitle, selectedQuotationBuyerDetails, selectedQuotationNo, selectedQuotationDate, selectedQuotationBuyerGst, general_quotation_items_list, selectedQuotationDeliveryFee, selectedQuotationSubtotal, selectedQuotationGst, selectedQuotationTotalAmount, selectedQuotationTerms);

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

                              ///Delete Quotation ---------------------
                              InkWell(
                                onTap: (){
                                  deleteQuotation();
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
                          detailsPlaceHolder
                        ],
                      ),
                    ),
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
    fetchGeneralQuotations();
    super.initState();
  }

  fetchGeneralQuotations() async {
    var url = Uri.parse(fetch_general_quotation);
    Response response = await post(url);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      general_quotation_list.clear();
      jsonData.forEach((jsonResponse) {
        GeneralQuotationModel obj = new GeneralQuotationModel.fromJson(
            jsonResponse);
        setState(() {
          general_quotation_list.add(obj);
        });
      });
      if(selectedQuotationId.isNotEmpty){
        refreshIndex();
        fetchGeneralQuotationDetails();
      }
    } else {
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred!"),
      ).show(context);

    }
    setState(() {
      isListLoading = false;
    });
  }


  fetchGeneralQuotationDetails() async {
    setState(() {
      isQuotationLoading = true;
    });

    var url = Uri.parse(general_quotation_details);
    Map<String, String> body = {"id": selectedQuotationId};
    Response response = await post(url, body: body);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      selectedQuotationId = jsonData['id'].toString();
      selectedQuotationBuyerDetails = jsonData['buyer_details'].toString();
      selectedQuotationBuyerGst = jsonData['buyer_gst'].toString();
      selectedQuotationDate = jsonData['date'].toString();
      selectedQuotationSubtotal = jsonData['subtotal'].toString();
      selectedQuotationGst = jsonData['gst'].toString();
      selectedQuotationTotalAmount = jsonData['total_amount'].toString();
      selectedQuotationNo = jsonData['quotation_no'].toString();
      selectedQuotationTitle = jsonData['quotation_title'].toString();
      selectedQuotationTerms = jsonData['terms'].toString();
      selectedQuotationDeliveryFee = jsonData['delivery_fee'].toString();

      general_quotation_items_list.clear();

      jsonData['quotations_details'].forEach((jsonResponse) {
        GeneralQuotationNotEditableModel obj = new GeneralQuotationNotEditableModel.fromJson(jsonResponse);
        general_quotation_items_list.add(obj);
      });
    }


    detailsPlaceHolder = notEditableGeneralQuotation(selectedQuotationTitle, selectedQuotationBuyerDetails, selectedQuotationNo, selectedQuotationDate, selectedQuotationBuyerGst, general_quotation_items_list, selectedQuotationPackagingFee, selectedQuotationSubtotal, selectedQuotationGst, selectedQuotationTotalAmount, selectedQuotationTerms);

    setState(() {
      isQuotationLoading = false;
    });
  }


  ///not editable general quotation view
  Widget notEditableGeneralQuotation(String quotation_title, String buyer_details, String quotation_no, String quotation_date, String buyer_gst_no, List<GeneralQuotationNotEditableModel> quotation_item_list, String packaging_fee, String subtotal, String gst, String total_amount, String terms){
    return Expanded(
      child: Container(
        width: 780,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 10,),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10,),
                      Image.asset("assets/logo/logo3.png",  height: 70,),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10,),
                          Text("Transmission Surgicals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.teal),),

                          SizedBox(
                              width: 280,
                              child: Divider(height: 5,thickness: 2,color: Colors.teal,)
                          ),
                          SizedBox(height: 2,),
                          SizedBox(
                            width: 280,
                            child:
                            Center(child: Text("Sales and Service", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.teal),)),
                          )
                        ],
                      )
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Divider(color: Colors.grey, thickness: 1,  height: 10),
                  ),

                  SizedBox(height: 5,),

                  ///Quotation title ---------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(quotation_title,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600,fontSize: 14),textAlign: TextAlign.center,),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Container(
                              height: 180,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 0.3
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("TO : ", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                                          SizedBox(height: 4,),
                                          Expanded(
                                            child: Text(
                                                buyer_details,
                                                style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500, )
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 0.3
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("Customer GST : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                        Expanded(
                                          child: Text(
                                              buyer_gst_no,
                                              style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500)
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),

                        SizedBox(width: 10,),

                        Expanded(
                            flex: 5,
                            child: Container(
                              height: 180,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 0.3
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("QUOTATION NO : KOL/TS-", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500),),
                                            Expanded(
                                              child: Text(
                                                  quotation_no,
                                                  style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500)
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("QUOTATION DATE : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                            Expanded(
                                              child: Text(
                                                  quotation_date,
                                                  style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500)
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 0.3
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Bank Details : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                              Text("A/C Holder Name : $bank_ac_holder_name",
                                                  style: TextStyle(color: Colors.black,fontSize: 13, fontWeight: FontWeight.w500)
                                              ),
                                              Text("Bank Name : $bank_name",
                                                  style: TextStyle(color: Colors.black,fontSize: 13, fontWeight: FontWeight.w500)
                                              ),
                                              Text("Account Number : $bank_ac_number",
                                                  style: TextStyle(color: Colors.black,fontSize: 13, fontWeight: FontWeight.w500)
                                              ),
                                              Text("IFSC Code : $ifsc_code",
                                                  style: TextStyle(color: Colors.black,fontSize: 13, fontWeight: FontWeight.w500)
                                              ),

                                              SizedBox(height: 8,),
                                              Text("PAN Number : $pan_no",
                                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600)
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  ///Table header ..............
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Table(
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.blue),
                        outside: BorderSide(color: Colors.blue),
                      ),
                      columnWidths: {
                        0: FlexColumnWidth(0.7),
                        1: FlexColumnWidth(4),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(2),
                        6: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50
                            ),
                            children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Sl. No.",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Product Name",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "HSN Code",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Qty",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Rate",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "GST",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Amount",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                        )
                      ],
                    ),
                  ),

                  ///Table cells .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: quotation_item_list.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index){
                          return Table(
                            border: TableBorder(
                              left: BorderSide(color: Colors.blue),
                              right: BorderSide(color: Colors.blue),
                              bottom: BorderSide(color: Colors.blue),
                              verticalInside: BorderSide(color: Colors.blue),
                            ),
                            columnWidths: {
                              0: FlexColumnWidth(0.7),
                              1: FlexColumnWidth(4),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(2),
                              5: FlexColumnWidth(2),
                              6: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                  children: [
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            (index+1).toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - Product name -------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(quotation_item_list[index].productName.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - HSN code -----------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(quotation_item_list[index].hsn_code.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - quantity ----------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(quotation_item_list[index].quantity.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - Rate --------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(quotation_item_list[index].rate.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - GST --------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Column(
                                            children: [
                                              Expanded(child: Text(quotation_item_list[index].gst.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),)),
                                              Expanded(
                                                child: Text(quotation_item_list[index].gst_percentage.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11,),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - Amount --------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Center(
                                          child: Text(quotation_item_list[index].amount.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,),),
                                        ),
                                      ),
                                    ),
                                  ]
                              )
                            ],
                          );
                        }
                    ),
                  ),


                  SizedBox(height: 2,),

                  /// Delivery fee .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blue,
                                  width: 0.8
                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Delivery fee", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(packaging_fee,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Subtotal .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 0.8),
                                right: BorderSide(color: Colors.blue, width: 0.8),
                                bottom: BorderSide(color: Colors.blue, width: 0.8),

                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Subtotal", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(subtotal, style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Gst .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 0.8),
                                right: BorderSide(color: Colors.blue, width: 0.8),
                                bottom: BorderSide(color: Colors.blue, width: 0.8),

                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("GST", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(gst, style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Total amount .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 0.8),
                                right: BorderSide(color: Colors.blue, width: 0.8),
                                bottom: BorderSide(color: Colors.blue, width: 0.8),

                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Total Amount", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(total_amount, style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            color: Colors.grey.shade300,
                            child: Text("Total: "+amountToWords(int.parse(double.parse(total_amount.toString()).round().toString())), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),)
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  ///Authorized Signatory ......................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            Text("Authorized Signatory", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: Colors.black),),
                            SizedBox(height: 5,),
                            Image.asset("assets/image/sig1.jpg",height: 26,width: 100,fit: BoxFit.fill,),
                            Image.asset("assets/image/sig2.jpg",height: 26,width: 100,fit: BoxFit.fill,),
                            SizedBox(height: 5,),
                            Text("Transmission Surgicals", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: Colors.black),),
                          ],
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 50,),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Terms and Conditions : ", style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                  SizedBox(height: 3,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            terms,
                            style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                            maxLines: null,
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 50,),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// General quotation pdf generate
  generateGeneralPdf(String purpose, String quotation_title, String buyer_details, String quotation_no, String quotation_date, String buyer_gst_no, List<GeneralQuotationNotEditableModel> pdf_data_list, String delivery_fee, String subtotal, String gst, String total_amount, String terms) async {
    pdf = pw.Document();
    final Logo = await getAssetsImage("assets/logo/logo3.png");
    final sig1 = await getAssetsImage("assets/image/sig1.jpg");
    final sig2 = await getAssetsImage("assets/image/sig2.jpg");
    List<pw.Widget> pdf_widget = [];


    pdf_widget.add(
      pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(quotation_title,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 13,color: PdfColors.black ))
          ]
      ),
    );
    pdf_widget.add(
      pw.SizedBox(height: 14),
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
              children: [
                /// 1st expanded...........
                pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                        children: [

                          /// 1st container........
                          pw.Container(
                              width: double.infinity,
                              padding: pw.EdgeInsets.all(8),
                              height: 120,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                              ),
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("TO:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                    pw.SizedBox(height: 3),
                                    pw.Text(buyer_details,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(400)))
                                  ]
                              )
                          ),
                          pw.SizedBox(height: 5),

                          /// 2ND container........
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              height: 30,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                              ),
                              child: pw.Row(
                                  children: [
                                    pw.Text("Customer GST : ",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                    pw.SizedBox(height: 3),
                                    pw.Text(buyer_gst_no,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(400)))
                                  ]
                              )
                          ),


                        ]
                    )
                ),


                pw.SizedBox(width: 8),


                /// 2nd expanded...........
                pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                        children: [
                          /// 1st container...........
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              height: 50,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                              ),
                              child: pw.Column(
                                  children: [
                                    pw.Row(
                                        children: [
                                          pw.Text("QUOTATION NO : KOL/TS-",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 9,color: PdfColors.black.shade(200))),
                                          pw.SizedBox(height: 3),
                                          pw.Text(quotation_no,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 9,color: PdfColors.black.shade(400)))
                                        ]
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Row(
                                        children: [
                                          pw.Text("QUOTATION DATE:",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 9,color: PdfColors.black.shade(200))),
                                          pw.SizedBox(height: 3),
                                          pw.Text(quotation_date,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 9,color: PdfColors.black.shade(400)))
                                        ]
                                    ),

                                  ]
                              )
                          ),

                          pw.SizedBox(height: 5),

                          /// 2nd container........
                          pw.Container(
                            padding: pw.EdgeInsets.all(8),
                            height: 100,
                            width: double.infinity,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                            ),
                            child: pw.Row(
                              children: [
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("Bank Details : ", style: pw.TextStyle(color: PdfColors.black,fontSize: 10, fontWeight: pw.FontWeight.bold),),
                                    pw.Text("A/C Holder Name : $bank_ac_holder_name",
                                        style: pw.TextStyle(color: PdfColors.black,fontSize: 10, fontWeight: pw.FontWeight.normal)
                                    ),
                                    pw.Text("Bank Name : $bank_name",
                                        style: pw.TextStyle(color: PdfColors.black,fontSize: 10, fontWeight: pw.FontWeight.normal)
                                    ),
                                    pw.Text("Account Number : $bank_ac_number",
                                        style: pw.TextStyle(color: PdfColors.black,fontSize: 10, fontWeight: pw.FontWeight.normal)
                                    ),
                                    pw.Text("IFSC Code : $ifsc_code",
                                        style: pw.TextStyle(color: PdfColors.black,fontSize: 10, fontWeight: pw.FontWeight.normal)
                                    ),

                                    pw.SizedBox(height: 5,),
                                    pw.Text("PAN Number : $pan_no",
                                        style: pw.TextStyle(color: PdfColors.black,fontSize: 10, fontWeight: pw.FontWeight.bold)
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]
                    )
                ),
              ]
          ),
        )
    );

    pdf_widget.add(
      pw.SizedBox(height: 15),
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Table.fromTextArray(
              data: [
                ['Sl. No.','Product Name','HSN Code', 'Rate', 'Qty', 'GST','Amount'],
                ...pdf_data_list.asMap().entries.map((item) => [
                  (item.key+1).toString()+".",
                  item.value.productName.toString(),
                  item.value.hsn_code.toString(),
                  item.value.rate.toString(),
                  item.value.quantity.toString(),
                  item.value.gst.toString()+"\n"+item.value.gst_percentage.toString(),
                  item.value.amount.toString(),
                ]).toList(),
              ],
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 10),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              border: pw.TableBorder.all(width: 1, color: PdfColors.blue),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blue100,
              ),
              columnWidths: {
                0:pw.FlexColumnWidth(2),
                1:pw.FlexColumnWidth(4),
                2:pw.FlexColumnWidth(3),
                3:pw.FlexColumnWidth(3),
                4:pw.FlexColumnWidth(2),
                5:pw.FlexColumnWidth(3),
                6:pw.FlexColumnWidth(3),
              }
          ),
        )
    );

    pdf_widget.add(
      pw.SizedBox(height: 3),
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                    children: [
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 218,
                          height: 25,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                          ),
                          child: pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("Delivery Fee ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Text(": $delivery_fee",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 218,
                          height: 25,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                          ),
                          child: pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("Subtotal ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Text(": $subtotal",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 218,
                          height: 25,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                          ),
                          child: pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("GST ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Text(": $gst",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 218,
                          height: 25,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                          ),
                          child: pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("Total Amount ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),

                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Text(": $total_amount",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      )
                    ]
                ),

              ]
          ),
        )

    );


    pdf_widget.add(pw.SizedBox(height: 15,),);
    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  color: PdfColors.grey200,
                  child: pw.Text("Total : "+amountToWords(int.parse(double.parse(total_amount).round().toString())), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),)
              ),
            ],
          ),
        )
    );

    pdf_widget.add(
      pw.SizedBox(height: 15),
    );



    ///authorized Signatory
    pdf_widget.add(

        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("Authorized Signatory",style: pw.TextStyle(fontSize: 11,fontWeight: pw.FontWeight.bold,color: PdfColors.black))

              ]
          ),
        )

    );

    pdf_widget.add(
      pw.SizedBox(height: 8),
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Image(pw.MemoryImage(sig1),width: 100,height: 26,fit: pw.BoxFit.fill),
              ]
          ),
        )
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Image(pw.MemoryImage(sig2),width: 100,height: 26,fit: pw.BoxFit.fill),
              ]
          ),
        )
    );

    pdf_widget.add(
      pw.SizedBox(height: 8),
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child:  pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("Transmission Surgicals",style: pw.TextStyle(fontSize: 11,fontWeight: pw.FontWeight.bold,color: PdfColors.black))

              ]
          ),
        )
    );

    pdf_widget.add(
      pw.SizedBox(height: 20),
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child:  pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text("Terms and Conditions",style: pw.TextStyle(fontSize: 11,fontWeight: pw.FontWeight.bold,color: PdfColors.black))

              ]
          ),
        )
    );

    pdf_widget.add(
      pw.SizedBox(height: 2),
    );

    pdf_widget.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child:  pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(terms,style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black))
              ]
          ),
        )
    );



    pdf.addPage(
      pw.MultiPage(
          header: (context)=> pw.Column(
              children: [
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.SizedBox(width: 10,),
                    pw.Image(pw.MemoryImage(Logo), height: 60),
                    pw.SizedBox(width: 10,),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 10,),
                        pw.Text("Transmission Surgicals", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.teal),),

                        pw.SizedBox(
                            width: 180,
                            child: pw.Divider(height: 5,thickness: 1,color: PdfColors.teal,)
                        ),
                        pw.SizedBox(height: 2,),
                        pw.SizedBox(
                          width: 180,
                          child: pw.Center(child: pw.Text("Sales and Service", style: pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 10, color: PdfColors.teal),)),
                        )
                      ],
                    )
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Divider(height: 1,color: PdfColors.grey700,thickness: 0.5),
                ),
                pw.SizedBox(height: 15),
              ]
          ),

          footer: (context)=> pw.Column(
              children: [
                pw.SizedBox(height: 10),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Divider(height: 5,color: PdfColors.grey700,thickness: 0.5),
                ),

                pw.Text("This quotation is generated by Transmission Surgicals, for any concern contact at  surgicalstrans@gmail.com",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 8,color: PdfColors.black)),

                pw.SizedBox(height: 10),
              ]
          ),

          pageTheme: pw.PageTheme(
              pageFormat: PdfPageFormat.a4,
              margin: pw.EdgeInsets.all(30),
              buildBackground: (context)=> pw.Container(
                  height: double.infinity, width: double.infinity,
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0.5,color: PdfColors.black)
                  )
              )
          ),


          build: (pw.Context context){
            return pdf_widget;
          }
      ),
    );


    pdf_bytes = await pdf.save();

  if(purpose=="download"){
  final blob = html.Blob([pdf_bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
  ..href = url
  ..download = "Quotation$selectedQuotationNo.pdf";
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
  }

  if(purpose=="print"){
  final blob = html.Blob([pdf_bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final windowFeatures = 'resizable,scrollbars,status,titlebar';
  html.window.open(url, "Print Quotation", windowFeatures);
  html.Url.revokeObjectUrl(url);
  }


  Fluttertoast.showToast(
  msg: "Quotation Generated!",
  toastLength: Toast.LENGTH_SHORT,
  gravity: ToastGravity.CENTER,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.green,
  textColor: Colors.white,
  webBgColor:"linear-gradient(to right, #32a852, #32a852)",
  fontSize: 16.0
  );


  }





  Future<Uint8List> getAssetsImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }

  deleteQuotation(){
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
                Text("Are you sure you want to delete this quotation?",style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500)),
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
                        deleteQuotationApi(selectedQuotationId);
                        setState(() {
                          if(selectedTab==1){
                            general_quotation_list.removeAt(selectedIndex);
                          }
                          selectedQuotationId="";
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


  deleteQuotationApi(String quotation_id) async {
    var url = Uri.parse(delete_general_quotation);
    Map<String, String> body = {"id": quotation_id};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="Success"){

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


  refreshIndex(){
    for(int i=0; i<general_quotation_list.length; i++){
      if(general_quotation_list[i].id.toString() == selectedQuotationId){
        selectedIndex = i;
      }
    }
  }


  fetchImageQuotations() async {
    var url = Uri.parse(fetch_image_quotation);
    Response response = await post(url);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      image_quotation_list.clear();
      jsonData.forEach((jsonResponse) {
        ImageQuotationModel obj = new ImageQuotationModel.fromJson(jsonResponse);
        setState(() {
          image_quotation_list.add(obj);
        });
      });


      if(selectedQuotationId.isNotEmpty){
        refreshIndex();
        fetchImageQuotationDetails();
      }

    } else {
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred!"),
      ).show(context);

    }
    setState(() {
      isListLoading = false;
    });
  }


  fetchImageQuotationDetails() async {
    setState(() {
      isQuotationLoading = true;
    });

    var url = Uri.parse(image_quotation_details);
    Map<String, String> body = {"id": selectedQuotationId};
    Response response = await post(url, body: body);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      selectedQuotationId = jsonData['id'].toString();
      selectedQuotationBuyerName = jsonData['buyer_name'].toString();
      selectedQuotationBuyerDetails = jsonData['buyer_address'].toString();
      selectedQuotationBuyerContactDetails = jsonData['buyer_contact_details'].toString();
      selectedQuotationBuyerGst = jsonData['buyer_gst'].toString();
      selectedQuotationDate = jsonData['date'].toString();
      selectedQuotationSellerContactDetails = jsonData['seller_contact_details'].toString();
      selectedQuotationPackagingFee = jsonData['packaging_fee'].toString();
      selectedQuotationSubtotal = jsonData['subtotal'].toString();
      selectedQuotationGst = jsonData['gst'].toString();
      selectedQuotationTotalAmount = jsonData['total_amount'].toString();
      selectedQuotationNo = jsonData['quotation_no'].toString();
      selectedQuotationTitle = jsonData['quotation_title'].toString();

      image_quotation_items_url_list.clear();

      jsonData['quotations_details'].forEach((jsonResponse) {
        ImageQuotationNotEditableUrlModel obj = new ImageQuotationNotEditableUrlModel.fromJson(jsonResponse);
        image_quotation_items_url_list.add(obj);
      });
    }

    detailsPlaceHolder = notEditableImageQuotation(selectedQuotationTitle, selectedQuotationBuyerName, selectedQuotationNo, selectedQuotationBuyerDetails, selectedQuotationDate, selectedQuotationBuyerGst, selectedQuotationBuyerContactDetails, selectedQuotationSellerContactDetails, image_quotation_items_url_list, selectedQuotationPackagingFee, selectedQuotationSubtotal, selectedQuotationGst, selectedQuotationTotalAmount);



    setState(() {
      isQuotationLoading = false;
    });
  }


  ///not editable image quotation view
  Widget notEditableImageQuotation(String quotation_title, String buyer_name, String quotation_no, String buyer_address, String quotation_date, String buyer_gst_no, String buyer_contact_details, String seller_contact_details, List<ImageQuotationNotEditableUrlModel> quotation_item_list, String packaging_fee, String subtotal, String gst, String total_amount){
    return Expanded(
      child: Container(
        width: 780,
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 10,),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/logo/logo.png", width: 150, height: 150,),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Transmission Surgicals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue),),
                          Text("333 J.C. Bose Road, PallyShree\nSodepur, Kolkata - 700110 \nPhone : +91 0333335980722 / 7278360630 / 9836947573\nEmail : surgicaltrans@gmail.com",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Colors.redAccent),),
                        ],
                      )
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Divider(color: Colors.grey, thickness: 1,  height: 10),
                  ),

                  SizedBox(height: 5,),

                  ///Quotation title ---------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(quotation_title,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600,fontSize: 14),textAlign: TextAlign.center,),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  ///Buyer's name and quotation number ---------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 0.3
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("BUYER'S NAME : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                  Expanded(
                                    child: Text(buyer_name, style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                    ),
                                  )
                                ],
                              ),
                            )
                        ),

                        SizedBox(width: 2,),

                        Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 0.3
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("QUOTATION NO : KOL/TS-", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                  Expanded(
                                    child: Text(quotation_no,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                    ),
                                  )
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2,),

                  ///Buyer's address, gst no, date ---------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                              height: 65,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 0.3
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text("BUYER'S ADDRESS : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                  ),
                                  Expanded(
                                    child: Text(buyer_address,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                    ),
                                  )
                                ],
                              ),
                            )
                        ),

                        SizedBox(width: 2,),

                        Expanded(
                            child: Container(
                              height: 65,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 0.3
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("QUOTATION DATE : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                      Expanded(
                                        child: Text(quotation_date,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("BUYER'S GST NO : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                      Expanded(
                                        child: Text(buyer_gst_no,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2,),

                  ///buyer and seller contact
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                              height: 70,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 0.3
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text("BUYER'S CONTACT DETAILS: ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                  ),
                                  Expanded(
                                    child: Text(buyer_contact_details,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                    ),
                                  )
                                ],
                              ),
                            )
                        ),

                        SizedBox(width: 2,),

                        Expanded(
                            child: Container(
                              height: 70,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black, width: 0.3
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text("SELLER'S CONTACT DETAILS : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                  ),
                                  Expanded(
                                    child: Text(seller_contact_details,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                    ),
                                  )
                                ],
                              ),
                            )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  ///Table header ..............
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Table(
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.blue),
                        outside: BorderSide(color: Colors.blue),
                      ),
                      columnWidths: {
                        0: FlexColumnWidth(0.9),
                        1: FlexColumnWidth(5.2),
                        2: FlexColumnWidth(5.5),
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(2),
                        6: FlexColumnWidth(2)
                      },
                      children: [
                        TableRow(
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50
                            ),
                            children: [
                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Sl. No.",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Product Name",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Picture",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Qty",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Rate",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "GST",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),

                              TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: SizedBox(
                                  height: 30,
                                  child: Center(
                                    child: Text(
                                      "Amount",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: Colors.blue.shade700),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                        )
                      ],
                    ),
                  ),

                  ///Table cells .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: quotation_item_list.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index){
                          return Table(
                            border: TableBorder(
                              left: BorderSide(color: Colors.blue),
                              right: BorderSide(color: Colors.blue),
                              bottom: BorderSide(color: Colors.blue),
                              verticalInside: BorderSide(color: Colors.blue),
                            ),
                            columnWidths: {
                              0: FlexColumnWidth(0.9),
                              1: FlexColumnWidth(5.2),
                              2: FlexColumnWidth(5.5),
                              3: FlexColumnWidth(2),
                              4: FlexColumnWidth(2),
                              5: FlexColumnWidth(2),
                              6: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                  children: [
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Center(
                                          child: Text(
                                            (index+1).toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - Product name -------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(quotation_item_list[index].productName.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - Image -----------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 150,
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                            child: Image.network(product_image_base_path + quotation_item_list[index].ImageName.toString(),)
                                        ),
                                      ),
                                    ),

                                    /// Cell - quantity ----------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(quotation_item_list[index].quantity.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - Rate --------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(quotation_item_list[index].rate.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - GST --------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Column(
                                            children: [
                                              Expanded(child: Text(quotation_item_list[index].gst.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),)),
                                              Expanded(
                                                child: Text(quotation_item_list[index].gst_percentage.toString(),style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11,),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Cell - Amount --------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 40,
                                        child: Center(
                                          child: Text(quotation_item_list[index].amount.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,),),
                                        ),
                                      ),
                                    ),
                                  ]
                              )
                            ],
                          );
                        }
                    ),
                  ),


                  SizedBox(height: 2,),

                  /// Packaging and forwarding .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blue,
                                  width: 0.8
                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Packaging & Forwarding", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(packaging_fee,style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Subtotal .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 0.8),
                                right: BorderSide(color: Colors.blue, width: 0.8),
                                bottom: BorderSide(color: Colors.blue, width: 0.8),

                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Subtotal", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(subtotal, style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Gst .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 0.8),
                                right: BorderSide(color: Colors.blue, width: 0.8),
                                bottom: BorderSide(color: Colors.blue, width: 0.8),

                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("GST", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(gst, style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Total amount .................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: Colors.blue, width: 0.8),
                                right: BorderSide(color: Colors.blue, width: 0.8),
                                bottom: BorderSide(color: Colors.blue, width: 0.8),

                              )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Total Amount", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                              SizedBox(width: 8,),

                              Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                              SizedBox(width: 8,),

                              Container(
                                width: 120,
                                child: Text(total_amount, style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 5,),

                  /// GST no ----------------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("GST NO. $gst_no", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),)
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                  ///Authorized Signatory ......................
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            Text("Authorized Signatory", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: Colors.black),),
                            SizedBox(height: 5,),
                            Image.asset("assets/image/sig1.jpg",height: 26,width: 100,fit: BoxFit.fill,),
                            Image.asset("assets/image/sig2.jpg",height: 26,width: 100,fit: BoxFit.fill,),
                            SizedBox(height: 5,),
                            Text("Transmission Surgicals", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,color: Colors.black),),
                          ],
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 20,),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  String amountToWords(int amount) {
    if(amount==0){
      return "";
    }

    String words = capitalizeSentence(NumberToWord().convert('en-in', amount).trim()) + ' rupees only';

    return words;
  }

  String capitalizeSentence(String sentence) {
    if(sentence.length == 0){
      return "";
    }
    List<String> words = sentence.split(' ');
    List<String> capitalizedWords = [];

    String capitalizedWord="";
    for (String word in words) {
      if(word.length>=2){
        capitalizedWord = word.substring(0, 1).toUpperCase() + word.substring(1);
      }else{
        capitalizedWord = word.substring(0, 1).toUpperCase();
      }

      capitalizedWords.add(capitalizedWord);
    }

    String capitalizedSentence = capitalizedWords.join(' ');
    return capitalizedSentence;
  }




}
