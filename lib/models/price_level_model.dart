class PriceLevel {
  final int id;
  final String companyId;       
  final int companyRefId;     
  final String listName;

  PriceLevel({
    required this.id,
    required this.companyId,
    required this.companyRefId,
    required this.listName,
  });

  factory PriceLevel.fromJson(Map<String, dynamic> json) {
    return PriceLevel(
      id: int.parse(json['id'].toString()),
      companyId: json['company_id'],
      companyRefId: int.parse(json['company_ref_id'].toString()), 
      listName: json['list_name'],
    );
  }
}