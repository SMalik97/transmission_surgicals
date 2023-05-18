import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ImageQuotationEditableModel {
  String? product_name;
  String? quantity;
  String? rate;
  String? gst;
  String? gst_percentage;
  String? amount;
  bool? isSelectImage;
  String? ImageId;
  Uint8List? ImageData;
  TextEditingController? product_name_controller;
  TextEditingController? quantity_controller;
  TextEditingController? rate_controller;
  TextEditingController? gst_controller;


  ImageQuotationEditableModel({required this.product_name, required this.quantity,
    required this.rate,required this.gst,required this.gst_percentage, required this.amount, required this.isSelectImage, required this.ImageId, required this.ImageData, required this.product_name_controller,
    required this.quantity_controller, required this.rate_controller, required this.gst_controller});

  ImageQuotationEditableModel.fromJson(Map<String, dynamic> json) {
    product_name = json['product_name'];
    quantity = json['quantity'];
    rate = json['rate'];
    gst = json['gst'];
    gst_percentage = json['gst_percentage'];
    amount = json['amount'];
    isSelectImage = false;
    ImageId = json['Image_name'];
    ImageData = json['Image_data'];
    product_name_controller = TextEditingController();
    quantity_controller = TextEditingController();
    rate_controller = TextEditingController();
    gst_controller = TextEditingController();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    product_name = this.product_name;
    quantity = this.quantity;
    rate = this.rate;
    gst = this.gst;
    gst_percentage = this.gst_percentage;
    amount = this.amount;
    isSelectImage = this.isSelectImage;
    ImageId = this.ImageId;
    ImageData = this.ImageData;
    product_name_controller = this.product_name_controller;
    quantity_controller = this.quantity_controller;
    rate_controller = this.rate_controller;
    gst_controller = this.gst_controller;
    return data;
  }
}