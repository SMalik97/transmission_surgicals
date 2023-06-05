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
  String? hsnCode;
  TextEditingController? product_name_controller;
  TextEditingController? quantity_controller;
  TextEditingController? rate_controller;
  TextEditingController? gst_percentage_controller;
  TextEditingController? gst_controller;
  TextEditingController? amount_controller;
  TextEditingController? hsn_controller;


  ImageQuotationEditableModel({required this.product_name, required this.quantity,
    required this.rate,required this.gst,required this.gst_percentage, required this.amount, required this.isSelectImage, required this.ImageId, required this.ImageData, required this.product_name_controller,
    required this.quantity_controller, required this.rate_controller, required this.gst_percentage_controller, required this.gst_controller, required this.amount_controller, required this.hsnCode, required this.hsn_controller});

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
    hsnCode = json['hsn_code'];
    product_name_controller = TextEditingController();
    quantity_controller = TextEditingController();
    rate_controller = TextEditingController();
    gst_percentage_controller = TextEditingController();
    gst_controller = TextEditingController();
    amount_controller = TextEditingController();
    hsn_controller = TextEditingController();
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
    hsnCode = this.hsnCode;
    product_name_controller = this.product_name_controller;
    quantity_controller = this.quantity_controller;
    rate_controller = this.rate_controller;
    gst_percentage_controller = this.gst_percentage_controller;
    gst_controller = this.gst_controller;
    amount_controller = this.amount_controller;
    hsn_controller = this.hsn_controller;
    return data;
  }
}