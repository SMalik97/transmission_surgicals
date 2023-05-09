import 'package:flutter/material.dart';

class editableInvoiceItem {
  String? description;
  String? hsn;
  int? quantity;
  double? price;
  double? totalAmount;
  double? gst_percentage;
  double? gst;
  TextEditingController? des_controller;
  TextEditingController? price_controller;
  TextEditingController? quantity_controller;
  TextEditingController? hsn_controller;
  TextEditingController? gst_percentage_controller;


  editableInvoiceItem(
  {required this.description,
      required this.hsn,
      required this.quantity,
      required this.price,
      required this.totalAmount,
      required this.gst_percentage,
      required this.gst,
      required this.des_controller,
      required this.price_controller,
      required this.quantity_controller,
      required this.hsn_controller,
      required this.gst_percentage_controller});


  editableInvoiceItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    hsn = json['hsn'];
    quantity = json['quantity'];
    price = json['price'];
    gst_percentage = json['gst_percentage'];
    gst = json['gst'];
    totalAmount = json['total_amount'];
    des_controller = TextEditingController();
    price_controller = TextEditingController();
    quantity_controller = TextEditingController();
    hsn_controller = TextEditingController();
    gst_percentage_controller = TextEditingController();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['hsn'] = this.hsn;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['gst_percentage'] = this.gst_percentage;
    data['gst'] = this.gst;
    data['total_amount'] = this.totalAmount;
    des_controller = this.des_controller;
    price_controller = this.price_controller;
    quantity_controller = this.quantity_controller;
    hsn_controller = this.hsn_controller;
    gst_percentage_controller = this.gst_percentage_controller;
    return data;
  }
}