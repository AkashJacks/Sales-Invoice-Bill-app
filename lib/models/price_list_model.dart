class PriceList {
  final int id;
  final String companyId;
  final String companyRefId;
  final String listName;
  final String applyFrom;
  final String productName;
  final String rate;
  final String itemId;

  PriceList({
    required this.id,
    required this.companyId,
    required this.companyRefId,
    required this.listName,
    required this.applyFrom,
    required this.productName,
    required this.rate,
    required this.itemId,
  });

  factory PriceList.fromJson(Map<String, dynamic> json) {
    return PriceList(
      id: int.parse(json['id'].toString()),
      companyId: json['company_id'] ?? '',
      companyRefId: json['company_ref_id'] ?? '',
      listName: json['list_name'] ?? '',
      applyFrom: json['apply_from'] ?? '',
      productName: json['product_name'] ?? '',
      rate: json['rate'] ?? '',
      itemId: json['item_id'] ?? '', 
    );
  }
}