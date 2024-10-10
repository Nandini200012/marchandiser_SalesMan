class Vendors {
  final int vendorId;
  final String vendorName;
  final String vendorCode;
  final String mobileNo;
  final dynamic salesPerson;
  final dynamic salesPersonName;

  Vendors(
      {required this.vendorId,
      required this.vendorName,
      required this.vendorCode,
      required this.mobileNo,
      required this.salesPerson,
      required this.salesPersonName});

  factory Vendors.fromJson(Map<String, dynamic> json) {
    return Vendors(
        vendorId: json['vendorId'],
        vendorName: json['vendorName'],
        vendorCode: json['vendorCode'],
        mobileNo: json['mobileNo'],
        salesPerson: json['salesPerson'],
        salesPersonName: json['salesPersonName']);
  }
}
