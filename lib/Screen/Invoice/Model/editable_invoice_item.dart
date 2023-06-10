import 'package:flutter/material.dart';

class editableInvoiceItem {
  String? description;
  String? hsn;
  int? quantity;
  double? price;
  double? totalAmount;
  double? gst;
  double? gst_percentage;
  double? cgst;
  double? cgst_percentage;
  double? sgst;
  double? sgst_percentage;
  TextEditingController? des_controller;
  TextEditingController? price_controller;
  TextEditingController? quantity_controller;
  TextEditingController? hsn_controller;
  TextEditingController? gst_controller;
  TextEditingController? gst_percentage_controller;


  editableInvoiceItem(
  {required this.description,
      required this.hsn,
      required this.quantity,
      required this.price,
      required this.totalAmount,
      required this.gst,
      required this.gst_percentage,
      required this.cgst,
      required this.cgst_percentage,
      required this.sgst,
      required this.sgst_percentage,
      required this.des_controller,
      required this.price_controller,
      required this.quantity_controller,
      required this.hsn_controller,
      required this.gst_controller,
      required this.gst_percentage_controller});


  editableInvoiceItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    hsn = json['hsn'];
    quantity = json['quantity'];
    price = json['price'];
    gst = json['gst'];
    gst_percentage = json['gst_percentage'];
    cgst = json['cgst'];
    cgst = json['cgst_percentage'];
    sgst = json['sgst'];
    sgst = json['sgst_percentage'];
    totalAmount = json['total_amount'];
    des_controller = TextEditingController();
    price_controller = TextEditingController();
    quantity_controller = TextEditingController();
    hsn_controller = TextEditingController();
    gst_controller = TextEditingController();
    gst_percentage_controller = TextEditingController();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['hsn'] = this.hsn;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['gst'] = this.gst;
    data['gst_percentage'] = this.gst_percentage;
    data['cgst'] = this.cgst;
    data['cgst_percentage'] = this.cgst_percentage;
    data['sgst'] = this.sgst;
    data['sgst_percentage'] = this.sgst_percentage;
    data['total_amount'] = this.totalAmount;
    des_controller = this.des_controller;
    price_controller = this.price_controller;
    quantity_controller = this.quantity_controller;
    hsn_controller = this.hsn_controller;
    gst_controller = this.gst_controller;
    gst_percentage_controller = this.gst_percentage_controller;
    return data;
  }
}