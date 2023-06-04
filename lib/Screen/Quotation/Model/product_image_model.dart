class ProductDetails {
  String? productId;
  String? productName;
  String? productDescription;
  String? amount;
  List<ImageList>? imageList;

  ProductDetails(
      {this.productId,
        this.productName,
        this.productDescription,
        this.amount,
        this.imageList});

  ProductDetails.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productDescription = json['product_description'];
    amount = json['amount'];
    if (json['image_list'] != null) {
      imageList = <ImageList>[];
      json['image_list'].forEach((v) {
        imageList!.add(new ImageList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_description'] = this.productDescription;
    data['amount'] = this.amount;
    if (this.imageList != null) {
      data['image_list'] = this.imageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageList {
  String? imageName;

  ImageList({this.imageName});

  ImageList.fromJson(Map<String, dynamic> json) {
    imageName = json['image_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image_name'] = this.imageName;
    return data;
  }
}
