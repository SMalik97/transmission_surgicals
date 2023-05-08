import 'dart:typed_data';

class SelectImageList {
  Uint8List? file;
  String? file_name;

  SelectImageList({required this.file,required this.file_name,});

  SelectImageList.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    file_name = json['file_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file'] = this.file;
    data['file_name'] = this.file_name;
    return data;
  }
}