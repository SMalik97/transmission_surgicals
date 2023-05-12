import 'package:flutter/cupertino.dart';

class editableChallanModel {
  String? description;
  int? quantity;
  String? hsn;
  double? totalAmount;
  TextEditingController? des_controller;
  TextEditingController? hsn_controller;
  TextEditingController? quantity_controller;
  TextEditingController? amount_controller;

  editableChallanModel({required this.description, required this.quantity, required this.hsn, required this.totalAmount,required this.des_controller, required this.hsn_controller, required this.quantity_controller, required this.amount_controller});

  editableChallanModel.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    quantity = json['quantity'];
    hsn = json['hsn'];
    totalAmount = json['total_amount'];
    des_controller = TextEditingController();
    hsn_controller = TextEditingController();
    quantity_controller = TextEditingController();
    amount_controller = TextEditingController();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    data['hsn'] = this.hsn;
    data['total_amount'] = this.totalAmount;
    des_controller = this.des_controller;
    hsn_controller = this.hsn_controller;
    quantity_controller = this.quantity_controller;
    amount_controller = this.amount_controller;
    return data;
  }

}