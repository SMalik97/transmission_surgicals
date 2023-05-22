import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageQuotationNotEditableModel {
  String? productName;
  String? quantity;
  String? rate;
  String? gst;
  String? gst_percentage;
  String? amount;
  String? imageId;
  Uint8List? ImageData;


  ImageQuotationNotEditableModel({required this.productName, required this.imageId, required this.quantity, required this.rate, required this.gst,  required this.gst_percentage, required this.amount, required this.ImageData});

  ImageQuotationNotEditableModel.fromJson(Map<String, dynamic> json) {
    productName = json['product_name'];
    quantity = json['quantity'];
    rate = json['rate'];
    gst = json['gst'];
    gst_percentage = json['gst_percentage'];
    amount = json['amount'];
    ImageData = json['ImageData'];
    imageId = json['image_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_name'] = this.productName;
    data['quantity'] = this.quantity;
    data['rate'] = this.rate;
    data['gst'] = this.gst;
    data['gst_percentage'] = this.gst_percentage;
    data['amount'] = this.amount;
    data['image_id'] = this.imageId;
    ImageData = this.ImageData;
    return data;
  }
}