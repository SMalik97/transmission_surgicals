import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart' as getX;
import '../../../Utils/global_variable.dart';
import '../../../Utils/urls.dart';
import '../Model/editable_invoice_item.dart';
import '../Model/noteditable_invoice_item.dart';
import 'dart:html' as html;



class InvoiceCreate extends StatefulWidget {
  InvoiceCreate({Key? key}) : super(key: key);

  @override
  State<InvoiceCreate> createState() => _InvoiceCreateState();
}

class _InvoiceCreateState extends State<InvoiceCreate> {

  late pw.Document pdf;
  late Uint8List pdf_bytes;
  List<editableInvoiceItem> invoice_data=[];
  final billing_address_controller=TextEditingController();
  final shipping_address_controller=TextEditingController();
  final other_charges_controller=TextEditingController();
  final paid_amount_controller=TextEditingController();
  final comment_controller=TextEditingController();
  final date_controller=TextEditingController();
  final place_controller=TextEditingController();
  Widget placeHolder=Container();

  bool isGenerateViewShowing=true;
  bool isDownloadViewShowing=false;
  bool isGenerating=false;

  double subtotal=0.00, gst=0.00, due_amount=0.00;
  int  grand_total=0;

  String invoice_no="",invoice_id="",invoice_date="", purpose="", invoice_place="";


