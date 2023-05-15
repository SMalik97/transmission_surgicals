import 'package:flutter/material.dart';

class GeneralQuotationNotEditableModel {
  String? productName;
  String? hsn_code;
  String? quantity;
  String? rate;
  String? gst;
  String? gst_percentage;
  String? amount;


  GeneralQuotationNotEditableModel({required this.productName, required this.hsn_code, required this.quantity, required this.rate, required this.gst,  required this.gst_percentage, required this.amount});

  GeneralQuotationNotEditableModel.fromJson(Map<String, dynamic> json) {
    productName = json['product_name'];
    hsn_code = json['hsn_code'];
    quantity = json['quantity'];
    rate = json['rate'];
    gst = json['gst'];
    gst_percentage = json['gst_percentage'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_name'] = this.productName;
    data['hsn_code'] = this.hsn_code;
    data['quantity'] = this.quantity;
    data['rate'] = this.rate;
    data['gst'] = this.gst;
    data['gst_percentage'] = this.gst_percentage;
    data['amount'] = this.amount;
    return data;
  }
}