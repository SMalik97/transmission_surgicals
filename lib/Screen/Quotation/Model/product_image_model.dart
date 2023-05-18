
class ProductImage {
  String? productId;
  String? imageName;
  String? productName;

  ProductImage({this.productId, this.imageName, this.productName});

  ProductImage.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    imageName = json['image_name'];
    productName = json['product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['image_name'] = this.imageName;
    data['product_name'] = this.productName;
    return data;
  }
}
