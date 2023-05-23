class ImageQuotationModel {
  String? id;
  String? imageQuotationId;
  String? buyerName;
  String? buyerAddress;
  String? buyerContactDetails;
  String? buyerGst;
  String? date;
  String? sellerContactDetails;
  String? packagingFee;
  String? subtotal;
  String? gst;
  String? totalAmount;
  String? isdelete;
  String? quotationTitle;

  ImageQuotationModel(
      {this.id,
        this.imageQuotationId,
        this.buyerName,
        this.buyerAddress,
        this.buyerContactDetails,
        this.buyerGst,
        this.date,
        this.sellerContactDetails,
        this.packagingFee,
        this.subtotal,
        this.gst,
        this.totalAmount,
        this.isdelete,
        this.quotationTitle});

  ImageQuotationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageQuotationId = json['image_quotation_id'];
    buyerName = json['buyer_name'];
    buyerAddress = json['buyer_address'];
    buyerContactDetails = json['buyer_contact_details'];
    buyerGst = json['buyer_gst'];
    date = json['date'];
    sellerContactDetails = json['seller_contact_details'];
    packagingFee = json['packaging_fee'];
    subtotal = json['subtotal'];
    gst = json['gst'];
    totalAmount = json['total_amount'];
    isdelete = json['isdelete'];
    quotationTitle = json['quotation_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image_quotation_id'] = this.imageQuotationId;
    data['buyer_name'] = this.buyerName;
    data['buyer_address'] = this.buyerAddress;
    data['buyer_contact_details'] = this.buyerContactDetails;
    data['buyer_gst'] = this.buyerGst;
    data['date'] = this.date;
    data['seller_contact_details'] = this.sellerContactDetails;
    data['packaging_fee'] = this.packagingFee;
    data['subtotal'] = this.subtotal;
    data['gst'] = this.gst;
    data['total_amount'] = this.totalAmount;
    data['isdelete'] = this.isdelete;
    data['quotation_title'] = this.quotationTitle;
    return data;
  }
}
