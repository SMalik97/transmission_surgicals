import 'package:flutter/material.dart';

class noteditableInvoiceItem {
  String? description;
  String? quantity;
  String? price;
  String? totalAmount;
  String? hsn;
  String? gst_percentage;
  String? gst;

  noteditableInvoiceItem({required this.description,
    required this.hsn,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.gst_percentage,
    required this.gst,});

  noteditableInvoiceItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    hsn = json['hsn'];
    quantity = json['quantity'];
    price = json['price'];
    gst_percentage = json['gst_percentage'];
    gst = json['gst'];
    totalAmount = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['hsn'] = this.hsn;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['gst_percentage'] = this.gst_percentage;
    data['gst'] = this.gst;
    data['total'] = this.totalAmount;
    return data;
  }
}