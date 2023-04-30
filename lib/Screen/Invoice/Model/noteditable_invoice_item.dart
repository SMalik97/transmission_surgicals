import 'package:flutter/material.dart';

class noteditableInvoiceItem {
  String? description;
  String? quantity;
  String? price;
  String? totalAmount;

  noteditableInvoiceItem({required this.description, required this.quantity, required this.price, required this.totalAmount});

  noteditableInvoiceItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    quantity = json['quantity'];
    price = json['price'];
    totalAmount = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['total'] = this.totalAmount;
    return data;
  }
}