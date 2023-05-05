import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart' as getX;
import '../../../Utils/urls.dart';
import '../Model/editable_invoice_item.dart';
import '../Model/noteditable_invoice_item.dart';
import 'dart:html' as html;
import 'package:get/get.dart' as getX;


class InvoiceCreate extends StatefulWidget {
  InvoiceCreate({Key? key}) : super(key: key);

  @override
  State<InvoiceCreate> createState() => _InvoiceCreateState();
}

class _InvoiceCreateState extends State<InvoiceCreate> {

  final pdf = pw.Document();
  late Uint8List pdf_bytes;
  List<editableInvoiceItem> invoice_data=[];
  final recipient_controller=TextEditingController();
  final gst_controller=TextEditingController();
  final other_charges_controller=TextEditingController();
  final paid_amount_controller=TextEditingController();
  final comment_controller=TextEditingController();
  final date_controller=TextEditingController();
  Widget placeHolder=Container();

  bool isGenerateViewShowing=true;
  bool isDownloadViewShowing=false;
  bool isGenerating=false;

  double subtotal=0.00, gst=0.00, grand_total=0.00, due_amount=0.00;

  String invoice_no="",invoice_id="",invoice_date="", purpose="";


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
                              if(recipient_controller.text.isEmpty){
                                Fluttertoast.showToast(
                                    msg: "Please enter recipient address",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM_RIGHT,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                    fontSize: 16.0
                                );
                              }else{
                                bool isError=false;
                                for(int i = 0 ; i<invoice_data.length; i++){
                                  if(invoice_data[i].des_controller!.text.isEmpty || invoice_data[i].price_controller!.text.isEmpty || invoice_data[i].quantity_controller!.text.isEmpty){
                                    isError =true;
                                  }
                                }
                                if(isError==true){
                                  Fluttertoast.showToast(
                                      msg: "Please enter all field correctly",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM_RIGHT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                      fontSize: 16.0
                                  );
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
                            if(recipient_controller.text.isEmpty){
                              Fluttertoast.showToast(
                                  msg: "Please enter recipient address",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM_RIGHT,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                  fontSize: 16.0
                              );
                            }else{
                              bool isError=false;
                              for(int i = 0 ; i<invoice_data.length; i++){
                                if(invoice_data[i].des_controller!.text.isEmpty || invoice_data[i].price_controller!.text.isEmpty || invoice_data[i].quantity_controller!.text.isEmpty){
                                  isError =true;
                                }
                              }
                              if(isError==true){
                                Fluttertoast.showToast(
                                    msg: "Please enter all field correctly",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM_RIGHT,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    webBgColor: "linear-gradient(to right, #C62828, #C62828)",
                                    fontSize: 16.0
                                );
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
                              child: Center(child: Text(isGenerating==true ? "Generating..." :"Generate Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                            ),
                          ),
                        ),

                        SizedBox(width: 15,),
                        if(isDownloadViewShowing==true)
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
                            Fluttertoast.showToast(
                                msg: "Downloading...",
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
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Color(0xff00802b)
                            ),
                            child: Center(child: Text("Download Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                          ),
                        ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: (){
                            if(getX.Get.parameters['id'] == null){
                              getX.Get.offAndToNamed("/create-invoice");
                            }else{
                              getX.Get.offAndToNamed("/create-invoice?purpose=$purpose&id=$invoice_id",);
                            }
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
      editableInvoiceItem eii=editableInvoiceItem(description: "", quantity: 0, price: 0.00, totalAmount: 0.00, des_controller: TextEditingController(), price_controller: TextEditingController(), quantity_controller: TextEditingController());
      invoice_data.add(eii);

      gst_controller.text="18";
      other_charges_controller.text="0.00";
      paid_amount_controller.text="0.00";
      comment_controller.text="If you have any questions concerning this invoice, contact name, phone or amount please contact us at surgicaltrans@gmail.com";



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
              Text("Getting ready...", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600,fontSize: 15),)
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
        recipient_controller.text=jsonData['customer_details'];
        subtotal=double.parse(jsonData['subtotal']);
        gst=double.parse(jsonData['gst']);
        other_charges_controller.text=jsonData['other_charges'];
        grand_total=double.parse(jsonData['grand_total']);
        paid_amount_controller.text=jsonData['paid'];
        due_amount=double.parse(jsonData['due']);
        comment_controller.text=jsonData['custom_note'];
        gst_controller.text=jsonData['gst_percentage'];

        date_controller.text=formattedDate(invoice_date);

        invoice_details_list.clear();
        jsonData['details'].forEach((jsonResponse) {
          noteditableInvoiceItem obj = new noteditableInvoiceItem.fromJson(jsonResponse);
          invoice_details_list.add(obj);
        });



        for(int i =0; i<invoice_details_list.length; i++){
          editableInvoiceItem eii=editableInvoiceItem(description: invoice_details_list[i].description.toString(), quantity: int.parse(invoice_details_list[i].quantity.toString()), price: double.parse(invoice_details_list[i].price.toString()), totalAmount: double.parse(invoice_details_list[i].totalAmount.toString()), des_controller: TextEditingController(), price_controller: TextEditingController(), quantity_controller: TextEditingController());
          invoice_data.add(eii);
          invoice_data[i].des_controller!.text=invoice_details_list[i].description.toString();
          invoice_data[i].price_controller!.text=invoice_details_list[i].price.toString();
          invoice_data[i].quantity_controller!.text=invoice_details_list[i].quantity.toString();
        }

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
                              Text("INVOICE",style: GoogleFonts.alata(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),),
                              SizedBox(height: 5,),
                              purpose=="edit"?
                              Text("Invoice Number $invoice_no",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),)
                              : Text("Invoice Number ########",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              purpose=="edit"?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Invoice Date ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black)),
                                  Container(
                                    width: 70,
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
                              )
                              : Text("Invoice Date "+DateFormat('dd/MM/yyyy').format(DateTime.now()),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Text("TO :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
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
                                border: Border.all(color: Colors.blue.withOpacity(0.5),width: 1)
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
                          itemCount: invoice_data.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index){
                            return Row(
                              children: [
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
                                        controller: invoice_data[index].des_controller,
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
                                        onChanged: (v){
                                          invoice_data[index].description = invoice_data[index].des_controller!.text;
                                        },
                                      ),
                                    )),

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
                                        controller: invoice_data[index].price_controller,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
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
                                        controller: invoice_data[index].quantity_controller,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none
                                        ),
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
                                          right: BorderSide(color: Colors.blue, width: 1),
                                          bottom: BorderSide(color: Colors.blue, width: 1),
                                        ),

                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(invoice_data[index].totalAmount!.toStringAsFixed(2), style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w500),textAlign: TextAlign.right,),
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
                                editableInvoiceItem eii=editableInvoiceItem(description: "", quantity: 0, price: 0.00, totalAmount: 0.00, des_controller: TextEditingController(), price_controller: TextEditingController(), quantity_controller: TextEditingController());
                                setState(() {
                                  invoice_data.add(eii);
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Subtotal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("GST (", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        width: 20,
                                        height: 15,
                                        child: TextField(
                                          controller: gst_controller,
                                          decoration: InputDecoration(
                                              isDense: true,border: InputBorder.none
                                          ),
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
                                          onChanged: (v){
                                            calculateInvoice();
                                          },
                                        ),
                                      ),
                                      Text("%)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                    ],
                                  ),
                                  Text("Other Charges", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  Text("Grand Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  Text("Paid Amount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  Text("Due Amount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
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
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(subtotal.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  Text(gst.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  Transform.translate(
                                    offset: Offset(2, 0),
                                    child: Container(
                                      margin: EdgeInsets.only(top: 3),
                                      width: 80,
                                      height: 15,
                                      child: TextField(
                                        controller: other_charges_controller,
                                        decoration: InputDecoration(
                                            isDense: true,border: InputBorder.none
                                        ),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
                                        onChanged: (v){
                                          calculateInvoice();
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(grand_total.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                  Transform.translate(
                                    offset: Offset(2, 0),
                                    child: Container(
                                      margin: EdgeInsets.only(top: 3),
                                      width: 80,
                                      height: 15,
                                      child: TextField(
                                        controller: paid_amount_controller,
                                        decoration: InputDecoration(
                                            isDense: true,border: InputBorder.none
                                        ),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
                                        onChanged: (v){
                                          calculateInvoice();
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(due_amount.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                                ],
                              ),
                            ],
                          ),
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
    for(int i=0; i<invoice_data.length; i++){
      subtotal = subtotal + invoice_data[i].totalAmount!;
    }
    if(gst_controller.text.isNotEmpty){
      gst=(subtotal*double.parse(gst_controller.text))/100;
    }else{
      gst=0.00;
    }

    if(other_charges_controller.text.isEmpty){
      grand_total = subtotal + gst;
    }else{
      grand_total = subtotal + gst + double.parse(other_charges_controller.text);
    }

    if(paid_amount_controller.text.isEmpty){
      due_amount = grand_total;
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
      noteditableInvoiceItem a = noteditableInvoiceItem(description: invoice_data[i].description.toString(),quantity: invoice_data[i].quantity.toString(),price: invoice_data[i].price!.toStringAsFixed(2),totalAmount: invoice_data[i].totalAmount!.toStringAsFixed(2));
      invoice_items.add(a);
    }
    String invoice_item_list=jsonEncode(invoice_items);
    var url = Uri.parse(update_invoice);
    Map<String, String> body = {"invoice_id":invoice_id,"date":formattedDate2(date_controller.text),"customer_details": recipient_controller.text.trim(),"subtotal":subtotal.toStringAsFixed(2), "gst_percentage":gst_controller.text, "gst":gst.toStringAsFixed(2), "grand_total":grand_total.toStringAsFixed(2),"paid":paid_amount_controller.text.toString(),"due":due_amount.toStringAsFixed(2),"custom_note":comment_controller.text.trim(),"other_charges":other_charges_controller.text,"descriptions":invoice_item_list};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;

      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        generatePdf(invoice_no, recipient_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst_controller.text, gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), paid_amount_controller.text.toString(), due_amount.toStringAsFixed(2),comment_controller.text.trim());
        setState(() {
          placeHolder=invoiceView(invoice_no, recipient_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst_controller.text, gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), paid_amount_controller.text.toString(), due_amount.toStringAsFixed(2),comment_controller.text.trim());
        });
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

  createNewInvoice() async {
    setState(() {
      isGenerating = true;
    });
    List<noteditableInvoiceItem> invoice_items=[];
    for(int i =0; i<invoice_data.length; i++){
      noteditableInvoiceItem a = noteditableInvoiceItem(description: invoice_data[i].description.toString(),quantity: invoice_data[i].quantity.toString(),price: invoice_data[i].price!.toStringAsFixed(2),totalAmount: invoice_data[i].totalAmount!.toStringAsFixed(2));
      invoice_items.add(a);
    }
    String invoice_item_list=jsonEncode(invoice_items);
    var url = Uri.parse(update_invoice);
    Map<String, String> body = {"customer_details": recipient_controller.text.trim(),"subtotal":subtotal.toStringAsFixed(2), "gst_percentage":gst_controller.text, "gst":gst.toStringAsFixed(2), "grand_total":grand_total.toStringAsFixed(2),"paid":paid_amount_controller.text.toString(),"due":due_amount.toStringAsFixed(2),"custom_note":comment_controller.text.trim(),"other_charges":other_charges_controller.text,"descriptions":invoice_item_list};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      print(myData);
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        invoice_no=jsonData['invoice_no'];
        generatePdf(invoice_no, recipient_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst_controller.text, gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), paid_amount_controller.text.toString(), due_amount.toStringAsFixed(2),comment_controller.text.trim());
        setState(() {
          placeHolder=invoiceView(invoice_no, recipient_controller.text.trim(), invoice_items, subtotal.toStringAsFixed(2), gst_controller.text, gst.toStringAsFixed(2), other_charges_controller.text, grand_total.toStringAsFixed(2), paid_amount_controller.text.toString(), due_amount.toStringAsFixed(2),comment_controller.text.trim());

        });
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


  Widget invoiceView(String invoice_number, String customer_details, List<noteditableInvoiceItem> invoice_item_details, String subtotal, String gst_percentage, String gst, String other_charges, String grand_total, String paid, String due, String comments){
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
                              Text("Invoice Number : "+invoice_number,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              Text("Invoice Date : "+DateFormat('dd/MM/yyyy').format(DateTime.now()),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Text("TO :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black),),
                      Text(customer_details,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),

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
                          itemCount: invoice_item_details.length,
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
                                          Expanded(child: Text(invoice_item_details[index].description.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500,),softWrap: true, overflow: TextOverflow.fade,)),
                                        ],
                                      ),
                                    )),

                                Expanded(
                                    flex: 3,
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
                                          Text(invoice_item_details[index].price.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
                                      ),
                                    )),

                                Expanded(
                                    flex: 3,
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
                                          Text(invoice_item_details[index].quantity.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
                                        ],
                                      ),
                                    )),

                                Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 30,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Subtotal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text("GST ($gst_percentage%)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text("Other charges", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text("Grand Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text("Paid Amount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text("Due Amount", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
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
                              Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(" : ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                            ],
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(subtotal, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(gst, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(other_charges, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(grand_total, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(paid, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(due, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 50,),

                      Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                      SizedBox(height: 3,),
                      Text(comments,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black),),

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

              ),
            ],
          ),
        ],
      ),
    );
  }




  generatePdf(String invoice_no, String recipient_details,  List<noteditableInvoiceItem> invoice_items, String subtotal, String gst_percentage, String gst, String other_charges, String grand_total, String paid, String due, String comments) async {
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
            pw.Text("INVOICE",style: pw.TextStyle(fontSize: 18,fontWeight:pw.FontWeight.bold,color: PdfColors.black),),
            pw.SizedBox(height: 5,),
            pw.Text("Invoice Number $invoice_no",style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
            pw.Text("Invoice Date "+DateFormat('dd/MM/yyyy').format(DateTime.now()),style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
          ],
        ),
      ],
    ));


    widgets.add( pw.SizedBox(height: 30,),);

    widgets.add(pw.Text("TO :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 13,color: PdfColors.black),),);
    widgets.add(pw.Text(recipient_details,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 13,color: PdfColors.black),),);
    widgets.add(pw.SizedBox(height: 30,),);




    widgets.add(pw.Table.fromTextArray(
        data: [
          ['Sl. No.','Description', 'Quantity', 'Price', 'Total'],
          ...invoice_items.asMap().entries.map((item) => [
            (item.key+1).toString()+".",
            item.value.description.toString(),
            item.value.quantity.toString(),
            item.value.price.toString(),
            item.value.totalAmount.toString(),
          ]).toList(),
        ],
        cellAlignment: pw.Alignment.centerRight,
        cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
        pw.Column(
          crossAxisAlignment:pw. CrossAxisAlignment.start,
          children: [
            pw.Text("Subtotal", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text("GST ($gst_percentage%)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text("Other charges", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text("Grand Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text("Paid", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text("Due", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(" : ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(" : ", style: pw.TextStyle(fontWeight:pw. FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(" : ", style:pw. TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(" : ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(" : ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(" : ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
          ],
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(subtotal, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(gst, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(other_charges, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(grand_total, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(paid, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
            pw.Text(due, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
          ],
        ),
      ],
    ),);

    widgets.add(pw.SizedBox(height: 50,),);

    widgets.add(pw.Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12,color: PdfColors.black),),);
    widgets.add(pw.SizedBox(height: 3,),);
    widgets.add(pw.Text(comments,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 11,color: PdfColors.black),),);
    widgets.add(pw.SizedBox(height: 30,),);
    widgets.add(pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text("THANK YOU FOR YOUR BUSINESS!",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 14,color:PdfColors.black),),

      ],
    ),);

    widgets.add(pw.SizedBox(height: 80,),);


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => widgets,
      ),
    );

    pdf_bytes=await pdf.save();


    setState(() {
      isGenerating = false;
      isGenerateViewShowing=false;
      isDownloadViewShowing=true;
    });

    Fluttertoast.showToast(
        msg: "Invoice Generated!",
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


  String formattedDate(String inputDate){
    DateFormat format = DateFormat("yyyy-MM-dd");
    var inDate = format.parse(inputDate);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formatted = formatter.format(inDate);
    return formatted;
  }

  String formattedDate2(String inputDate){
    DateFormat format = DateFormat("dd/MM/yyyy");
    var inDate = format.parse(inputDate);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(inDate);
    return formatted;
  }


}
