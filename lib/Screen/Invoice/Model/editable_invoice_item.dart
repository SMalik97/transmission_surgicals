import 'package:flutter/material.dart';

class editableInvoiceItem {
  String? description;
  int? quantity;
  double? price;
  double? totalAmount;
  TextEditingController? des_controller;
  TextEditingController? price_controller;
  TextEditingController? quantity_controller;

  editableInvoiceItem({required this.description, required this.quantity, required this.price, required this.totalAmount,required this.des_controller, required this.price_controller, required this.quantity_controller});

  editableInvoiceItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    quantity = json['quantity'];
    price = json['price'];
    totalAmount = json['total_amount'];
    des_controller = TextEditingController();
    price_controller = TextEditingController();
    quantity_controller = TextEditingController();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['total_amount'] = this.totalAmount;
    des_controller = this.des_controller;
    price_controller = this.price_controller;
    quantity_controller = this.quantity_controller;
    return data;
  }
}