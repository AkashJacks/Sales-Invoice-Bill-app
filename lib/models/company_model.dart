class Company {
  final int id;
  final String companyId;
  final String companyName;
  final String address1;
  final String address2;
  final String address3;
  final String district;
  final String city;
  final String pincode;
  final String state;
  final String country;
  final String gstin;
  final String mobile;
  final String email;
  final String website;

  Company({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.district,
    required this.city,
    required this.pincode,
    required this.state,
    required this.country,
    required this.gstin,
    required this.mobile,
    required this.email,
    required this.website,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: int.parse(json['id']),
      companyId: json['company_id'] ?? "",
      companyName: json['company_name'] ?? "",
      address1: json['address1'] ?? "",
      address2: json['address2'] ?? "",
      address3: json['address3'] ?? "",
      district: json['district'] ?? "",
      city: json['city'] ?? "",
      pincode: json['pincode'] ?? "",
      state: json['state'] ?? "",
      country: json['country'] ?? "",
      gstin: json['gstin'] ?? "",
      mobile: json['mobile'] ?? "",
      email: json['email'] ?? "",
      website: json['website'] ?? "",
    );
  }
}