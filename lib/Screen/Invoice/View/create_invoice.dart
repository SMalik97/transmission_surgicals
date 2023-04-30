import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart' as getX;
import '../../../Utils/urls.dart';
import '../Model/editable_invoice_item.dart';
import '../Model/noteditable_invoice_item.dart';

class InvoiceCreate extends StatefulWidget {
  const InvoiceCreate({Key? key}) : super(key: key);

  @override
  State<InvoiceCreate> createState() => _InvoiceCreateState();
}

class _InvoiceCreateState extends State<InvoiceCreate> {

  final pdf = pw.Document();
  List<editableInvoiceItem> invoice_data=[];
  final recipient_controller=TextEditingController();
  final gst_controller=TextEditingController();
  final other_charges_controller=TextEditingController();
  final paid_amount_controller=TextEditingController();
  final comment_controller=TextEditingController();
  Widget placeHolder=Container();

  bool isGenerateViewShowing=true;
  bool isDownloadViewShowing=false;
  bool isGenerating=false;

  double subtotal=0.00, gst=0.00, grand_total=0.00, due_amount=0.00;

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
                        Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Color(0xff00802b)
                          ),
                          child: Center(child: Text("Download Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
                        ),
                        SizedBox(width: 25,),
                        InkWell(
                          onTap: (){
                            getX.Get.offAndToNamed("/create-invoice");
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
    editableInvoiceItem eii=editableInvoiceItem(description: "", quantity: 0, price: 0.00, totalAmount: 0.00, des_controller: TextEditingController(), price_controller: TextEditingController(), quantity_controller: TextEditingController());
    invoice_data.add(eii);

    gst_controller.text="18";
    other_charges_controller.text="0.00";
    paid_amount_controller.text="0.00";
    comment_controller.text="If you have any questions concerning this invoice, contact name, phone or amount please contact us at surgicaltrans@gmail.com";



    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      List<noteditableInvoiceItem> a =[];
      noteditableInvoiceItem b=noteditableInvoiceItem(description: "description", quantity: "1", price: "78", totalAmount: "45");
      a.add(b);
      a.add(b);
      a.add(b);
      a.add(b);
      // setState(() {
      //   placeHolder = invoiceView("748596", "30/04/2023", "Customer Name\nCustomer Address\nPhone : +91 1234567890\nEmail : example@mail.com", a, "23.20", "45.36", "12", "45.36", "45.36", "45.36", "23.00", "If you have any questions concerning this invoice, contact name, phone or amount please contact us at surgicaltrans@gmail.com");
      // });
      setState(() {
        placeHolder=createInvoiceView();
      });
    });

    super.initState();
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
                              Text("Invoice Number ########",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              Text("Invoice Date #########",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

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
                                            invoice_data[index].quantity = int.parse(invoice_data[index].price_controller!.text);
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


  createNewInvoice() async {
    setState(() {
      isGenerating = true;
    });
    List<noteditableInvoiceItem> invoice_items=[];
    for(int i =0; i<invoice_data.length; i++){
      noteditableInvoiceItem a = noteditableInvoiceItem(description: invoice_data[i].description.toString(),quantity: invoice_data[i].quantity.toString(),price: invoice_data[i].price.toString(),totalAmount: invoice_data[i].totalAmount.toString());
      invoice_items.add(a);
    }
    String invoice_item_list=jsonEncode(invoice_items);
    var url = Uri.parse(create_invoice);
    Map<String, String> body = {"customer_details": recipient_controller.text.trim(),"subtotal":subtotal.toStringAsFixed(2), "gst":gst.toStringAsFixed(2), "grand_total":grand_total.toStringAsFixed(2),"paid":paid_amount_controller.text.toString(),"due":due_amount.toStringAsFixed(2),"custom_note":comment_controller.text.trim(),"other_charges":other_charges_controller.text,"descriptions":invoice_item_list};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      print(myData);
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="success"){
        String invoice_no=jsonData['invoice_no'];
      }else{

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
      isGenerating = false;
    });


  }


  Widget invoiceView(String invoice_number, String invoice_date, String customer_details, List<noteditableInvoiceItem> invoice_item_details, String subtotal, String gst, String gst_percentage, String other_charges, String grand_total, String paid, String due, String comments){
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
                              Text("Invoice Date : "+invoice_date,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

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
                                          Text(invoice_item_details[index].description.toString(),style: TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.w500),),
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

}
