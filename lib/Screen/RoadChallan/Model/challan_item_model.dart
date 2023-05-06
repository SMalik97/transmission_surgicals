import 'package:flutter/material.dart';

class notEditableChallanItem {
  String? description;
  String? quantity;
  String? rate;
  String? totalAmount;

  notEditableChallanItem({required this.description, required this.quantity, required this.rate, required this.totalAmount});

  notEditableChallanItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    quantity = json['quantity'];
    rate = json['rate'];
    totalAmount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['rate'] = this.rate;
    data['amount'] = this.totalAmount;
    return data;
  }
}