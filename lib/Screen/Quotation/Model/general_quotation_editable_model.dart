import 'package:flutter/cupertino.dart';

class GeneralQuotationEditableModel {
  String? product_name;
  String? hsn_no;
  String? quantity;
  String? rate;
  String? gst;
  String? gst_percentage;
  String? amount;
  TextEditingController? product_name_controller;
  TextEditingController? hsn_no_controller;
  TextEditingController? quantity_controller;
  TextEditingController? rate_controller;
  TextEditingController? gst_controller;


  GeneralQuotationEditableModel({required this.product_name, required this.hsn_no, required this.quantity,
      required this.rate,required this.gst,required this.gst_percentage, required this.amount, required this.product_name_controller,
      required this.hsn_no_controller, required this.quantity_controller, required this.rate_controller, required this.gst_controller});

  GeneralQuotationEditableModel.fromJson(Map<String, dynamic> json) {
    product_name = json['product_name'];
    hsn_no = json['hsn_code'];
    quantity = json['quantity'];
    rate = json['rate'];
    gst = json['gst'];
    gst_percentage = json['gst_percentage'];
    amount = json['amount'];
    product_name_controller = TextEditingController();
    hsn_no_controller = TextEditingController();
    quantity_controller = TextEditingController();
    rate_controller = TextEditingController();
    gst_controller = TextEditingController();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    product_name = this.product_name;
    hsn_no = this.hsn_no;
    quantity = this.quantity;
    rate = this.rate;
    gst = this.gst;
    gst_percentage = this.gst_percentage;
    amount = this.amount;
    product_name_controller = this.product_name_controller;
    hsn_no_controller = this.hsn_no_controller;
    quantity_controller = this.quantity_controller;
    rate_controller = this.rate_controller;
    gst_controller = this.gst_controller;
    return data;
  }
}