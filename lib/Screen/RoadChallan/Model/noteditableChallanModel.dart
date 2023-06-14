import 'package:flutter/material.dart';

class notEditableChallanItem {
  String? description;
  String? quantity;
  String? hsn;

  notEditableChallanItem({required this.description, required this.quantity, required this.hsn});

  notEditableChallanItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    quantity = json['quantity'];
    hsn = json['hsn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['hsn'] = this.hsn;
    return data;
  }
}