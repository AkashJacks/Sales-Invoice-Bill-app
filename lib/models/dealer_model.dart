class Dealer {
  final int id;
  final String companyId;
  final int companyRefId;
  final String dealerId;
  final String dealerName;
  final String address1;
  final String address2;
  final String address3;
  final String district;
  final String city;
  final String pincode;
  final String state;
  final String country;
  final String gstin;
  final String salesman;
  final String mobile;
  final String email;
  final String website;
  final String openingBal;

  Dealer({
    required this.id,
    required this.companyId,
    required this.companyRefId,
    required this.dealerId,
    required this.dealerName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.district,
    required this.city,
    required this.pincode,
    required this.state,
    required this.country,
    required this.gstin,
    required this.salesman,
    required this.mobile,
    required this.email,
    required this.website,
    required this.openingBal,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      id: int.parse(json['id']),
      companyId: json['company_id'] ?? "",
      companyRefId: int.parse(json['company_ref_id'].toString()), // 🔥 IMPORTANT
      dealerId: json['dealer_id'] ?? "",
      dealerName: json['dealer_name'] ?? "",
      address1: json['address1'] ?? "",
      address2: json['address2'] ?? "",
      address3: json['address3'] ?? "",
      district: json['district'] ?? "",
      city: json['city'] ?? "",
      pincode: json['pincode'] ?? "",
      state: json['state'] ?? "",
      country: json['country'] ?? "",
      gstin: json['gstin'] ?? "",
      salesman: json['salesman'] ?? "",
      mobile: json['mobile'] ?? "",
      email: json['email'] ?? "",
      website: json['website'] ?? "",
      openingBal: json['opening_bal'] ?? "",
    );
  }
}