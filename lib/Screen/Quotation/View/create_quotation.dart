import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' as getX;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../Utils/global_variable.dart';
import '../../../Utils/urls.dart';
import '../Model/general_quotation_editable_model.dart';
import '../Model/general_quotation_noteditable_model.dart';
import '../Model/image_quotation_editable_model.dart';
import '../Model/image_quotation_noteditable_model.dart';
import 'dart:html' as html;

import '../Model/product_image_model.dart';

class CreateQuotation extends StatefulWidget {
  const CreateQuotation({Key? key}) : super(key: key);

  @override
  State<CreateQuotation> createState() => _CreateQuotationState();
}

class _CreateQuotationState extends State<CreateQuotation> {

  final quotation_title_controller = TextEditingController();
  List<GeneralQuotationEditableModel> general_quotation_editable_list=[];
  late pw.Document pdf;
  late Uint8List pdf_bytes;
  bool showGeneratedPdf=false;
  List<GeneralQuotationNotEditableModel> list=[];
  Widget placeHolder = Container();
  List<ImageQuotationEditableModel> image_quotation_editable_list = [];
  final product_search_controller = TextEditingController();
  final packaging_controller = TextEditingController();
  bool imageLoading=false;
  List<ProductDetails> product_image=[];
  final buyer_details_controller =TextEditingController();
  final buyer_address_controller =TextEditingController();
  final quotation_no_controller =TextEditingController();
  final quotation_date_controller =TextEditingController();
  final customer_gst_no_controller =TextEditingController();
  final buyer_contact_details =TextEditingController();
  final seller_contact_details =TextEditingController();
  final subtotal_controller =TextEditingController();
  final gst_controller =TextEditingController();
  final total_amount_controller =TextEditingController();
  final terms_controller =TextEditingController();
  final total_word_controller =TextEditingController();
  bool isGenerating=false;
  int selectedTab=1;
  String selectedQuotationId="", purpose="",selectedQuotationBuyerName="", selectedQuotationBuyerDetails="", selectedQuotationBuyerContactDetails="", selectedQuotationBuyerGst="";
  String selectedQuotationDate = "",selectedQuotationSellerContactDetails="", selectedQuotationDeliveryFee="", selectedQuotationSubtotal="",selectedQuotationGst="",selectedQuotationTotalAmount="";
  String selectedQuotationNo = "", selectedQuotationTitle="", selectedQuotationTerms="";
  bool isQuotationLoading=false;
  double total_amount=0, total_gst=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Column(
        children: [
          ///Appbar
          Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            color: Color(0xff004d4d),
            child: Row(
              children: [
                SizedBox(width: 15,),
                Text("Quotation", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),


                SizedBox(width: 20,),


                ///General Quotation
                InkWell(
                  onTap: (){
                    setState(() {
                      placeHolder=editableGenerateQuotation();
                      selectedTab = 1;
                    });
                  },
                  child: Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue, width: 1),
                        color: selectedTab == 1 ? Colors.blue : Colors.transparent
                    ),
                    child: Center(child: Text("General Quotation", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                  ),
                ),

                SizedBox(width: 20,),

                InkWell(
                  onTap: (){
                    setState(() {
                      placeHolder=editableImageQuotation();
                      selectedTab = 2;
                    });
                  },
                  child: Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 1),
                        borderRadius: BorderRadius.circular(15),
                        color: selectedTab == 2 ? Colors.blue : Colors.transparent
                    ),
                    child: Center(child: Text("Quotation with Image", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                  ),
                ),


                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(width: 15,),
                        showGeneratedPdf==true?
                        InkWell(
                          onTap: (){
                            final blob = html.Blob([pdf_bytes], 'application/pdf');
                            final url = html.Url.createObjectUrlFromBlob(blob);
                            final anchor = html.document.createElement('a') as html.AnchorElement
                              ..href = url
                              ..download = 'Quotation'+selectedQuotationNo+'.pdf';
                            html.document.body?.children.add(anchor);
                            anchor.click();
                            html.document.body?.children.remove(anchor);
                            html.Url.revokeObjectUrl(url);
                            },
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Color(0xff00802b)
                            ),
                            child: Center(child: Text("Download", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                          ),
                        )
                        : (getX.Get.parameters['purpose'].toString()=="edit") ?  InkWell(
                          onTap: isGenerating ==true? null :(){
                            List<GeneralQuotationNotEditableModel> quotation_item_list=[];
                            for(int i=0; i<general_quotation_editable_list.length; i++){
                              GeneralQuotationNotEditableModel a= GeneralQuotationNotEditableModel(productName: general_quotation_editable_list[i].product_name, hsn_code: general_quotation_editable_list[i].hsn_no, amount: general_quotation_editable_list[i].amount, rate: general_quotation_editable_list[i].rate, quantity: general_quotation_editable_list[i].quantity, gst_percentage: general_quotation_editable_list[i].gst_percentage, gst: general_quotation_editable_list[i].gst);
                              quotation_item_list.add(a);
                            }
                            updateGeneralQuotation(selectedQuotationId,quotation_title_controller.text,buyer_details_controller.text, buyer_address_controller.text, buyer_contact_details.text, customer_gst_no_controller.text, quotation_date_controller.text, seller_contact_details.text, packaging_controller.text, subtotal_controller.text, gst_controller.text, total_amount_controller.text, quotation_item_list, terms_controller.text);

                            },
                          child: Opacity(
                            opacity: isGenerating ? 0.5 : 1,
                            child: Container(
                              height: 30,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Color(0xff00802b)
                              ),
                              child: Center(child: Text(isGenerating ? 'Updating...' : "Update Quotation", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                            ),
                          ),
                        ) : InkWell(
                            onTap: isGenerating ==true? null :(){
                              if(selectedTab==1){
                                List<GeneralQuotationNotEditableModel> quotation_item_list=[];
                                for(int i=0; i<general_quotation_editable_list.length; i++){
                                  GeneralQuotationNotEditableModel a= GeneralQuotationNotEditableModel(productName: general_quotation_editable_list[i].product_name, hsn_code: general_quotation_editable_list[i].hsn_no, amount: general_quotation_editable_list[i].amount, rate: general_quotation_editable_list[i].rate, quantity: general_quotation_editable_list[i].quantity, gst_percentage: general_quotation_editable_list[i].gst_percentage, gst: general_quotation_editable_list[i].gst);
                                  quotation_item_list.add(a);
                                }
                                createGeneralQuotation(quotation_title_controller.text,buyer_details_controller.text, customer_gst_no_controller.text, quotation_date_controller.text,packaging_controller.text, subtotal_controller.text, gst_controller.text, total_amount_controller.text, quotation_item_list,terms_controller.text.trim());
                              }else{
                                List<ImageQuotationNotEditableModel> quotation_item_list=[];
                                for(int i=0; i<image_quotation_editable_list.length; i++){
                                  ImageQuotationNotEditableModel a= ImageQuotationNotEditableModel(productName: image_quotation_editable_list[i].product_name, amount: image_quotation_editable_list[i].amount, rate: image_quotation_editable_list[i].rate, quantity: image_quotation_editable_list[i].quantity, gst_percentage: image_quotation_editable_list[i].gst_percentage, gst: image_quotation_editable_list[i].gst, imageId: image_quotation_editable_list[i].ImageId.toString(),ImageData: image_quotation_editable_list[i].ImageData);
                                  quotation_item_list.add(a);
                                }
                                createImageQuotation(quotation_title_controller.text, buyer_details_controller.text, customer_gst_no_controller.text, quotation_date_controller.text, packaging_controller.text, subtotal_controller.text, gst_controller.text, total_amount_controller.text, quotation_item_list, terms_controller.text.trim());
                              }

                              },
                            child: Opacity(
                              opacity: isGenerating ? 0.5 : 1,
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Color(0xff00802b)
                                ),
                                child: Center(child: Text(isGenerating ? 'Generating...' : "Generate Quotation", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                              ),
                            ),
                          ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: (){
                            if(getX.Get.parameters['id'] == null){
                              getX.Get.offAndToNamed("/create-quotation");
                            }else{
                              getX.Get.offAndToNamed("/create-quotation?purpose=$purpose&id=$selectedQuotationId",);
                            }
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
    quotation_title_controller.text="QUOTATION FOR GENERAL INSTRUMENTS";
    GeneralQuotationEditableModel a =GeneralQuotationEditableModel(product_name: "", hsn_no: "", quantity: "", rate: "",gst: "", gst_percentage: "12%", amount: "", product_name_controller: TextEditingController(), hsn_no_controller: TextEditingController(), quantity_controller: TextEditingController(), rate_controller: TextEditingController(), gst_percentage_controller: TextEditingController(), amount_controller: TextEditingController(), gst_controller: TextEditingController());
    general_quotation_editable_list.add(a);
    general_quotation_editable_list[0].gst="0";
    general_quotation_editable_list[0].gst_percentage_controller!.text ="12%";

    ImageQuotationEditableModel b =ImageQuotationEditableModel(product_name: "",quantity: "", rate: "",gst: "0",gst_percentage: "1%", amount: "0", product_name_controller: TextEditingController(), quantity_controller: TextEditingController(), rate_controller: TextEditingController(), gst_percentage_controller: TextEditingController(), isSelectImage: false, ImageId: "",ImageData: null, gst_controller: TextEditingController(), amount_controller: TextEditingController());
    image_quotation_editable_list.add(b);
    image_quotation_editable_list[0].gst_controller!.text="0";
    image_quotation_editable_list[0].gst_percentage_controller!.text ="12%";

    packaging_controller.text="00";
    terms_controller.text="1. Here it's a sample terms conditions\n2.Here it's a sample terms conditions";

    if(getX.Get.parameters['purpose']=="create"){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if(getX.Get.parameters['type']=="general"){
          setState(() {
            placeHolder=editableGenerateQuotation();
            selectedTab=1;
          });
        }else{
          setState(() {
            placeHolder=editableImageQuotation();
            selectedTab=2;
          });
        }


      });
    }else{
      purpose=getX.Get.parameters['purpose']!;
      selectedQuotationId=getX.Get.parameters['id']!;
      selectedTab=int.parse(getX.Get.parameters['type']!);

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
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
                  Text("Getting ready...", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600,fontSize: 15),)
                ],
              ),
            ),
          );
        });
      });

      if(selectedTab==1){
        fetchGeneralQuotationDetails();
      }


    }


    super.initState();
  }

  /// General quotation editable widget
  Widget editableGenerateQuotation(){
    if(getX.Get.parameters['purpose'] == "create"){
      quotation_no_controller.text="Auto Generated";
      quotation_date_controller.text="Auto Generated";
      packaging_controller.text="0.00";
      subtotal_controller.text="0.00";
      gst_controller.text="0.00";
      total_amount_controller.text="0.00";
    }else{
      quotation_no_controller.text=selectedQuotationNo;
      quotation_date_controller.text=selectedQuotationDate;
      quotation_title_controller.text=selectedQuotationTitle;
      buyer_details_controller.text=selectedQuotationBuyerDetails;
      buyer_contact_details.text=selectedQuotationBuyerContactDetails;
      customer_gst_no_controller.text=selectedQuotationBuyerGst;
      seller_contact_details.text=selectedQuotationSellerContactDetails;
      subtotal_controller.text=selectedQuotationSubtotal;
      packaging_controller.text=selectedQuotationDeliveryFee;
      gst_controller.text=selectedQuotationGst;
      total_amount_controller.text=selectedQuotationTotalAmount;
      terms_controller.text=selectedQuotationTerms;
      total_word_controller.text = "Total : "+amountToWords(int.parse(double.parse(selectedQuotationTotalAmount).round().toString()));

    }

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
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
                          SizedBox(width: 20,),
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
                              child: TextField(
                                controller: quotation_title_controller,
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: "Type Quotation title here",
                                    hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 16)
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.black,fontSize: 16
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 20,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Container(
                                  height: 180,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
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
                                                child: TextField(
                                                    controller: buyer_details_controller,
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        border: InputBorder.none,
                                                        hintText: "Type customer details here...",
                                                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 14, fontWeight: FontWeight.w500)
                                                    ),
                                                    maxLines: null,
                                                    style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600, )
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
                                              child: TextField(
                                                  controller: customer_gst_no_controller,
                                                  decoration: InputDecoration(
                                                      isDense: true,
                                                      border: InputBorder.none
                                                  ),
                                                  style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
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
                                                Text("QUOTATION NO : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                                Expanded(
                                                  child: TextField(
                                                      readOnly: true,
                                                      controller: quotation_no_controller,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text("QUOTATION DATE : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                                Expanded(
                                                  child: TextField(
                                                      readOnly: true,
                                                      controller: quotation_date_controller,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
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
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(1),
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
                            itemCount: general_quotation_editable_list.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return  Table(
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
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(1),
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
                                              child: TextField(
                                                controller: general_quotation_editable_list[index].product_name_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none
                                                ),
                                                maxLines: 1,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  general_quotation_editable_list[index].product_name=general_quotation_editable_list[index].product_name_controller!.text;
                                                },
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
                                              child: TextField(
                                                controller: general_quotation_editable_list[index].hsn_no_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none
                                                ),
                                                maxLines: 1,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  general_quotation_editable_list[index].hsn_no=general_quotation_editable_list[index].hsn_no_controller!.text;
                                                },
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
                                              child: TextField(
                                                controller: general_quotation_editable_list[index].rate_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none
                                                ),
                                                maxLines: 1,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  general_quotation_editable_list[index].rate=general_quotation_editable_list[index].rate_controller!.text;
                                                  calculateGeneralQuotation();
                                                },
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
                                              child: TextField(
                                                controller: general_quotation_editable_list[index].quantity_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none
                                                ),
                                                maxLines: 1,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  setState((){
                                                    general_quotation_editable_list[index].quantity=general_quotation_editable_list[index].quantity_controller!.text;
                                                    calculateGeneralQuotation();
                                                  });
                                                },
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
                                                  Expanded(child: TextField(
                                                    controller: general_quotation_editable_list[index].gst_controller,
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        border: InputBorder.none
                                                    ),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                    onChanged: (v){
                                                      general_quotation_editable_list[index].gst=general_quotation_editable_list[index].gst_controller!.text;
                                                    },
                                                  ),),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: general_quotation_editable_list[index].gst_percentage_controller,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11,),
                                                      onChanged: (v){
                                                        general_quotation_editable_list[index].gst_percentage=general_quotation_editable_list[index].gst_percentage_controller!.text;
                                                        setState((){
                                                          calculateGeneralQuotation();
                                                        });
                                                      },
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
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                                    child: TextField(
                                                      controller: general_quotation_editable_list[index].amount_controller,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      maxLines: 1,
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                      onChanged: (v){
                                                        general_quotation_editable_list[index].amount=general_quotation_editable_list[index].amount_controller!.text;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Transform.translate(
                                                    offset: Offset(10,0),
                                                    child: InkWell(
                                                        onTap: (){
                                                          setState((){
                                                            general_quotation_editable_list.removeAt(index);
                                                          });
                                                          calculateGeneralQuotation();
                                                        },
                                                        child: Icon(Icons.close, size: 20, color: Colors.red,)
                                                    )
                                                )
                                              ],
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: InkWell(
                          onTap: (){
                            GeneralQuotationEditableModel a =GeneralQuotationEditableModel(product_name: "", hsn_no: "", quantity: "", rate: "",gst: "", gst_percentage: "12%", amount: "0", product_name_controller: TextEditingController(), hsn_no_controller: TextEditingController(), quantity_controller: TextEditingController(), rate_controller: TextEditingController(), gst_percentage_controller: TextEditingController(), amount_controller: TextEditingController(), gst_controller: TextEditingController());
                            setState(() {
                              general_quotation_editable_list.add(a);
                              general_quotation_editable_list[general_quotation_editable_list.length - 1].gst_percentage_controller!.text="12%";
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

                      SizedBox(height: 2,),

                      /// Delivery .................
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
                                  Text("Delivery Charge", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                                  SizedBox(width: 8,),

                                  Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                                  SizedBox(width: 8,),

                                  Container(
                                    width: 120,
                                    child: TextField(
                                      controller: packaging_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),
                                      onChanged: (v){
                                        calculateGeneralQuotation();
                                      },
                                    ),
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
                                    child: TextField(
                                      controller: subtotal_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
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
                                    child: TextField(
                                      controller: gst_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
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
                                    child: TextField(
                                      controller: total_amount_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),

                                    ),
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
                              width: 350,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              color: Colors.grey.shade300,
                              child: TextField(
                                controller: total_word_controller,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                              ),
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
                              child: TextField(
                                controller:terms_controller,
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none
                                ),
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
      },

    );
  }


  /// General quotation pdf generate
  generateGeneralPdf(String quotation_title, String buyer_details, String quotation_no, String quotation_date, String buyer_gst_no, List<GeneralQuotationNotEditableModel> pdf_data_list, String delivery_fee, String subtotal, String gst, String total_amount, String terms) async {
    pdf = pw.Document();
    final sig1 = await getAssetsImage("assets/image/sig1.jpg");
    final sig2 = await getAssetsImage("assets/image/sig2.jpg");
    final Logo = await getAssetsImage("assets/logo/logo3.png");
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
                                        pw.Text("QUOTATION NO:",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 9,color: PdfColors.black.shade(200))),
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

    MotionToast.success(
      title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
      description:  Text("Quotation Generated!"),
    ).show(context);


    setState(() {
      showGeneratedPdf=true;
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
                                            Text("QUOTATION NO : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500),),
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
                            child: Text("Total: "+amountToWords(int.parse(double.parse(total_amount).round().toString())), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),)
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


  ///Image quotation editable widget
  Widget editableImageQuotation(){


    if(getX.Get.parameters['purpose'] == "create"){
      quotation_no_controller.text="Auto Generated";
      quotation_date_controller.text="Auto Generated";
      packaging_controller.text="0.00";
      subtotal_controller.text="0.00";
      gst_controller.text="0.00";
      total_amount_controller.text="0.00";
    }else{
      quotation_no_controller.text=selectedQuotationNo;
      quotation_date_controller.text=selectedQuotationDate;
      quotation_title_controller.text=selectedQuotationTitle;
      buyer_details_controller.text=selectedQuotationBuyerDetails;
      buyer_contact_details.text=selectedQuotationBuyerContactDetails;
      customer_gst_no_controller.text=selectedQuotationBuyerGst;
      seller_contact_details.text=selectedQuotationSellerContactDetails;
      subtotal_controller.text=selectedQuotationSubtotal;
      packaging_controller.text=selectedQuotationDeliveryFee;
      gst_controller.text=selectedQuotationGst;
      total_amount_controller.text=selectedQuotationTotalAmount;
      terms_controller.text=selectedQuotationTerms;
      total_word_controller.text = "Total : "+amountToWords(int.parse(double.parse(selectedQuotationTotalAmount).round().toString()));

    }


    return StatefulBuilder(
      builder: (context, setState) {
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
                          SizedBox(width: 20,),
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
                              child: TextField(
                                controller: quotation_title_controller,
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    hintText: "Type Quotation title here",
                                    hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 16)
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.black,fontSize: 16
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 20,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Container(
                                  height: 180,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
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
                                                child: TextField(
                                                    controller: buyer_details_controller,
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        border: InputBorder.none,
                                                        hintText: "Type customer details here...",
                                                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 14, fontWeight: FontWeight.w500)
                                                    ),
                                                    maxLines: null,
                                                    style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600, )
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
                                              child: TextField(
                                                  controller: customer_gst_no_controller,
                                                  decoration: InputDecoration(
                                                      isDense: true,
                                                      border: InputBorder.none
                                                  ),
                                                  style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
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
                                                Text("QUOTATION NO : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                                Expanded(
                                                  child: TextField(
                                                      readOnly: true,
                                                      controller: quotation_no_controller,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text("QUOTATION DATE : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                                                Expanded(
                                                  child: TextField(
                                                      readOnly: true,
                                                      controller: quotation_date_controller,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)
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
                                          "Product Details",
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
                            itemCount: image_quotation_editable_list.length,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index){
                              return  Table(
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
                                  6: FlexColumnWidth(2)
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

                                        /// Cell - Product details -------------
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: SizedBox(
                                            height: image_quotation_editable_list[index].isSelectImage == true ? 150 : 40,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                              child: TextField(
                                                controller: image_quotation_editable_list[index].product_name_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                ),
                                                maxLines: null,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  image_quotation_editable_list[index].product_name = image_quotation_editable_list[index].product_name_controller!.text;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// Cell - Image  -----------------
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: SizedBox(
                                            height: image_quotation_editable_list[index].isSelectImage == true ? 150 : 40,
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: (){

                                                        Dialog image_dialog= Dialog(
                                                          backgroundColor: Colors.white,
                                                          child: StatefulBuilder(
                                                            builder: (context, setState) {
                                                              return Container(
                                                                padding: EdgeInsets.all(10),
                                                                width: 400,
                                                                height: 580,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(5),
                                                                    color: Colors.grey.shade100
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text('Product Images',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),),
                                                                    SizedBox(height: 10),
                                                                    TextField(
                                                                      controller: product_search_controller,
                                                                      decoration: InputDecoration(
                                                                          isDense: true,
                                                                          hintText: "Search by product name"
                                                                      ),
                                                                      maxLines: 1,
                                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                                      onSubmitted: (v){
                                                                        fetch_image_list(product_search_controller.text.trim(),setState);
                                                                      },
                                                                    ),
                                                                    SizedBox(height: 10),
                                                                    Expanded(
                                                                        child: GridView.builder(
                                                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                              crossAxisCount: 3,
                                                                              crossAxisSpacing: 10,
                                                                              mainAxisSpacing: 10,
                                                                            ),
                                                                            itemCount: product_image.length,
                                                                            itemBuilder: (context, index){
                                                                              return Container(
                                                                                padding: EdgeInsets.all(8),
                                                                                color: Colors.white,
                                                                                child: Column(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: InkWell(
                                                                                        onTap: (){
                                                                                          getX.Get.back(result: [product_image_base_path+product_image[index].imageList![0].imageName.toString(),  product_image[index].productId.toString(),]);
                                                                                        },
                                                                                        child: Container(
                                                                                          width: double.infinity,
                                                                                          decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(2),
                                                                                              color: Colors.white
                                                                                          ),
                                                                                          child: Image.network(product_image_base_path+product_image[index].imageList![0].imageName.toString(),fit: BoxFit.fill,),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(height: 5,),
                                                                                    Text(product_image[index].productName.toString(),style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black),)
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }
                                                                        )
                                                                    )

                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                        showDialog(context: context, builder: (BuildContext context) => image_dialog).then((value) async {
                                                          if(value != null){
                                                            Response response = await get(Uri.parse(value[0]));
                                                            setState((){
                                                              image_quotation_editable_list[index].isSelectImage = true;
                                                              image_quotation_editable_list[index].ImageId = value[1];
                                                              image_quotation_editable_list[index].ImageData = response.bodyBytes;
                                                            });
                                                          }
                                                        });
                                                      },
                                                      child: image_quotation_editable_list[index].isSelectImage == true ? Stack(
                                                          alignment: Alignment.topRight,
                                                          children: [
                                                            Image.memory(image_quotation_editable_list[index].ImageData!,height: 140,),
                                                            InkWell(
                                                              onTap: (){
                                                                setState(() {
                                                                  image_quotation_editable_list[index].isSelectImage = false;
                                                                });
                                                              },
                                                              child: Container(
                                                                width: 16,
                                                                height: 16,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: Colors.white
                                                                ),
                                                                child: Center(child: Icon(Icons.close,size: 10,color: Colors.grey,)),
                                                              ),
                                                            )
                                                          ])
                                                          :Container(
                                                        height: 25,
                                                        width: 85,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(5),
                                                          color: Colors.grey.shade300,
                                                        ),
                                                        child: Center(
                                                          child: Text("Select Image",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.black),),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ),
                                          ),
                                        ),

                                        /// Cell - quantity ----------------
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: SizedBox(
                                            height: image_quotation_editable_list[index].isSelectImage == true ? 150 : 40,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                              child: TextField(
                                                controller: image_quotation_editable_list[index].quantity_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                ),
                                                maxLines: 1,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  image_quotation_editable_list[index].quantity = image_quotation_editable_list[index].quantity_controller!.text;
                                                  calculateImageQuotation();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// Cell - Rate --------------
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: SizedBox(
                                            height: image_quotation_editable_list[index].isSelectImage == true ? 150 : 40,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                              child: TextField(
                                                controller: image_quotation_editable_list[index].rate_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                ),
                                                maxLines: 1,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  image_quotation_editable_list[index].rate = image_quotation_editable_list[index].rate_controller!.text;
                                                  calculateImageQuotation();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// Cell - GST --------------
                                        TableCell(
                                          verticalAlignment: TableCellVerticalAlignment.middle,
                                          child: SizedBox(
                                            height: image_quotation_editable_list[index].isSelectImage == true ? 150 : 40,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                      height: 25,
                                                      child: TextField(
                                                    controller: image_quotation_editable_list[index].gst_controller,
                                                    decoration: InputDecoration(
                                                        isDense: true,
                                                        border: InputBorder.none
                                                    ),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                  )),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: image_quotation_editable_list[index].gst_percentage_controller,
                                                      decoration: InputDecoration(
                                                          isDense: true,
                                                          border: InputBorder.none
                                                      ),
                                                      maxLines: 1,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11,),
                                                      onChanged: (v){
                                                        image_quotation_editable_list[index].gst_percentage = image_quotation_editable_list[index].gst_percentage_controller!.text;
                                                        calculateImageQuotation();
                                                      },
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
                                            height: image_quotation_editable_list[index].isSelectImage == true ? 150 : 40,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                              child: TextField(
                                                controller: image_quotation_editable_list[index].amount_controller,
                                                decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                ),
                                                maxLines: 1,
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14,),
                                                onChanged: (v){
                                                  image_quotation_editable_list[index].amount = image_quotation_editable_list[index].amount_controller!.text;
                                                },
                                              ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: InkWell(
                          onTap: (){
                            ImageQuotationEditableModel a =ImageQuotationEditableModel(product_name: "",quantity: "", rate: "",gst: "0",gst_percentage: "1%", amount: "0", product_name_controller: TextEditingController(),quantity_controller: TextEditingController(), rate_controller: TextEditingController(), gst_percentage_controller: TextEditingController(),  isSelectImage: false, ImageId: "",ImageData: null, gst_controller: TextEditingController(), amount_controller: TextEditingController());
                            setState(() {
                              image_quotation_editable_list.add(a);
                              image_quotation_editable_list[image_quotation_editable_list.length-1].gst_controller!.text="0";
                              image_quotation_editable_list[image_quotation_editable_list.length-1].gst_percentage_controller!.text ="12%";
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
                                  Text("Delivery Charge", style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),

                                  SizedBox(width: 8,),

                                  Text(":",style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600)),

                                  SizedBox(width: 8,),

                                  Container(
                                    width: 120,
                                    child: TextField(
                                      controller: packaging_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),
                                     onChanged: (v){
                                       setState((){
                                         calculateImageQuotation();
                                       });
                                     },
                                    ),
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
                                    child: TextField(
                                      controller: subtotal_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
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
                                    child: TextField(
                                      controller: gst_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
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
                                    child: TextField(
                                      controller: total_amount_controller,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                      ),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w600),),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3,),

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
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 350,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              color: Colors.grey.shade300,
                              child: TextField(
                                controller: total_word_controller,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                              ),
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

                      SizedBox(height: 20,),



                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  ///Generate image quotation pdf
  generateImagePdf(String quotation_id,String quotation_title, String buyer_name, String buyer_address, String buyer_contact_details, String quotation_no, String quotation_date, String buyer_gst_no, String seller_contact_details, List<ImageQuotationNotEditableModel> pdf_data_list, String packaging_fee, String subtotal, String gst, String total_amount,) async {
    pw.Document pdf = pw.Document();
    final Logo = await getAssetsImage("assets/logo/logo.png");
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
                pw.Expanded(
                    child: pw.Column(
                        children: [

                          /// 1st container........
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              height: 30,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50)),
                              ),
                              child: pw.Row(
                                  children: [
                                    pw.Text("BUYER'S NAME:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                    pw.SizedBox(height: 3),
                                    pw.Text(buyer_name,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black.shade(400)))
                                  ]
                              )
                          ),
                          pw.SizedBox(height: 2),

                          /// 2ND container........
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              height: 50,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                              ),

                              child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("BUYER'S ADDRESS:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                    pw.SizedBox(height: 3),
                                    pw.Expanded(
                                        child: pw.Text(buyer_address,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black.shade(200)))

                                    )
                                  ]
                              )
                          ),

                          pw.SizedBox(height: 2),

                          /// 3RD container........
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              height: 60,
                              width: double.infinity,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                              ),
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("BUYER'S CONTACT DETAILS:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                    pw.SizedBox(height: 3),
                                    pw.Text(buyer_contact_details,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black.shade(200))),
                                  ]
                              )
                          ),

                        ]
                    )
                ),
                pw.SizedBox(width: 2),


                /// 2nd expanded...........
                pw.Expanded(
                    child: pw.Column(
                        children: [
                          /// 1st container...........
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              height: 30,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                              ),
                              child: pw.Row(
                                  children: [
                                    pw.Text("QUOTATION NO:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                    pw.SizedBox(height: 3),
                                    pw.Text(quotation_no,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black.shade(400)))
                                  ]
                              )
                          ),

                          pw.SizedBox(height: 2),

                          /// 2ND container........
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
                                          pw.Text("QUOTATION DATE:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                          pw.SizedBox(height: 3),
                                          pw.Text(quotation_date,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black.shade(400)))
                                        ]
                                    ),
                                    pw.SizedBox(height: 3),
                                    pw.Row(
                                        children: [
                                          pw.Text("BUYER'S GST NO:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                          pw.SizedBox(height: 3),
                                          pw.Text(buyer_gst_no,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black.shade(200)))
                                        ]
                                    ),
                                  ]
                              )
                          ),

                          pw.SizedBox(height: 2),

                          /// 3RD container........
                          pw.Container(
                              padding: pw.EdgeInsets.all(8),
                              height: 60,
                              width: double.infinity,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black.shade(50), width: 0.7),
                              ),
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("SELLER'S CONTACT DETAILS:",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black.shade(200))),
                                    pw.SizedBox(height: 3),
                                    pw.Text(seller_contact_details,style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black.shade(400))),

                                  ]
                              )
                          ),
                        ]
                    )
                ),
              ]
          ),
        )
    );

    pdf_widget.add(
      pw.SizedBox(height: 14),
    );
    pdf_widget.add(
        pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 20),
            child: pw.Table(

                children: [
                  ///Table Header ---------------
                  pw.TableRow(
                      children: [
                        pw.Container(
                            height: 30,width: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7),
                                color: PdfColors.blue100
                            ),
                            child: pw.Center(
                                child: pw.Text('Sl. No.')
                            )
                        ),
                        pw.Container(
                            height: 30,width: 70,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7),
                                color: PdfColors.blue100
                            ),
                            child: pw.Center(
                                child: pw.Text('Product Name')
                            )
                        ),
                        pw.Container(
                            height: 30,width: 80,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7),
                                color: PdfColors.blue100
                            ),
                            child: pw.Center(
                                child: pw.Text('Picture')
                            )
                        ),
                        pw.Container(
                            height: 30,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7),
                                color: PdfColors.blue100
                            ),
                            child: pw.Center(
                                child: pw.Text('Qty')
                            )
                        ),
                        pw.Container(
                            height: 30,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7),
                                color: PdfColors.blue100
                            ),
                            child: pw.Center(
                                child: pw.Text('Rate')
                            )
                        ),
                        pw.Container(
                            height: 30,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7),
                                color: PdfColors.blue100
                            ),
                            child: pw.Center(
                                child: pw.Text('GST')
                            )
                        ),
                        pw.Container(
                            height: 30,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7),
                                color: PdfColors.blue100
                            ),
                            child: pw.Center(
                                child: pw.Text('Amount')
                            )
                        ),
                      ]
                  ),
                  ///Table Rows ---------------
                  ...pdf_data_list.asMap().entries.map((item) => pw.TableRow(
                      children:[
                        pw.Container(
                            height: 65,width: 30,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                            ),
                            child: pw.Center(
                                child: pw.Text((item.key+1).toString()+".")
                            )
                        ),
                        pw.Container(
                            height: 65,width: 70,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                            ),
                            child: pw.Center(
                                child: pw.Text(item.value.productName.toString())
                            )
                        ),
                        pw.Container(
                            height: 65,width: 80,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                            ),
                            child: pw.Center(
                              child: pw.Image(pw.MemoryImage(item.value.ImageData!),width: 80,height: 60,fit: pw.BoxFit.fill),
                            )
                        ),
                        pw.Container(
                            height: 65,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                            ),
                            child: pw.Center(
                                child: pw.Text(item.value.quantity.toString())
                            )
                        ),
                        pw.Container(
                            height: 65,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                            ),
                            child: pw.Center(
                                child: pw.Text(item.value.rate.toString())
                            )
                        ),
                        pw.Container(
                            height: 65,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                            ),
                            child: pw.Center(
                                child: pw.Text(item.value.gst.toString()+"\n"+item.value.gst_percentage.toString())
                            )
                        ),
                        pw.Container(
                            height: 65,width: 50,
                            decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.blue, width: 0.7)
                            ),
                            child: pw.Center(
                                child: pw.Text(item.value.amount.toString())
                            )
                        ),
                      ])).toList(),
                ]
            )
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
                          padding: pw.EdgeInsets.all(5),
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
                                        pw.Text("Packaging & Forwarding ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.start,
                                      children: [
                                        pw.Text(": $packaging_fee",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      ),
                      pw.Container(
                          padding: pw.EdgeInsets.all(5),
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
                          padding: pw.EdgeInsets.all(5),
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
                          padding: pw.EdgeInsets.all(5),
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

    pdf_widget.add(

        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("GST NO. 500",style: pw.TextStyle(fontSize: 11,fontWeight: pw.FontWeight.bold,color: PdfColors.black))

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
                pw.Image(pw.MemoryImage(Logo),width: 100,height: 60,fit: pw.BoxFit.fill),
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

    pdf.addPage(
      pw.MultiPage(
          header: (context)=> pw.Column(
              children: [
                pw.SizedBox(height: 8),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(pw.MemoryImage(Logo),width: 80,height: 80),
                      pw.SizedBox(width: 15,),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Transmission Surgicals :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 15,color: PdfColors.blue),),
                            pw.Text("333 J.C Bose Road Pallyshree Sodepore,Kolkata-700110",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.red),),
                            pw.Text("Phone: +91 8521036687 / 7412586630 / 9852147896",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.red),),
                            pw.Text("Email: surgicalstrans@gmail.com",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 11,color: PdfColors.red),),
                          ]
                      )
                    ]

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

    setState(() {
      isGenerating=false;
      showGeneratedPdf=true;
    });

  }


  /// Api general quotation
  createGeneralQuotation(String quotation_title,String buyer_details, String buyer_gst, String date, String delivery_fee, String subtotal, String gst, String total_amount, List<GeneralQuotationNotEditableModel> quotation_item_list, String terms) async {
    setState(() {
      isGenerating=true;
    });
    String item_list=jsonEncode(quotation_item_list);
    var url = Uri.parse(create_general_quotation);
    Map<String, String> body = {"quotation_title":quotation_title,"buyer_details": buyer_details, "buyer_gst":buyer_gst, "date":date, "quotations_details":item_list, "delivery_fee":delivery_fee, "subtotal":subtotal, "gst":gst, "total_amount":total_amount, "terms":terms};
    Response response = await post(url, body: body);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      if (jsonData['status'] == "success") {
        selectedQuotationNo = jsonData['quotation_no'];
        setState(() {
          placeHolder=notEditableGeneralQuotation(quotation_title, buyer_details, selectedQuotationNo, DateFormat('dd/MM/yyyy').format(DateTime.now()), buyer_gst, quotation_item_list, delivery_fee, subtotal, gst, total_amount, terms);
        });
        generateGeneralPdf(quotation_title, buyer_details, selectedQuotationNo, DateFormat('dd/MM/yyyy').format(DateTime.now()), buyer_gst, quotation_item_list, delivery_fee, subtotal, gst, total_amount, terms);
      } else {
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Some error has occurred"),
        ).show(context);

      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }
  }

  updateGeneralQuotation(String quotation_id,String quotation_title,String buyer_details, String buyer_address, String buyer_contact_details, String buyer_gst, String date, String seller_contact_details, String delivery_fee, String subtotal, String gst, String total_amount, List<GeneralQuotationNotEditableModel> quotation_item_list, String terms) async {
    setState(() {
      isGenerating=true;
    });
    String item_list=jsonEncode(quotation_item_list);
    var url = Uri.parse(update_general_quotation);
    Map<String, String> body = {"id":quotation_id,"quotation_title":quotation_title,"buyer_details": buyer_details, "buyer_gst":buyer_gst, "date":date, "quotations_details":item_list, "delivery_fee":delivery_fee, "subtotal":subtotal, "gst":gst, "total_amount":total_amount, "terms":terms};
    Response response = await post(url, body: body);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      if (jsonData['status'] == "success") {
        setState(() {
          placeHolder=notEditableGeneralQuotation(quotation_title, buyer_details, selectedQuotationNo, date, buyer_gst, quotation_item_list, delivery_fee, subtotal, gst, total_amount, terms);
        });
        generateGeneralPdf(quotation_title, buyer_details, selectedQuotationNo, date, buyer_gst, quotation_item_list, delivery_fee, subtotal, gst, total_amount, terms);

      } else {
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Some error has occurred"),
        ).show(context);

      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }
  }


  Future<Uint8List> getAssetsImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }



  fetch_image_list(String keyword, StateSetter setState) async {
    setState(() {
      imageLoading=true;
    });
    product_image.clear();
    var url = Uri.parse(search_product_image);
    Map<String, String> body = {
      "product_name":keyword,
    };
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      print(myData);
      var jsonData=jsonDecode(myData);
      jsonData['product_list'].forEach((jsonResponse) {
        ProductDetails obj = new ProductDetails.fromJson(jsonResponse);
        setState(() {
          product_image.add(obj);
        });
      });

    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred!"),
      ).show(context);
    }
    setState(() {
      imageLoading=false;
    });

  }



  /// api - create general quotation
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
      selectedQuotationDeliveryFee = jsonData['delivery_fee'].toString();
      selectedQuotationSubtotal = jsonData['subtotal'].toString();
      selectedQuotationGst = jsonData['gst'].toString();
      selectedQuotationTotalAmount = jsonData['total_amount'].toString();
      selectedQuotationNo = jsonData['quotation_no'].toString();
      selectedQuotationTitle = jsonData['quotation_title'].toString();
      selectedQuotationTerms = jsonData['terms'].toString();

      List<GeneralQuotationNotEditableModel> general_quotation_items_list=[];

      jsonData['quotations_details'].forEach((jsonResponse) {
        GeneralQuotationNotEditableModel obj = new GeneralQuotationNotEditableModel.fromJson(jsonResponse);
        general_quotation_items_list.add(obj);
      });


      general_quotation_editable_list.clear();
      for(int i=0; i<general_quotation_items_list.length; i++){
        GeneralQuotationEditableModel a =GeneralQuotationEditableModel(product_name: general_quotation_items_list[i].productName.toString(), hsn_no: general_quotation_items_list[i].hsn_code.toString(), quantity: general_quotation_items_list[i].quantity.toString(), rate: general_quotation_items_list[i].rate.toString(), gst: general_quotation_items_list[i].gst.toString(), gst_percentage: general_quotation_items_list[i].gst_percentage.toString(), amount: general_quotation_items_list[i].amount.toString(), product_name_controller: TextEditingController(), hsn_no_controller: TextEditingController(), quantity_controller: TextEditingController(), rate_controller: TextEditingController(), gst_controller: gst_controller, gst_percentage_controller: TextEditingController(), amount_controller: TextEditingController());
        general_quotation_editable_list.add(a);
        general_quotation_editable_list[i].product_name_controller!.text=general_quotation_items_list[i].productName.toString();
        general_quotation_editable_list[i].hsn_no_controller!.text=general_quotation_items_list[i].hsn_code.toString();
        general_quotation_editable_list[i].quantity_controller!.text=general_quotation_items_list[i].quantity.toString();
        general_quotation_editable_list[i].rate_controller!.text=general_quotation_items_list[i].rate.toString();
        general_quotation_editable_list[i].gst_controller!.text=general_quotation_items_list[i].gst.toString();
        general_quotation_editable_list[i].gst_percentage_controller!.text=general_quotation_items_list[i].gst_percentage.toString();
        general_quotation_editable_list[i].amount_controller!.text=general_quotation_items_list[i].amount.toString();
      }

    }


    placeHolder = editableGenerateQuotation();

    setState(() {
      isQuotationLoading = false;
    });
  }



  /// api - create image quotation
  createImageQuotation(String quotation_title,String buyer_details, String buyer_gst, String date, String delivery_fee, String subtotal, String gst, String total_amount, List<ImageQuotationNotEditableModel> quotation_item_list, String terms) async {
    setState(() {
      isGenerating=true;
    });

    String item_list=jsonEncode(quotation_item_list);

    placeHolder=notEditableImageQuotation(quotation_title, buyer_details, selectedQuotationNo, DateFormat('dd/MM/yyyy').format(DateTime.now()), buyer_gst, quotation_item_list, delivery_fee, subtotal, gst, total_amount, terms);
setState(() {

});

    var url = Uri.parse(create_image_quotation+"p");
    Map<String, String> body = {"quotation_title":quotation_title,"buyer_details": buyer_details, "buyer_gst":buyer_gst, "date":date, "quotations_details":item_list, "delivery_fee":delivery_fee, "subtotal":subtotal, "gst":gst, "total_amount":total_amount, "terms":terms};
    Response response = await post(url, body: body);
    if (response.statusCode == 200) {
      String myData = response.body;
      var jsonData = jsonDecode(myData);
      if (jsonData['status'] == "success") {
        selectedQuotationNo = jsonData['quotation_no'].toString();
        selectedQuotationId = jsonData['id'].toString();
        setState(() {
          placeHolder=notEditableImageQuotation(quotation_title, buyer_details, selectedQuotationNo, DateFormat('dd/MM/yyyy').format(DateTime.now()), buyer_gst, quotation_item_list, delivery_fee, subtotal, gst, total_amount, terms);
        });
        //generateImagePdf(selectedQuotationId, quotation_title, buyer_name, buyer_address, buyer_contact_details, selectedQuotationNo, DateFormat('dd/MM/yyyy').format(DateTime.now()), buyer_gst, seller_contact_details, quotation_item_list, packaging_fee, subtotal, gst, total_amount);
      } else {
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Some error has occurred"),
        ).show(context);

      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }
  }



  ///not editable image quotation view
  Widget notEditableImageQuotation(String quotation_title, String buyer_details, String quotation_no, String quotation_date, String buyer_gst_no, List<ImageQuotationNotEditableModel> quotation_item_list, String packaging_fee, String subtotal, String gst, String total_amount, String terms){
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
                                            Text("QUOTATION NO : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500),),
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

                                    /// Cell - HSN code -----------------
                                    TableCell(
                                      verticalAlignment: TableCellVerticalAlignment.middle,
                                      child: SizedBox(
                                        height: 150,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Image.memory(quotation_item_list[index].ImageData!, fit: BoxFit.fill,)
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
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            color: Colors.grey.shade300,
                            child: Text("Total: "+amountToWords(int.parse(double.parse(total_amount).round().toString())), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),)
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
                            Image.asset("assets/image/sig1.jpg",height: 20,width: 100,fit: BoxFit.fill,),
                            Image.asset("assets/image/sig2.jpg",height: 20,width: 100,fit: BoxFit.fill,),
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



  calculateGeneralQuotation(){
    total_amount=0; total_gst=0;
    for(int i=0; i<general_quotation_editable_list.length; i++){
      if(general_quotation_editable_list[i].rate!.isNotEmpty && general_quotation_editable_list[i].quantity!.isNotEmpty && general_quotation_editable_list[i].gst_percentage!.isNotEmpty){
        int qty = int.parse(general_quotation_editable_list[i].quantity!);
        double rate = double.parse(general_quotation_editable_list[i].rate!);
        int gst_per = int.parse(general_quotation_editable_list[i].gst_percentage!.replaceAll("%", ""));
        double amt = qty * rate;
        double gst = (amt * gst_per)/100;
        general_quotation_editable_list[i].amount=amt.toStringAsFixed(2);
        general_quotation_editable_list[i].amount_controller!.text=amt.toStringAsFixed(2);
        general_quotation_editable_list[i].gst=gst.toStringAsFixed(2);
        general_quotation_editable_list[i].gst_controller!.text=gst.toStringAsFixed(2);

        total_amount = total_amount + amt + double.parse(packaging_controller.text);
        total_gst = total_gst + gst;
      }
    }
    setState(() {
      subtotal_controller.text=total_amount.toStringAsFixed(2);
      gst_controller.text = total_gst.toStringAsFixed(2);
      total_amount_controller.text = (total_amount + total_gst).toStringAsFixed(0)+".00";
      total_word_controller.text = "Total : "+amountToWords(int.parse(double.parse(total_amount.toString()).round().toString()));
    });

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


  calculateImageQuotation(){
    total_amount=0; total_gst=0;
    for(int i=0; i<image_quotation_editable_list.length; i++){
      if(image_quotation_editable_list[i].rate!.isNotEmpty && image_quotation_editable_list[i].quantity!.isNotEmpty && image_quotation_editable_list[i].gst_percentage!.isNotEmpty){
        int qty = int.parse(image_quotation_editable_list[i].quantity!);
        double rate = double.parse(image_quotation_editable_list[i].rate!);
        int gst_per = int.parse(image_quotation_editable_list[i].gst_percentage!.replaceAll("%", ""));
        double amt = qty * rate;
        double gst = (amt * gst_per)/100;
        image_quotation_editable_list[i].amount=amt.toStringAsFixed(2);
        image_quotation_editable_list[i].amount_controller!.text=amt.toStringAsFixed(2);
        image_quotation_editable_list[i].gst=gst.toStringAsFixed(2);
        image_quotation_editable_list[i].gst_controller!.text=gst.toStringAsFixed(2);

        total_amount = total_amount + amt + double.parse(packaging_controller.text);
        total_gst = total_gst + gst;
      }
    }
    setState(() {
      subtotal_controller.text=total_amount.toStringAsFixed(2);
      gst_controller.text = total_gst.toStringAsFixed(2);
      total_amount_controller.text = (total_amount + total_gst).toStringAsFixed(0)+".00";
      total_word_controller.text = "Total : "+amountToWords(int.parse(double.parse(total_amount.toString()).round().toString()));
    });

  }

}
