import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart' as getX;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../Utils/urls.dart';
import '../Model/invoice_model.dart';
import '../Model/noteditable_invoice_item.dart';
import 'dart:html' as html;

class InvoiceList extends StatefulWidget {
  const InvoiceList({Key? key}) : super(key: key);

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {

  List<InvoiceModel> invoice_list=[];
  bool isListLoading=true;
  bool isInvoiceLoading=false;
  int selectedIndex=0;
  String selectedInvoiceId="", selectedInvoiceNumber="", selectedInvoiceShippingAddress="", selectedInvoiceBillingAddress="", selectedInvoiceSubtotal="";
  String selectedInvoiceGst="", selectedInvoiceOther_charges="", selectedInvoiceGrand_total="", selectedInvoicePaid="";
  String selectedInvoiceDue="", selectedInvoiceDate="", selectedInvoiceCustom_note="";
  late pw.Document pdf;
  late Uint8List pdf_bytes;

  List<noteditableInvoiceItem> invoice_details_list=[];

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
                          onTap: () async {
                            await getX.Get.toNamed("/create-invoice");
                            fetch_invoice_list();
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
                        InkWell(
                          onTap: (){
                            fetch_invoice_list();
                            setState(() {
                              isListLoading=true;
                              isInvoiceLoading=false;
                              selectedIndex=0;
                              selectedInvoiceId="";
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
                          Text("Getting invoice list ...", style: TextStyle(color: Colors.green.shade700,fontWeight: FontWeight.w600, fontSize: 15),)
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
                                  child: Text("Generated Invoices", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)
                              )
                          ),
                          SizedBox(height: 10,),
                          Expanded(
                            child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: invoice_list.length,
                                itemBuilder: (context, index){
                                  return InkWell(
                                    onTap: (){
                                      setState(() {
                                        isInvoiceLoading=true;
                                        selectedInvoiceId=invoice_list[index].invoiceId.toString();
                                        selectedInvoiceNumber=invoice_list[index].invoiceNo.toString();
                                        selectedIndex=index;
                                      });
                                      fetchInvoiceDetails(selectedInvoiceId);
                                    },
                                    child: Container(
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
                                              Text("Invoice No. #"+invoice_list[index].invoiceNo.toString(), style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),),
                                              Text(formattedDate(invoice_list[index].date.toString()), style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 11),),
                                            ],
                                          ),
                                          SizedBox(height: 15,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(invoice_list[index].billingAddress.toString(), style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.90), fontSize: 13),),
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text("₹"+invoice_list[index].grandTotal.toString(), style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),)
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
                      child: isInvoiceLoading==true? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(color: Colors.green.shade700,),
                            ),
                            SizedBox(height: 5,),
                            Text("Loading invoice details ...", style: TextStyle(color: Colors.green.shade700,fontWeight: FontWeight.w600, fontSize: 15),)
                          ],
                        ),
                      ) : selectedInvoiceId.isEmpty ? Center(
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
                              Text("Click on a invoice to view details", style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.w600, fontSize: 15),),
                              SizedBox(height: 5,),
                              Text("OR", style: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.w600, fontSize: 15),),
                              SizedBox(height: 5,),
                              InkWell(
                                onTap: () async {
                                  await getX.Get.toNamed("/create-invoice");
                                  fetch_invoice_list();
                                },
                                child: Container(
                                  width: 150,
                                  height: 30,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: Color(0xff00802b)
                                  ),
                                  child: Center(child: Text("Create New Invoice", style: TextStyle(color: Colors.white,fontSize: 14, fontWeight: FontWeight.w500),)),
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
                              /// Invoice number ------------------
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                                  decoration: BoxDecoration(
                                      color: Color(0xff003366).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Text("Invoice #"+selectedInvoiceNumber, style: TextStyle(fontWeight: FontWeight.w600,color: Colors.black, fontSize: 14),)
                              ),
                              SizedBox(width: 20,),

                              ///Edit Invoice ---------------------
                              InkWell(
                                onTap: () async {
                                  await getX.Get.toNamed("/create-invoice?purpose=edit&id=$selectedInvoiceId");
                                  fetch_invoice_list();
                                },
                                child: Container(
                                    width: 90,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: Color(0xff006666),
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Center(
                                        child: Text("Edit Invoice", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                    )
                                ),
                              ),
                              SizedBox(width: 20,),

                              ///Copy Invoice -------------------------
                              InkWell(
                                onTap: () async {
                                 await getX.Get.toNamed("/create-invoice?purpose=copy&id=$selectedInvoiceId");
                                  fetch_invoice_list();

                                },
                                child: Container(
                                    width: 90,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: Color(0xff003366),
                                        borderRadius: BorderRadius.circular(15)
                                    ),
                                    child: Center(
                                        child: Text("Copy Invoice", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 12),)
                                    )
                                ),
                              ),
                              SizedBox(width: 20,),


                              ///Download Invoice ---------------------
                              InkWell(
                                onTap: (){
                                  MotionToast.success(
                                    title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                    description:  Text("Please wait, downloading..."),
                                  ).show(context);
                                  Timer(Duration(milliseconds: 300),(){
                                    generatePdf("download",selectedInvoiceNumber, selectedInvoiceBillingAddress, selectedInvoiceShippingAddress,  invoice_details_list, selectedInvoiceSubtotal, selectedInvoiceGst, selectedInvoiceOther_charges, selectedInvoiceGrand_total, selectedInvoicePaid, selectedInvoiceDue, selectedInvoiceCustom_note);
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

                              ///Print Invoice ---------------------
                              InkWell(
                                onTap: (){
                                  MotionToast.success(
                                    title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
                                    description:  Text("Initializing printer ..."),
                                  ).show(context);
                                  Timer(Duration(milliseconds: 300),(){
                                    generatePdf("print",selectedInvoiceNumber, selectedInvoiceBillingAddress, selectedInvoiceShippingAddress,  invoice_details_list, selectedInvoiceSubtotal, selectedInvoiceGst, selectedInvoiceOther_charges, selectedInvoiceGrand_total, selectedInvoicePaid, selectedInvoiceDue, selectedInvoiceCustom_note);
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

                              ///Delete Invoice ---------------------
                              InkWell(
                                onTap: (){
                                  deleteInvoice();
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
                          invoiceView()
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

  @override
  void initState() {
    fetch_invoice_list();
    super.initState();
  }


  Widget invoiceView(){
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
                              Text("TAX INVOICE",style: GoogleFonts.alata(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                              SizedBox(height: 5,),
                              Text("Invoice Number : "+selectedInvoiceNumber,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                              Text("Invoice Date : "+formattedDate(selectedInvoiceDate),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),

                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Billing Address :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),
                                Text(selectedInvoiceBillingAddress,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Shipping Address :",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.black),),
                                Text(selectedInvoiceShippingAddress,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 13,color: Colors.black),),
                              ],
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 30,),


                      DataTable(
                        columns: [
                          DataColumn(label: Text('Sl. No.'),),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('HSN/SAC')),
                          DataColumn(label: Text('Quantity')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('GST')),
                          DataColumn(label: Text('Total')),
                        ],
                        rows: [
                          ...invoice_details_list.asMap().entries.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text((item.key + 1).toString() + ".")),
                                DataCell(Text(item.value.description.toString())),
                                DataCell(Text(item.value.hsn.toString())),
                                DataCell(Text(item.value.quantity.toString())),
                                DataCell(Text(item.value.price.toString())),
                                DataCell(Text(item.value.gst.toString()+"\n"+item.value.gst_percentage.toString()+"%")),
                                DataCell(Text(item.value.totalAmount.toString())),
                              ],
                            );
                          }).toList(),
                        ],

                        columnSpacing: 10,
                        headingRowColor: MaterialStateProperty.resolveWith<Color?>((states) => Colors.blue.withOpacity(0.3)),
                        border: TableBorder.all(color: Colors.blue,width: 1),
                        headingRowHeight: 30,
                        headingTextStyle: TextStyle(fontWeight: FontWeight.bold),


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
                              Text("GST", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
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
                              Text(selectedInvoiceSubtotal, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedInvoiceGst, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedInvoiceOther_charges, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedInvoiceGrand_total, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedInvoicePaid, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                              SizedBox(height: 2,),
                              Text(selectedInvoiceDue, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              color: Colors.grey.shade300,
                              child: Text("Total : "+amountToWords(int.parse(double.parse(selectedInvoiceDue).round().toString())), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),)
                          ),
                        ],
                      ),

                      SizedBox(height: 50,),

                      Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.black),),
                      SizedBox(height: 3,),
                      Text(selectedInvoiceCustom_note,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black),),

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




  fetch_invoice_list() async {
    var url = Uri.parse(fetch_invoice);
    Response response = await post(url);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      invoice_list.clear();
      jsonData['invoice_list'].forEach((jsonResponse) {
        InvoiceModel obj = new InvoiceModel.fromJson(jsonResponse);
        setState(() {
          invoice_list.add(obj);
        });
      });
      if(selectedInvoiceId.isNotEmpty){
        refreshIndex();
        fetchInvoiceDetails(selectedInvoiceId);
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


  fetchInvoiceDetails(String invoice_id) async {
    var url = Uri.parse(fetch_invoice_details);
    Map<String, String> body = {"invoice_id": invoice_id};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="Success"){
        selectedInvoiceId=jsonData['invoice_id'];
        selectedInvoiceNumber=jsonData['invoice_no'];
        selectedInvoiceBillingAddress=jsonData['billing_address'];
        selectedInvoiceShippingAddress=jsonData['shipping_address'];
        selectedInvoiceSubtotal=jsonData['subtotal'];
        selectedInvoiceGst=jsonData['gst'];
        selectedInvoiceOther_charges=jsonData['other_charges'];
        selectedInvoiceGrand_total=jsonData['grand_total'];
        selectedInvoicePaid=jsonData['paid'];
        selectedInvoiceDue=jsonData['due'];
        selectedInvoiceDate=jsonData['date'];
        selectedInvoiceCustom_note=jsonData['custom_note'];


        invoice_details_list.clear();
        jsonData['details'].forEach((jsonResponse) {
          noteditableInvoiceItem obj = new noteditableInvoiceItem.fromJson(jsonResponse);
            invoice_details_list.add(obj);
        });

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
      isInvoiceLoading=false;
    });

  }


  deleteInvoice(){
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
                Text("Are you sure you want to delete this invoice?",style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500)),
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
                        deleteInvoiceApi(selectedInvoiceId);
                        setState(() {
                          invoice_list.removeAt(selectedIndex);
                          selectedInvoiceId="";
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


  deleteInvoiceApi(String invoice_id) async {
    var url = Uri.parse(delete_invoice);
    Map<String, String> body = {"invoice_id": invoice_id};
    Response response = await post(url, body: body);
    if(response.statusCode==200){
      String myData = response.body;
      var jsonData=jsonDecode(myData);
      if(jsonData['status']=="Success"){

        setState(() {});
      }else{
        MotionToast.error(
          title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
          description:  Text("Error while deleting"),
        ).show(context);
      }
    }else{
      MotionToast.error(
        title:  Text("Message", style: TextStyle(fontWeight: FontWeight.bold),),
        description:  Text("Some error has occurred"),
      ).show(context);

    }
  }

  generatePdf(String purpose, String invoice_no, String billing_address,String shipping_address,  List<noteditableInvoiceItem> invoice_items, String subtotal, String gst, String other_charges, String grand_total, String paid, String due, String comments) async {
    pdf = pw.Document();
    final invoiceLogo = await getAssetsImage("assets/logo/logo.png");
    List<pw.Widget> widgets = [];


    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child: pw.SizedBox(height: 20,),
      )
    );

    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 10),
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
                pw.Text("TAX INVOICE",style: pw.TextStyle(fontSize: 16,fontWeight:pw.FontWeight.bold,color: PdfColors.black),),
                pw.SizedBox(height: 5,),
                pw.Text("Invoice Number $invoice_no",style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
                pw.Text("Invoice Date "+DateFormat('dd/MM/yyyy').format(DateTime.now()),style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.normal,color: PdfColors.black),),
              ],
            ),
          ],
        )
      )
    );


    widgets.add( pw.SizedBox(height: 30,),);

    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Expanded(
                    child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Billing Address :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12,color: PdfColors.black),),
                          pw.Text(billing_address,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 11,color: PdfColors.black),),
                        ]
                    )
                ),
                pw.SizedBox(width: 25),
                pw.Expanded(
                    child:pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Shipping Address :",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12,color: PdfColors.black),),
                          pw.Text(shipping_address,style: pw.TextStyle(fontWeight: pw.FontWeight.normal,fontSize: 11,color: PdfColors.black),),
                        ]
                    )
                )
              ]
          ),
        )
    );
    widgets.add(pw.SizedBox(height: 30,),);




    widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Table.fromTextArray(
              data: [
                ['Sl. No.','Description','HSN/SAC', 'Quantity', 'Price', 'GST', 'Total'],
                ...invoice_items.asMap().entries.map((item) => [
                  (item.key+1).toString()+".",
                  item.value.description.toString(),
                  item.value.hsn.toString(),
                  item.value.quantity.toString(),
                  item.value.price.toString(),
                  item.value.gst.toString()+"\n"+item.value.gst_percentage.toString()+"%",
                  item.value.totalAmount.toString(),
                ]).toList(),
              ],
              cellAlignment: pw.Alignment.centerRight,
              cellStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal, fontSize: 10),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
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
            pw.Column(
              crossAxisAlignment:pw. CrossAxisAlignment.start,
              children: [
                pw.Text("Subtotal", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
                pw.Text("GST", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.black),),
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
        ),
      )
      );

    widgets.add(pw.SizedBox(height: 30,));

    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                color: PdfColors.grey200,
                child: pw.Text("Total : "+amountToWords(int.parse(double.parse(selectedInvoiceDue).round().toString())), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),)
            ),
          ],
        ),
      )
    );

    widgets.add(pw.SizedBox(height: 50,),);

    widgets.add(
      pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 15),
        child: pw.Text("COMMENTS OR SPECIAL INSTRUCTIONS:",style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12,color: PdfColors.black),),
      )
    );
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

    widgets.add(pw.SizedBox(height: 20,),);


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
        build: (context) {
           return widgets;
        }

      ),
    );

    pdf_bytes=await pdf.save();


    if(purpose=="download"){
      final blob = html.Blob([pdf_bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = "Invoice$invoice_no.pdf";
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }

    if(purpose=="print"){
      final blob = html.Blob([pdf_bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final windowFeatures = 'resizable,scrollbars,status,titlebar';
      html.window.open(url, "Print Invoice", windowFeatures);
      html.Url.revokeObjectUrl(url);
    }



  }

  Future<Uint8List> getAssetsImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    return data.buffer.asUint8List();
  }


  refreshIndex(){
    for(int i=0; i<invoice_list.length; i++){
      if(invoice_list[i].invoiceId == selectedInvoiceId){
        selectedIndex = i;
      }
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