  List<noteditableInvoiceItem> invoice_details_list=[];

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
                Text("Generate Invoice", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 18),),
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(isGenerateViewShowing==true)
                          (getX.Get.parameters['id'] !=null && purpose=="edit") ?
                          InkWell(
                            onTap: (){
                              if(billing_address_controller.text.isEmpty){
                                MotionToast.error(
                                  title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                  description:  Text("Please enter billing address"),
                                ).show(context);

                              }if(shipping_address_controller.text.isEmpty){
                                MotionToast.error(
                                  title:  Text("Message"),
                                  description:  Text("Please enter shipping address"),
                                ).show(context);
                              }else{
                                bool isError=false;
                                for(int i = 0 ; i<invoice_data.length; i++){
                                  if(invoice_data[i].des_controller!.text.isEmpty || invoice_data[i].price_controller!.text.isEmpty || invoice_data[i].quantity_controller!.text.isEmpty || invoice_data[i].hsn_controller!.text.isEmpty){
                                    isError =true;
                                  }
                                }
                                if(isError==true){
                                  MotionToast.error(
                                    title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                    description:  Text("Please enter all field correctly"),
                                  ).show(context);

                                }else{
                                  ///call api
                                  updateInvoice();
                                }
                              }
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
                                child: Center(child: Text(isGenerating==true ? "Saving..." :"Save Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                              ),
                            ),
                          ):
                          InkWell(
                          onTap: isGenerating==true? null : (){
                            if(billing_address_controller.text.isEmpty){
                              MotionToast.error(
                                title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                description:  Text("Please enter billing address"),
                              ).show(context);

                            }if(shipping_address_controller.text.isEmpty){
                              MotionToast.error(
                                title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                description:  Text("Please enter shipping address"),
                              ).show(context);
                            }else{
                              bool isError=false;
                              for(int i = 0 ; i<invoice_data.length; i++){
                                if(invoice_data[i].des_controller!.text.isEmpty || invoice_data[i].price_controller!.text.isEmpty || invoice_data[i].quantity_controller!.text.isEmpty || invoice_data[i].quantity_controller!.text.isEmpty){
                                  isError =true;
                                }
                              }
                              if(isError==true){
                                MotionToast.error(
                                  title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                  description:  Text("Please enter all field correctly"),
                                ).show(context);

                              }else{
                                ///call api
                                createNewInvoice();
                              }
                            }
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
                              child: Center(child: Text(isGenerating==true ? "Generating..." :"Generate Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                            ),
                          ),
                        ),

                        SizedBox(width: 15,),
                        if(isDownloadViewShowing==true)
                        Row(
                          children: [
                            InkWell(
                              onTap: (){
                                final blob = html.Blob([pdf_bytes], 'application/pdf');
                                final url = html.Url.createObjectUrlFromBlob(blob);
                                final anchor = html.document.createElement('a') as html.AnchorElement
                                  ..href = url
                                  ..download = "Invoice$invoice_no.pdf";
                                html.document.body?.children.add(anchor);
                                anchor.click();
                                html.document.body?.children.remove(anchor);
                                html.Url.revokeObjectUrl(url);

                                MotionToast.success(
                                  title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                  description:  Text("Downloading..."),
                                ).show(context);
                              },
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.green,
                                ),
                                child: Center(child: Text("Download Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                              ),
                            ),
                            SizedBox(width: 15,),
                            InkWell(
                              onTap: (){
                                final blob = html.Blob([pdf_bytes], 'application/pdf');
                                final url = html.Url.createObjectUrlFromBlob(blob);
                                final windowFeatures = 'resizable,scrollbars,status,titlebar';
                                html.window.open(url, "Print Invoice", windowFeatures);
                                html.Url.revokeObjectUrl(url);
                              },
                              child: Container(
                                height: 30,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.blue
                                ),
                                child: Center(child: Text("Print Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 25,),
                        InkWell(
                          onTap: (){
                            if(getX.Get.parameters['id'] == null){
                              getX.Get.offAndToNamed("/create-invoice");
                            }else{
                              getX.Get.offAndToNamed("/create-invoice?purpose=$purpose&id=$invoice_id",);
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
                SizedBox(width: 15,)
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
    if(getX.Get.parameters['id']==null){
      editableInvoiceItem eii=editableInvoiceItem(description: "", quantity: 0, price: 0.00, totalAmount: 0.00, gst: 0.00,gst_percentage: 12, sgst: 0.00, cgst: 0.00, cgst_percentage: 6, sgst_percentage: 6, hsn: "", des_controller: TextEditingController(), price_controller: TextEditingController(), quantity_controller: TextEditingController(),hsn_controller: TextEditingController(),gst_controller: TextEditingController(),gst_percentage_controller: TextEditingController());
      invoice_data.add(eii);
      invoice_data[0].gst_controller!.text="0.00";
      invoice_data[0].gst_percentage_controller!.text="12";

      other_charges_controller.text="0.00";
      paid_amount_controller.text="0.00";
      comment_controller.text="If you have any questions concerning this invoice, contact name, phone or amount please contact us at $email_id";



      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          placeHolder=createInvoiceView();
        });
      });
    }else{
      purpose=getX.Get.parameters['purpose']!;
      invoice_id=getX.Get.parameters['id']!;
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


      fetchInvoiceDetails(invoice_id);


    }


    super.initState();
  }

  fetchInvoiceDetails(String invoice_id) async {
    var url = Uri.parse(fetch_invoice_details);
    Map<String, String> body = {"invoice_id": invoice_id};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="Success"){
        invoice_no=jsonData['invoice_no'];
        invoice_date=jsonData['date'];
        billing_address_controller.text=jsonData['billing_address'];
        shipping_address_controller.text=jsonData['shipping_address'];
        subtotal=double.parse(jsonData['subtotal']);
        gst=double.parse(jsonData['gst']);
        other_charges_controller.text=jsonData['other_charges'];
        grand_total=double.parse(jsonData['grand_total']).round();
        paid_amount_controller.text=jsonData['paid'];
        due_amount=double.parse(jsonData['due']);
        comment_controller.text=jsonData['custom_note'];

        date_controller.text=formattedDate(invoice_date);

        invoice_details_list.clear();
        jsonData['details'].forEach((jsonResponse) {
          noteditableInvoiceItem obj = new noteditableInvoiceItem.fromJson(jsonResponse);
          invoice_details_list.add(obj);
        });



        for(int i =0; i<invoice_details_list.length; i++){
          editableInvoiceItem eii=editableInvoiceItem(description: invoice_details_list[i].description.toString(), quantity: int.parse(invoice_details_list[i].quantity.toString()), price: double.parse(invoice_details_list[i].price.toString()), gst: 0.0, gst_percentage: 0, sgst_percentage: 0.00, cgst_percentage: 0.00, totalAmount: double.parse(invoice_details_list[i].totalAmount.toString()),hsn:invoice_details_list[i].hsn.toString(), sgst: double.parse(invoice_details_list[i].sgst.toString()), cgst: double.parse(invoice_details_list[i].cgst.toString()), hsn_controller: TextEditingController() , des_controller: TextEditingController(), price_controller: TextEditingController(), quantity_controller: TextEditingController(), gst_controller: TextEditingController(), gst_percentage_controller: TextEditingController());
          invoice_data.add(eii);
          invoice_data[i].des_controller!.text=invoice_details_list[i].description.toString();
          invoice_data[i].price_controller!.text=invoice_details_list[i].price.toString();
          invoice_data[i].quantity_controller!.text=invoice_details_list[i].quantity.toString();
          invoice_data[i].hsn_controller!.text=invoice_details_list[i].hsn.toString();
        }

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
    setState(() {
      placeHolder=createInvoiceView();
    });

  }

  Widget createInvoiceView(){
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

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 140,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: 0.5)
                              ),
                              child: Text("$address \nOffice : $office_phone\nMobile : $phone_number\nEmail : $email_id\nPAN Number : $pan_no\nGST : $gst_no\nWebsite : $website",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),)
                          ),
                          ),
                          SizedBox(width: 15,),
                          Expanded(child: Container(
                            height: 140,
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: 0.5)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("TAX INVOICE",style: GoogleFonts.alata(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                                SizedBox(height: 5,),

                                purpose=="edit"?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("Invoice Number",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                        width: 130,
                                        child: Text("KOL/TS${DateFormat('yyyy').format(DateTime.now())}-$invoice_no",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                  ],
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("Invoice Number",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                        width: 130,
                                        child: Text("##########",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                  ],
                                ),
                                purpose=="edit"?
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("Invoice Date",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black))),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                      width: 130,
                                      child: TextField(
                                        controller: date_controller,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: "DD/MM/YYYY",
                                            hintStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.grey)
                                        ),
                                        style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),

                                      ),
                                    )
                                  ],
                                ): Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("Invoice Date",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                      width: 130,
                                        child: Text(DateFormat('dd/MM/yyyy').format(DateTime.now()),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("GST",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                        width: 130,
                                        child: Text(gst_no,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 100,
                                        child: Text("Place",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black))
                                    ),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                      width: 130,
                                      child: TextField(
                                        controller: place_controller,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            hintText: "Type Place Name",
                                            hintStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.grey)
                                        ),
                                        style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),

                                      ),
                                    )
                                  ],
                                )



                              ],
                            ),
                          ),)
                        ],
                      ),

                      SizedBox(height: 15,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black,width: 0.5)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Billing Address :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Container(
                                        width:300,
                                        constraints: BoxConstraints(
                                          minHeight: 100,
                                        ),
                                        child: TextField(
                                          controller: billing_address_controller,
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
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 15,),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black,width: 0.5)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Shipping Address :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Container(
                                        width:300,
                                        constraints: BoxConstraints(
                                          minHeight: 100,
                                        ),

                                        child: TextField(
                                          controller: shipping_address_controller,
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
                                ],
                              ),
                            ),
                          ),
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
                                color: Colors.blue.withOpacity(0.3)
                            ),
                            child: Center(
                                child: Text("Sl. No.", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
                            ),
                          ),
                          Expanded(
                              flex: 6,
                              child: Container(
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
                                    child: Text("Product Name", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
                                ),
                              )),

                          Expanded(
                              flex: 3,
                              child: Container(
                                width: 70,
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
                                    child: Text("HSN/SAC", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
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
                                    child: Text("Price", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
                                ),
                              )),

                          Expanded(
                              flex: 3,
                              child: Container(
                                width: 70,
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
                                    child: Text("Quantity", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
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
                                    child: Text("GST", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
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
                                    child: Text("CGST", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
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
                                    child: Text("SGST", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
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
                                    child: Text("Total", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w600),)
                                ),
                              )),
                        ],
                      ),
                      ListView.builder(
                          itemCount: invoice_data.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index){
                            return Row(
                              children: [
                                Container(
                                  width: 60,
                                  constraints: BoxConstraints(
                                      minHeight: 50
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.blue, width: 1),
                                      bottom: BorderSide(color: Colors.blue, width: 1),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text((index+1).toString()+".", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),),
                                        InkWell(
                                            onTap: (){
                                              setState((){
                                                invoice_data.removeAt(index);
                                              });
                                              calculateInvoice();
                                            },
                                            child: Icon(Icons.close, size: 15, color: Colors.red,)
                                        )
                                      ]
                                  ),
                                ),

                                /// Description ..........................
                                Expanded(
                                    flex: 6,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: invoice_data[index].des_controller,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.end,
                                        onChanged: (v){
                                          invoice_data[index].description = invoice_data[index].des_controller!.text;
                                        },
                                      ),
                                    )),

                                /// HSN / SAC ..................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: invoice_data[index].hsn_controller,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.end,
                                        onChanged: (v){
                                          invoice_data[index].hsn=v;
                                        },
                                      ),
                                    )),

                                /// Price ................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: invoice_data[index].price_controller,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.end,
                                        onChanged: (v){
                                          if(invoice_data[index].price_controller!.text.isNotEmpty){
                                            invoice_data[index].price = double.parse(invoice_data[index].price_controller!.text);
                                          }
                                          if(invoice_data[index].price_controller!.text.isEmpty || invoice_data[index].quantity_controller!.text.isEmpty){
                                            setState(() {
                                              invoice_data[index].totalAmount = 0.00;
                                            });
                                          }else{
                                            double r = double.parse(invoice_data[index].price_controller!.text) * double.parse(invoice_data[index].quantity_controller!.text);
                                            setState(() {
                                              invoice_data[index].totalAmount =r;
                                            });
                                          }
                                          calculateInvoice();
                                        },
                                      ),
                                    )),

                                ///Quantity ....................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: TextField(
                                        controller: invoice_data[index].quantity_controller,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.end,
                                        onChanged: (v){
                                          if(invoice_data[index].quantity_controller!.text.isNotEmpty){
                                            invoice_data[index].quantity = int.parse(invoice_data[index].quantity_controller!.text);
                                          }
                                          if(invoice_data[index].price_controller!.text.isEmpty || invoice_data[index].quantity_controller!.text.isEmpty){
                                            setState(() {
                                              invoice_data[index].totalAmount = 0.00;
                                            });
                                          }else{
                                            double r = double.parse(invoice_data[index].price_controller!.text) * double.parse(invoice_data[index].quantity_controller!.text);
                                            setState(() {
                                              invoice_data[index].totalAmount =r;
                                            });
                                          }
                                          calculateInvoice();
                                        },
                                      ),
                                    )),


                                /// Gst .................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 3),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none
                                                  ),
                                                  controller: invoice_data[index].gst_controller
                                                 , style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),textAlign: TextAlign.end),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2,),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  decoration: InputDecoration(
                                                      isDense: true,
                                                      border: InputBorder.none
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  controller: invoice_data[index].gst_percentage_controller,
                                                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                                                onChanged: (v){
                                                    setState((){
                                                      calculateInvoice();
                                                    });
                                                },
                                                ),
                                              ),
                                              Text("%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),)
                                            ],
                                          )
                                        ],
                                      ),
                                    )),

                                /// CGst .................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 3),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 40,
                                            child:Text(invoice_data[index].cgst!.toStringAsFixed(2), style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),textAlign: TextAlign.end),
                                          ),
                                          SizedBox(height: 2,),
                                          Text("${invoice_data[index].sgst_percentage!.toStringAsFixed(2)}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),)
                                        ],
                                      ),
                                    )),

                                /// SGst .................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 3),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child:Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 40,
                                            child:Text(invoice_data[index].sgst!.toStringAsFixed(2), style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),textAlign: TextAlign.end),
                                          ),
                                          SizedBox(height: 2,),
                                          Text("${invoice_data[index].sgst_percentage!.toStringAsFixed(2)}%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),)
                                        ],
                                      )
                                    )),

                                /// Total Price ...........................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 7),
                                      width: 80,
                                      constraints: BoxConstraints(
                                          minHeight: 50
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          right: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(invoice_data[index].totalAmount!.toStringAsFixed(2), style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),textAlign: TextAlign.right,),
                                        ],
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
                                editableInvoiceItem eii=editableInvoiceItem(description: "", quantity: 0, price: 0.00, totalAmount: 0.00,hsn: "",gst: 0.00, gst_percentage: 0, sgst: 0.00, cgst: 0.00, sgst_percentage: 6,cgst_percentage: 6, des_controller: TextEditingController(), price_controller: TextEditingController(), quantity_controller: TextEditingController(), hsn_controller: TextEditingController(), gst_controller: TextEditingController(), gst_percentage_controller: TextEditingController());
                                setState((){
                                  invoice_data.add(eii);
                                  invoice_data[invoice_data.length-1].gst_controller!.text="0.00";
                                  invoice_data[invoice_data.length-1].gst_percentage_controller!.text="12";
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

                          Column(
                            children: [
                              /// Subtotal
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black,width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("Subtotal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(subtotal.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                          ],
                                        )),

                                      ],
                                    ),
                                  ),
                                ],
                              ),


                              /// gst
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black.withOpacity(0.7),width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("GST", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(gst.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                          ],
                                        )),

                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              /// Other charges
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black.withOpacity(0.7),width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("Other Charges", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: TextField(
                                          controller: other_charges_controller,
                                          decoration: InputDecoration(
                                              isDense: true,border: InputBorder.none
                                          ),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),
                                          onChanged: (v){
                                            setState((){
                                              calculateInvoice();
                                            });
                                          },
                                        ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              /// Total
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black.withOpacity(0.7),width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(grand_total.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                          ],
                                        ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )

                        ],
                      ),





                      SizedBox(height: 30,),
                      if(amountToWords(due_amount.round()).isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              color: Colors.grey.shade300,
                              child: Text("Total : "+amountToWords(due_amount.round()), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),)
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      ///Bank details & Authorized Signatory ......................
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bank Details : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                              Text("A/C Holder Name : $bank_ac_holder_name",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                              Text("Bank Name : $bank_name",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                              Text("Account Number : $bank_ac_number",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                              Text("IFSC Code : $ifsc_code",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),


                            ],
                          ),
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
                      SizedBox(height: 50,),

                      Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                      SizedBox(height: 3,),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue,width: 1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: TextField(
                            controller: comment_controller,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            maxLines: null,
                          )
                      ),

                      SizedBox(height: 30,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("THANK YOU FOR YOUR BUSINESS!",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),

                        ],
                      ),


                      SizedBox(height: 15,),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Text("This is a computer-generated invoice, no need any seals or stamps. The invoice is considered valid and official without any physical seals or stamps.",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 10,color: Colors.black),)),
                        ],
                      ),

                      SizedBox(height: 80,),
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

  calculateInvoice(){
    subtotal = 0.00;
    gst=0.00;
    for(int i=0; i<invoice_data.length; i++){
      subtotal = subtotal + invoice_data[i].totalAmount!;
      try{
        double g = (invoice_data[i].totalAmount! * double.parse(invoice_data[i].gst_percentage_controller!.text))/100;
        invoice_data[i].gst=g;
        invoice_data[i].gst_controller!.text=g.toStringAsFixed(2);
        invoice_data[i].sgst=double.parse((g/2).toStringAsFixed(2));
        invoice_data[i].sgst_percentage=(double.parse(invoice_data[i].gst_percentage_controller!.text)/2);
        invoice_data[i].cgst=double.parse((g/2).toStringAsFixed(2));
        invoice_data[i].cgst_percentage=(double.parse(invoice_data[i].gst_percentage_controller!.text)/2);
        gst = gst + g;
      }catch(e){
        invoice_data[i].sgst=0.00;
        invoice_data[i].cgst=0.00;
        invoice_data[i].gst=0.00;
      }
    }




    if(other_charges_controller.text.isEmpty){
      grand_total = (subtotal + gst).round();
    }else{
      grand_total = (subtotal + gst + double.parse(other_charges_controller.text)).round();
    }

    if(paid_amount_controller.text.isEmpty){
      due_amount = double.parse(grand_total.toString());
    }else{
      due_amount = grand_total - double.parse(paid_amount_controller.text);
    }

    setState(() {});
  }


  updateInvoice() async {
    setState(() {
      isGenerating = true;
    });
    List<noteditableInvoiceItem> invoice_items=[];
    for(int i =0; i<invoice_data.length; i++){
      noteditableInvoiceItem a = noteditableInvoiceItem(description: invoice_data[i].description.toString(),quantity: invoice_data[i].quantity.toString(),price: invoice_data[i].price!.toStringAsFixed(2),totalAmount: invoice_data[i].totalAmount!.toStringAsFixed(2),gst: invoice_data[i].gst!.toStringAsFixed(2),gst_percentage: invoice_data[i].gst_percentage!.toStringAsFixed(2),cgst: invoice_data[i].cgst!.toStringAsFixed(2),cgst_percentage: invoice_data[i].cgst_percentage!.toStringAsFixed(2), sgst: invoice_data[i].sgst!.toStringAsFixed(2),sgst_percentage: invoice_data[i].sgst_percentage!.toStringAsFixed(2), hsn: invoice_data[i].hsn!);
      invoice_items.add(a);
    }

    String invoice_item_list=jsonEncode(invoice_items);
    var url = Uri.parse(update_invoice);
    Map<String, String> body = {"invoice_id":invoice_id,"date":formattedDate2(date_controller.text),"billing_address": billing_address_controller.text.trim(), "shipping_address":shipping_address_controller.text.trim(),"subtotal":subtotal.toStringAsFixed(2), "gst":gst.toStringAsFixed(2), "grand_total":grand_total.toStringAsFixed(2),"paid":paid_amount_controller.text.toString(),"due":due_amount.toStringAsFixed(2),"custom_note":comment_controller.text.trim(),"other_charges":other_charges_controller.text,"descriptions":invoice_item_list};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;

      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        generatePdf(invoice_no,invoice_date, place_controller.text.trim(), billing_address_controller.text.trim(), shipping_address_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2),comment_controller.text.trim());
        setState(() {
          placeHolder=invoiceView(invoice_no, invoice_date, place_controller.text.toString(), billing_address_controller.text.trim(), shipping_address_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), comment_controller.text.trim());
        });
      }else{
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

  createNewInvoice() async {
    setState(() {
      isGenerating = true;
    });
    List<noteditableInvoiceItem> invoice_items=[];
    for(int i =0; i<invoice_data.length; i++){
      noteditableInvoiceItem a = noteditableInvoiceItem(description: invoice_data[i].description.toString(),quantity: invoice_data[i].quantity.toString(),price: invoice_data[i].price!.toStringAsFixed(2),totalAmount: invoice_data[i].totalAmount!.toStringAsFixed(2), gst:invoice_data[i].gst!.toStringAsFixed(2),gst_percentage:  invoice_data[i].gst_percentage!.round().toString(),cgst: invoice_data[i].cgst!.toStringAsFixed(2),cgst_percentage: invoice_data[i].cgst_percentage!.toStringAsFixed(2), sgst: invoice_data[i].sgst!.toStringAsFixed(2),sgst_percentage: invoice_data[i].sgst_percentage!.toStringAsFixed(2), hsn: invoice_data[i].hsn!);
      invoice_items.add(a);
    }
    // generatePdf("78202", DateFormat('dd/MM/yyyy').format(DateTime.now()), billing_address_controller.text.trim(), shipping_address_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), comment_controller.text.trim());

    String invoice_item_list=jsonEncode(invoice_items);
    var url = Uri.parse(create_invoice);
    Map<String, String> body = {"billing_address": billing_address_controller.text.trim(), "shipping_address":shipping_address_controller.text.trim(),"subtotal":subtotal.toStringAsFixed(2), "gst":gst.toStringAsFixed(2), "grand_total":grand_total.toStringAsFixed(2),"paid":paid_amount_controller.text.toString(),"due":due_amount.toStringAsFixed(2),"custom_note":comment_controller.text.trim(),"other_charges":other_charges_controller.text,"descriptions":invoice_item_list};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        invoice_no=jsonData['invoice_no'];
        generatePdf(invoice_no, DateFormat('dd/MM/yyyy').format(DateTime.now()), place_controller.text.trim(), billing_address_controller.text.trim(), shipping_address_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), comment_controller.text.trim());
        setState(() {
          placeHolder=invoiceView(invoice_no, DateFormat('dd/MM/yyyy').format(DateTime.now()), place_controller.text.toString(), billing_address_controller.text.trim(), shipping_address_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), comment_controller.text.trim());
        });
      }else{
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Some error has occurred"),
        ).show(context);
        setState(() {
          isGenerating = false;
        });
      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);
      setState(() {
        isGenerating = false;
      });

    }



  }


  Widget invoiceView(String invoice_number,String invoice_date, String place_name, String billing_address, String shipping_address, List<noteditableInvoiceItem> invoice_item_details, String subtotal, String gst, String other_charges, String grand_total, String comments){
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width:800,
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

                      SizedBox(height: 15,),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                                height: 130,
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black,width: 0.5)
                                ),
                                child: Text("$address \nOffice : $office_phone\nMobile : $phone_number\nEmail : $email_id\nPAN Number : $pan_no\nGST : $gst_no\nWebsite : $website",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),)
                            ),
                          ),
                          SizedBox(width: 15,),
                          Expanded(child: Container(
                            height: 130,
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black,width: 0.5)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("TAX INVOICE",style: GoogleFonts.alata(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                                SizedBox(height: 5,),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("Invoice Number",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                        width: 130,
                                        child: Text(invoice_number,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("Invoice Date",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                        width: 130,
                                        child: Text(DateFormat('dd/MM/yyyy').format(DateTime.now()),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("GST",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                        width: 130,
                                        child: Text(gst_no,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        child: Text("Place",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black))
                                    ),
                                    Text(" : ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    Container(
                                      width: 130,
                                      child: Text(place_name,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                                    )
                                  ],
                                )



                              ],
                            ),
                          ),)
                        ],
                      ),

                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 130,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                 border: Border.all(color: Colors.black87,width: 0.5)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Billing Address :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                                  SizedBox(height: 5,),
                                  Text(billing_address,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Colors.black),),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 15,),
                          Expanded(
                            child: Container(
                              height: 130,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black87,width: 0.5)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Shipping Address :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                                  SizedBox(height: 5,),
                                  Text(shipping_address,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12,color: Colors.black),),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 30,),

                      Row(
                        children: [
                          ///Sl no................
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
                                child: Text("Sl. No.", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w400),)
                            ),
                          ),

                          ///Description ........................
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
                                    child: Text("Product Name", style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500),)
                                ),
                              )),

                          ///HSN/SAC ........................
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
                                    child: Text("HSN/SAC", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),)
                                ),
                              )),

                          ///Price ...........................
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
                                    child: Text("Price", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),)
                                ),
                              )),

                          ///Quantity ....................
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
                                    child: Text("Quantity", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),)
                                ),
                              )),


                          ///Gst ....................
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
                                    child: Text("GST", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),)
                                ),
                              )),

                          ///CGst ....................
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
                                    child: Text("CGST", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),)
                                ),
                              )),

                          ///SGst ....................
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
                                    child: Text("SGST", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),)
                                ),
                              )),

                          ///Total ..................
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
                                    child: Text("Total", style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),)
                                ),
                              )),
                        ],
                      ),
                      ListView.builder(
                          itemCount: invoice_item_details.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index){
                            return Row(
                              children: [
                                /// Sl. No. .........................
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(color: Colors.blue, width: 1),
                                      bottom: BorderSide(color: Colors.blue, width: 1),
                                    ),
                                  ),
                                  child: Center(
                                      child: Text((index+1).toString()+".", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),)
                                  ),
                                ),

                                /// Description .........................
                                Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(child: Text(invoice_item_details[index].description.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500,),softWrap: true, overflow: TextOverflow.fade,)),
                                        ],
                                      ),
                                    )),

                                /// HSN /SAC ............................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(invoice_item_details[index].hsn.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
                                      ),
                                    )),

                                ///Price ..............................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(invoice_item_details[index].price.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
                                      ),
                                    )),

                                ///Quantity ............................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(invoice_item_details[index].quantity.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
                                      ),
                                    )),


                                ///Gst ............................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(invoice_item_details[index].gst.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                                              SizedBox(height: 2,),
                                              Text(invoice_item_details[index].gst_percentage.toString()+"%",style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.w500),),
                                            ],
                                          )                                        ],
                                      ),
                                    )),

                                ///CGst ............................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(invoice_item_details[index].cgst.toString(),style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.w500),),
                                          SizedBox(height: 3,),
                                          Text("6%",style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
                                      ),
                                    )),

                                ///SGst ............................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(invoice_item_details[index].sgst.toString(),style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.w500),),
                                          SizedBox(height: 3,),
                                          Text("6%",style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
                                      ),
                                    )),

                                ///Total ............................
                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: Colors.blue, width: 1),
                                          right: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(invoice_item_details[index].totalAmount.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
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
                            children: [
                              /// Subtotal
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black,width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("Subtotal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(subtotal, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                          ],
                                        )),

                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              /// gst
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black.withOpacity(0.7),width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("GST", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(gst, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                          ],
                                        )),

                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              /// Other charges
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black.withOpacity(0.7),width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("Other Charges", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(other_charges, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                          ],
                                        )),

                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              /// Total
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250,
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black.withOpacity(0.7),width: 0.5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text("Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),)),
                                        Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black),),
                                        Expanded(child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(grand_total, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                          ],
                                        ),
                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                color: Colors.grey.shade300,
                                child: Text("Total: "+amountToWords(int.parse(due_amount.round().toString())), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),)
                            ),
                          ],
                        ),

                      SizedBox(height: 20,),
                      ///Authorized Signatory ......................
                      ///Bank details & Authorized Signatory ......................
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bank Details : ", style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w600),),
                              Text("A/C Holder Name : $bank_ac_holder_name",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                              Text("Bank Name : $bank_name",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                              Text("Account Number : $bank_ac_number",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),
                              Text("IFSC Code : $ifsc_code",
                                  style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500)
                              ),


                            ],
                          ),
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
                      SizedBox(height: 50,),

                      Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                      SizedBox(height: 3,),
                      Text(comments,style: TextStyle(fontWeight: FontWeight.normal,fontSize: 13,color: Colors.black),),

                      SizedBox(height: 30,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("THANK YOU FOR YOUR BUSINESS!",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),

                        ],
                      ),
                      SizedBox(height: 15,),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Text("This is a computer-generated invoice, no need any seals or stamps. The invoice is considered valid and official without any physical seals or stamps.",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 10,color: Colors.black),)),
                        ],
                      ),

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




  generatePdf(String invoice_no, String invoice_date, String place_name, String billing_details, String shipping_details,  List<noteditableInvoiceItem> invoice_items, String subtotal, String gst, String other_charges, String grand_total, String comments) async {
    pdf = pw.Document();
    final Logo = await getAssetsImage("assets/logo/logo3.png");
    final sig1 = await getAssetsImage("assets/image/sig1.jpg");
    final sig2 = await getAssetsImage("assets/image/sig2.jpg");
    List<pw.Widget> widgets = [];


    widgets.add(pw.SizedBox(height: 20,),);

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
                pw.SizedBox(width: 5,),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Transmission Surgicals", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15, color: PdfColors.teal),),

                    pw.SizedBox(
                        width: 190,
                        child: pw.Divider(height: 5,thickness: 2,color: PdfColors.teal,)
                    ),
                    pw.SizedBox(height: 2,),
                    pw.SizedBox(
                      width: 190,
                      child:
                      pw.Center(child: pw.Text("Sales and Service", style: pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 10, color: PdfColors.teal),)),
                    ),
                    pw.SizedBox(height: 5,),
                  ],
                )
              ],
            ),
            pw.SizedBox(height: 5,),

            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    height: 110,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 0.5,
                        color: PdfColors.black
                      )
                    ),
                    child: pw.Text("$address\nOffice : $office_phone\nMobile : $phone_number\nEmail : $email_id\nPAN Number : $pan_no\nGST : $gst_no\nWebsite : $website",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 10,color: PdfColors.black),),
                  )
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                    child: pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        height: 110,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 0.5,
                                color: PdfColors.black
                            )
                        ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("TAX INVOICE",style: pw.TextStyle(fontSize: 16,fontWeight:pw.FontWeight.bold,color: PdfColors.black),),
                          pw.SizedBox(height: 5,),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Container(
                                  width: 80,
                                  child: pw.Text("Invoice Number",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),)),
                                  pw.Text(" : ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                                pw.Container(
                                  width: 100,
                                  child: pw.Text("KOL/TS${DateFormat('yyyy').format(DateTime.now())}-$invoice_no",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),)),
                            ],
                          ),

                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Container(
                                  width: 80,
                                  child: pw.Text("Invoice Date",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),)),
                              pw.Text(" : ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                              pw.Container(
                                  width: 100,
                                  child: pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()),style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),)
                              ),
                            ],
                          ),

                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Container(
                                  width: 80,
                                  child: pw.Text("GST",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),)),
                              pw.Text(" : ",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                              pw.Container(
                                  width: 100,
                                  child: pw.Text(gst_no,style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),)
                              ),
                            ],
                          ),

                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Container(
                                  width: 80,
                                  child: pw.Text("Place",style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black))
                              ),
                              pw.Text(" : ",style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                              pw.Container(
                                width: 100,
                                child: pw.Text(place_name,style: pw.TextStyle(fontSize: 10,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                )
              ]
            ),
            pw.SizedBox(height: 10,),
            pw.Row(
                children: [
                  pw.Expanded(
                      child: pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        height: 100,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 0.5,
                                color: PdfColors.black
                            )
                        ),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Billing Address :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 11,color: PdfColors.black),),
                              pw.Text(billing_details,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 9,color: PdfColors.black),),
                            ]
                        )
                      )
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                      child: pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        height: 100,
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 0.5,
                                color: PdfColors.black
                            )
                        ),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Shipping Address :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 11,color: PdfColors.black),),
                              pw.Text(shipping_details,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 9,color: PdfColors.black),),
                            ]
                        ),
                      )
                  )
                ]
            ),


          ],
        )
      )
    );


    widgets.add(pw.SizedBox(height: 30,),);




    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child: pw.Table.fromTextArray(
            data: [
              ['Sl. No.','Product Name', 'HSN/SAC', 'Quantity', 'Price', 'GST', 'CGST', 'SGST', 'Total'],
              ...invoice_items.asMap().entries.map((item) => [
                (item.key+1).toString()+".",
                item.value.description.toString(),
                item.value.hsn.toString(),
                item.value.quantity.toString(),
                item.value.price.toString(),
                item.value.gst.toString()+"\n"+item.value.gst_percentage.toString()+"%",
                item.value.cgst.toString()+"\n"+item.value.cgst_percentage.toString()+"%",
                item.value.sgst.toString()+"\n"+item.value.sgst_percentage.toString()+"%",
                item.value.totalAmount.toString(),
              ]).toList(),
            ],
            cellAlignment: pw.Alignment.centerRight,
            cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 8),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
            border: pw.TableBorder.all(width: 1, color: PdfColors.blue),
            headerDecoration: pw.BoxDecoration(
              color: PdfColors.blue100,
            ),
            columnWidths: {
              0:pw.FlexColumnWidth(1),
              1:pw.FlexColumnWidth(4),
              2:pw.FlexColumnWidth(2),
              3:pw.FlexColumnWidth(2),
              4:pw.FlexColumnWidth(2),
              5:pw.FlexColumnWidth(2),
              6:pw.FlexColumnWidth(2),
              7:pw.FlexColumnWidth(2),
              8:pw.FlexColumnWidth(2),
            }
        ),
      )
    );


    widgets.add(pw.SizedBox(height: 5,),);


    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  height: 60,
                  padding: pw.EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.5)
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Bank Details : ", style: pw.TextStyle(color: PdfColors.black,fontSize: 9, fontWeight: pw.FontWeight.bold),),
                      pw.SizedBox(height: 3),
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text("Account Number : $bank_ac_number",
                                style: pw.TextStyle(color: PdfColors.black,fontSize: 8, fontWeight: pw.FontWeight.normal)
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text("IFSC Code : $ifsc_code",
                                style: pw.TextStyle(color: PdfColors.black,fontSize: 8, fontWeight: pw.FontWeight.normal)
                            ),

                          ]
                      ),
                      pw.SizedBox(height: 3),
                      pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [

                            pw.Text("Bank Name : $bank_name",
                                style: pw.TextStyle(color: PdfColors.black,fontSize: 8, fontWeight: pw.FontWeight.normal)
                            ),
                            pw.SizedBox(width: 20),
                            pw.Text("Branch Name : $bank_branch",
                                style: pw.TextStyle(color: PdfColors.black,fontSize: 8, fontWeight: pw.FontWeight.normal)
                            ),

                          ]
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text("A/C Holder Name : $bank_ac_holder_name",
                          style: pw.TextStyle(color: PdfColors.black,fontSize: 8, fontWeight: pw.FontWeight.normal)
                      ),






                    ],
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Column(
                    children: [
                      ///Subtotal ...........
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 200,
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
                                        pw.Text("Subtotal",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),
                                pw.Text(":",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black)),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("$subtotal",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      ),

                      ///GST ...........
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 200,
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
                                        pw.Text("GST",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),
                                pw.Text(":",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black)),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("$gst",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      ),
                      ///Other charges ...........
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 200,
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
                                        pw.Text("Other charges",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),
                                pw.Text(":",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black)),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("$other_charges",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                )

                              ]
                          )
                      ),

                      /// Total
                      pw.Container(
                          padding: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          width: 200,
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
                                        pw.Text("Total Amount",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                                      ]
                                  ),
                                ),

                                pw.Text(":",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black)),

                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Text("$grand_total",style: pw.TextStyle(fontSize: 9,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
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


    widgets.add(pw.SizedBox(height: 30,),);
    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                color: PdfColors.grey200,
                child: pw.Text("Total : "+amountToWords(int.parse(due_amount.round().toString())), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),)
            ),
          ],
        ),
      )
    );

    widgets.add(
      pw.SizedBox(height: 15),
    );


    widgets.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [


          pw.Column(
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text("Authorized Signatory",style: pw.TextStyle(fontSize: 11,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                      ]
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 20),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Column(
                            children: [
                              pw.Image(pw.MemoryImage(sig1),width: 100,height: 20,fit: pw.BoxFit.fill),
                              pw.Image(pw.MemoryImage(sig2),width: 100,height: 20,fit: pw.BoxFit.fill),
                            ]
                        )
                      ]
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 20),
                  child:  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text("Transmission Surgicals",style: pw.TextStyle(fontSize: 11,fontWeight: pw.FontWeight.bold,color: PdfColors.black))
                      ]
                  ),
                )
              ]
          )
        ]
      )
    );




    widgets.add(pw.SizedBox(height: 50,),);

    widgets.add(pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 15),
      child: pw.Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 10,color: PdfColors.black),),
    ));
    widgets.add(pw.SizedBox(height: 3,),);
    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child: pw.Text(comments,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 11,color: PdfColors.black),),
      )
    );
    widgets.add(pw.SizedBox(height: 30,),);
    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("THANK YOU FOR YOUR BUSINESS!",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 14,color:PdfColors.black),),
          ],
        ),
      )
    );

    widgets.add(pw.SizedBox(height: 15,),);

    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child : pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Expanded(child: pw.Text("This is a computer-generated invoice, no need any seals or stamps. The invoice is considered valid and official without any physical seals or stamps.",style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 8,color: PdfColors.black),)),
          ],
        ),
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


    setState(() {
      isGenerating = false;
      isGenerateViewShowing=false;
      isDownloadViewShowing=true;
    });

    MotionToast.success(
      title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
      description:  Text("Invoice Generated!"),
    ).show(context);

  }



  Future<Uint8List> getAssetsImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }


  String formattedDate(String inputDate){
    try{
      DateFormat format = DateFormat("yyyy-MM-dd");
      var inDate = format.parse(inputDate);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      final String formatted = formatter.format(inDate);
      return formatted;
    }catch(e){
      return inputDate;
    }

  }

  String formattedDate2(String inputDate){
    try{
      DateFormat format = DateFormat("dd/MM/yyyy");
      var inDate = format.parse(inputDate);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(inDate);
      return formatted;
    }catch(e){
      return inputDate;
    }

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
