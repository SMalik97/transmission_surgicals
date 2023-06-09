import 'package:flutter/material.dart';

class noteditableInvoiceItem {
  String? description;
  String? quantity;
  String? price;
  String? totalAmount;
  String? hsn;
  String? cgst;
  String? sgst;

  noteditableInvoiceItem({required this.description,
    required this.hsn,
    required this.quantity,
    required this.price,
    required this.totalAmount,
    required this.cgst,
    required this.sgst,});

  noteditableInvoiceItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    hsn = json['hsn'];
    quantity = json['quantity'];
    price = json['price'];
    cgst = json['cgst'];
    sgst = json['sgst'];
    totalAmount = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['hsn'] = this.hsn;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['cgst'] = this.cgst;
    data['sgst'] = this.sgst;
    data['total'] = this.totalAmount;
    return data;
  }
}