import 'package:flutter/material.dart';

class noteditableInvoiceItem {
  String? description;
  String? quantity;
  String? price;
  String? totalAmount;
  String? hsn;
  String? gst;
  String? gst_percentage;
  String? cgst;
  String? cgst_percentage;
  String? sgst;
  String? sgst_percentage;

  noteditableInvoiceItem({required this.description,
    required this.hsn,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.gst,
    required this.gst_percentage,
    required this.cgst,
    required this.cgst_percentage,
    required this.sgst,
    required this.sgst_percentage,});

  noteditableInvoiceItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    hsn = json['hsn'];
    quantity = json['quantity'];
    price = json['price'];
    gst = json['gst'];
    gst_percentage = json['gst_percentage'];
    cgst = json['cgst'];
    cgst_percentage = json['cgst_percentage'];
    sgst = json['sgst'];
    sgst_percentage = json['sgst_percentage'];
    totalAmount = json['total'];
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
    data['total'] = this.totalAmount;
    return data;
  }
}