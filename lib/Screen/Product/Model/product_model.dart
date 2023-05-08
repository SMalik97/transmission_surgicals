class ProductModel {
  String? productId;
  String? productName;
  String? productDescription;
  List<ProductImages>? images;
  String? status;

  ProductModel(
      {this.productId,
        this.productName,
        this.productDescription,
        this.images,
        this.status});

  ProductModel.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'].toString();
    productName = json['product_name'].toString();
    productDescription = json['product_description'].toString();
    if (json['images'] != null) {
      images = <ProductImages>[];
      json['images'].forEach((v) {
        images!.add(new ProductImages.fromJson(v));
      });
    }
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_description'] = this.productDescription;
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    return data;
  }
}

class ProductImages {
  String? imageId;
  String? productId;
  String? imageName;

  ProductImages({this.imageId, this.productId, this.imageName});

  ProductImages.fromJson(Map<String, dynamic> json) {
    imageId = json['image_id'].toString();
    productId = json['product_id'].toString();
    imageName = json['image_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image_id'] = this.imageId;
    data['product_id'] = this.productId;
    data['image_name'] = this.imageName;
    return data;
  }
}
