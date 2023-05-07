class ChallanListModel {
  String? id;
  String? recipientAddress;
  String? gstNumber;
  String? vehicleNumber;
  String? supplyPlace;
  String? subtotal;
  String? gstPercentage;
  String? gst;
  String? total;
  String? date;
  String? challanNo;
  String? isdelete;
  String? otherCharges;

  ChallanListModel(
      {this.id,
        this.recipientAddress,
        this.gstNumber,
        this.vehicleNumber,
        this.supplyPlace,
        this.subtotal,
        this.gstPercentage,
        this.gst,
        this.total,
        this.date,
        this.challanNo,
        this.isdelete,
        this.otherCharges});

  ChallanListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    recipientAddress = json['recipient_address'];
    gstNumber = json['gst_number'];
    vehicleNumber = json['vehicle_number'];
    supplyPlace = json['supply_place'];
    subtotal = json['subtotal'];
    gstPercentage = json['gst_percentage'];
    gst = json['gst'];
    total = json['total'];
    date = json['date'];
    challanNo = json['challan_no'];
    isdelete = json['isdelete'];
    otherCharges = json['other_charges'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['recipient_address'] = this.recipientAddress;
    data['gst_number'] = this.gstNumber;
    data['vehicle_number'] = this.vehicleNumber;
    data['supply_place'] = this.supplyPlace;
    data['subtotal'] = this.subtotal;
    data['gst_percentage'] = this.gstPercentage;
    data['gst'] = this.gst;
    data['total'] = this.total;
    data['date'] = this.date;
    data['challan_no'] = this.challanNo;
    data['isdelete'] = this.isdelete;
    data['other_charges'] = this.otherCharges;
    return data;
  }
}
