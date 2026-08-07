class Item {
  final int id;
  final String companyId;
  final int companyRefId;
  final String itemId;
  final String partNo;
  final String description;
  final String unit;
  final String altUnit;
  final String conversion;
  final String dominator;
  final String hsnCode;
  final String gstPer;
  final String openingStk;
  final String openingRate;
  final String openingBal;

  Item({
    required this.id,
    required this.companyId,
    required this.companyRefId,
    required this.itemId,
    required this.partNo,
    required this.description,
    required this.unit,
    required this.altUnit,
    required this.conversion,
    required this.dominator,
    required this.hsnCode,
    required this.gstPer,
    required this.openingStk,
    required this.openingRate,
    required this.openingBal,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: int.parse(json['id']),
      companyId: json['company_id'] ?? "",
      companyRefId: int.parse(json['company_ref_id'].toString()), 
      itemId: json['item_id'] ?? "",
      partNo: json['part_no'] ?? "",
      description: json['description'] ?? "",
      unit: json['unit'] ?? "",
      altUnit: json['alt_unit'] ?? "",
      conversion: json['conversion'] ?? "",
      dominator: json['dominator'] ?? "",
      hsnCode: json['hsn_code'] ?? "",
      gstPer: json['gst_per'] ?? "",
      openingStk: json['opening_stk'] ?? "",
      openingRate: json['opening_rate'] ?? "",
      openingBal: json['opening_bal'] ?? "",
    );
  }
}