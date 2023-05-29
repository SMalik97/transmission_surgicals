class GeneralQuotationModel {
  String? id;
  String? buyerGst;
  String? date;
  String? deliveryFee;
  String? subtotal;
  String? gst;
  String? totalAmount;
  String? quotationNo;
  String? isdelete;
  String? quotationTitle;
  String? buyerDetails;
  String? terms;

  GeneralQuotationModel(
      {this.id,
        this.buyerGst,
        this.date,
        this.deliveryFee,
        this.subtotal,
        this.gst,
        this.totalAmount,
        this.quotationNo,
        this.isdelete,
        this.quotationTitle,
        this.buyerDetails,
        this.terms});

  GeneralQuotationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    buyerGst = json['buyer_gst'];
    date = json['date'];
    deliveryFee = json['delivery_fee'];
    subtotal = json['subtotal'];
    gst = json['gst'];
    totalAmount = json['total_amount'];
    quotationNo = json['quotation_no'];
    isdelete = json['isdelete'];
    quotationTitle = json['quotation_title'];
    buyerDetails = json['buyer_details'];
    terms = json['terms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['buyer_gst'] = this.buyerGst;
    data['date'] = this.date;
    data['delivery_fee'] = this.deliveryFee;
    data['subtotal'] = this.subtotal;
    data['gst'] = this.gst;
    data['total_amount'] = this.totalAmount;
    data['quotation_no'] = this.quotationNo;
    data['isdelete'] = this.isdelete;
    data['quotation_title'] = this.quotationTitle;
    data['buyer_details'] = this.buyerDetails;
    data['terms'] = this.terms;
    return data;
  }
}
