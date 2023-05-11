
class InvoiceModel {
  String? invoiceId;
  String? invoiceNo;
  String? grandTotal;
  String? date;
  String? billingAddress;

  InvoiceModel(
      {this.invoiceId,
        this.invoiceNo,
        this.grandTotal,
        this.date,
        this.billingAddress});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    invoiceId = json['invoice_id'];
    invoiceNo = json['invoice_no'];
    grandTotal = json['grand_total'];
    date = json['date'];
    billingAddress = json['billing_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invoice_id'] = this.invoiceId;
    data['invoice_no'] = this.invoiceNo;
    data['grand_total'] = this.grandTotal;
    data['date'] = this.date;
    data['billing_address'] = this.billingAddress;
    return data;
  }
}
