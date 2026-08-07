class SalesInvoice {

  final int? id;

  // 🔹 HEADER
  final String companyId;
  final String invoiceNo;
  final String invoiceDate;
  final String listName;
  final String dealerId;
  final String buyingName;
  final String buyingAddress1;
  final String buyingAddress2;
  final String buyingAddress3;
  final String buyingDistrict;
  final String buyingCity;
  final String buyingState;
  final String buyingPincode;
  final String placeOfSupply;

  // 🔹 DELIVERY
  final String deliveryAddress1;
  final String deliveryAddress2;
  final String deliveryAddress3;
  final String deliveryDistrict;
  final String deliveryCity;
  final String deliveryState;
  final String deliveryPincode;

  // 🔹 OTHER
  final String discount;
  final String freight;
  final String grandTotal;

  // 🔹 INVENTORY
  final List<InvoiceItem> items;

  SalesInvoice({
    this.id,

    required this.companyId,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.listName,
    required this.dealerId,
    required this.buyingName,
    required this.buyingAddress1,
    required this.buyingAddress2,
    required this.buyingAddress3,
    required this.buyingDistrict,
    required this.buyingCity,
    required this.buyingState,
    required this.buyingPincode,
    required this.placeOfSupply,

    required this.deliveryAddress1,
    required this.deliveryAddress2,
    required this.deliveryAddress3,
    required this.deliveryDistrict,
    required this.deliveryCity,
    required this.deliveryState,
    required this.deliveryPincode,

    required this.discount,
    required this.freight,
    required this.grandTotal,

    required this.items,
  });

  //  FROM JSON
  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,

      companyId: json['company_id'] ?? '',
      invoiceNo: json['invoice_no'] ??'',
      invoiceDate: json['invoice_date'] ??'',
      listName: json['list_name']??'',
      dealerId: json['dealer_id'] ?? '',

      buyingName: json['buying_name'] ?? '',
      buyingAddress1: json['buying_address1'] ?? '',
      buyingAddress2: json['buying_address2'] ?? '',
      buyingAddress3: json['buying_address3'] ?? '',
      buyingDistrict: json['buying_district'] ?? '',
      buyingCity: json['buying_city'] ?? '',
      buyingState: json['buying_state'] ?? '',
      buyingPincode: json['buying_pincode'] ?? '',
      placeOfSupply: json['place_of_supply'] ?? '',

      deliveryAddress1: json['delivery_address1'] ?? '',
      deliveryAddress2: json['delivery_address2'] ?? '',
      deliveryAddress3: json['delivery_address3'] ?? '',
      deliveryDistrict: json['delivery_district'] ?? '',
      deliveryCity: json['delivery_city'] ?? '',
      deliveryState: json['delivery_state'] ?? '',
      deliveryPincode: json['delivery_pincode'] ?? '',

      discount: json['discount'] ?? '',
      freight: json['freight'] ?? '',
      grandTotal: json['grand_total'] ??'',

      //  INVENTORY LIST
      items: (json['items'] as List? ?? [])
          .map((e) => InvoiceItem.fromJson(e))
          .toList(),
    );
  }

  //  TO JSON (API SEND)
  Map<String, dynamic> toJson() {
    return {
      "company_id": companyId,
      "invoice_no": invoiceNo,
      "invoice_date": invoiceDate,
      "dealer_id": dealerId,
      "buying_name": buyingName,
      "buying_address1": buyingAddress1,
      "buying_address2": buyingAddress2,
      "buying_address3": buyingAddress3,
      "buying_district": buyingDistrict,
      "buying_city": buyingCity,
      "buying_state": buyingState,
      "buying_pincode": buyingPincode,
      "place_of_supply": placeOfSupply,

      "delivery_address1": deliveryAddress1,
      "delivery_address2": deliveryAddress2,
      "delivery_address3": deliveryAddress3,
      "delivery_district": deliveryDistrict,
      "delivery_city": deliveryCity,
      "delivery_state": deliveryState,
      "delivery_pincode": deliveryPincode,

      "discount": discount,
      "freight": freight,

      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}

class InvoiceItem {

  final String itemId;
  final String productName;
  final String actualQty;
  final String billedQty;
  final String rate;
  final String discount;
  final String amount;
  final String hsnCode;
  final String gst;
  final String cgstPer;
  final String sgstPer;
  final String igstPer;
  final String cgstAmt;
  final String sgstAmt;
  final String igstAmt;
  final String netAmt;

  InvoiceItem({
    this.itemId = '',
    this.productName = '',
    this.actualQty = '',
    this.billedQty = '',
    this.rate = '',
    this.discount = '',
    this.amount = '',
    this.hsnCode = '',
    this.gst = '',
    this.cgstPer = '',
    this.sgstPer = '',
    this.igstPer = '',
    this.cgstAmt = '',
    this.sgstAmt = '',
    this.igstAmt = '',
    this.netAmt = '',
  });

  


  //  FROM JSON
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemId: json['item_id'] ?? '',
      productName: json['product_name'] ?? '',
      actualQty: json['actual_qty'] ?? '',
      billedQty: json['billed_qty'] ?? '',
      rate: json['rate'] ?? '',
      discount: json['discount'] ?? '',
      amount: json['amount'] ?? '',
      hsnCode: json['hsn_code'] ?? '',
      gst: json['gst'] ?? '',
      cgstPer: json['cgst_per'] ?? '',
      sgstPer: json['sgst_per'] ?? '',
      igstPer: json['igst_per'] ?? '',
      cgstAmt: json['cgst_amt'] ?? '',
      sgstAmt: json['sgst_amt'] ?? '',
      igstAmt: json['igst_amt'] ?? '',
      netAmt: json['net_amt'] ?? '',
    );
  }

  //  TO JSON
  Map<String, dynamic> toJson() {
    return {
      "item_id": itemId,
      "product_name": productName,
      "actual_qty": actualQty,
      "billed_qty": billedQty,
      "rate": rate,
      "discount": discount,
      "amount": amount,
      "hsn_code": hsnCode,
      "gst": gst,
      "cgst_per": cgstPer,
      "sgst_per": sgstPer,
      "igst_per": igstPer,
      "cgst_amt": cgstAmt,
      "sgst_amt": sgstAmt,
      "igst_amt": igstAmt,
      "net_amt": netAmt,
    };
  }
}