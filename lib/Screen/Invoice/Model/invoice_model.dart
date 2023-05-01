
class InvoiceModel {
  String? invoiceId;
  String? invoiceNo;
  String? grandTotal;
  String? date;
  String? recipientDetails;

  InvoiceModel(
      {this.invoiceId,
        this.invoiceNo,
        this.grandTotal,
        this.date,
        this.recipientDetails});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    invoiceId = json['invoice_id'];
    invoiceNo = json['invoice_no'];
    grandTotal = json['grand_total'];
    date = json['date'];
    recipientDetails = json['customer_details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invoice_id'] = this.invoiceId;
    data['invoice_no'] = this.invoiceNo;
    data['grand_total'] = this.grandTotal;
    data['date'] = this.date;
    data['customer_details'] = this.recipientDetails;
    return data;
  }
}
