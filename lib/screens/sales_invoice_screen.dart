import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/company_model.dart';
import 'dart:async';



class SalesInvoiceScreen extends StatefulWidget {
  const SalesInvoiceScreen({super.key});

  @override
  State<SalesInvoiceScreen> createState() => SalesInvoiceScreenState();
}


class InvoiceItemController {
  bool isItemSelected = false; 

  TextEditingController itemId = TextEditingController();
  TextEditingController partNo = TextEditingController();
  TextEditingController productName = TextEditingController();
  TextEditingController actualQty = TextEditingController();
  TextEditingController billedQty = TextEditingController();
  TextEditingController rate = TextEditingController();
  TextEditingController discount = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController hsnCode = TextEditingController();
  TextEditingController gst = TextEditingController();
  TextEditingController cgstPer = TextEditingController();
  TextEditingController sgstPer = TextEditingController();
  TextEditingController igstPer = TextEditingController();
  TextEditingController cgstAmt = TextEditingController();
  TextEditingController sgstAmt = TextEditingController();
  TextEditingController igstAmt = TextEditingController();
  TextEditingController netAmt = TextEditingController();
}

class SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
 
  bool showHeader = false;
  List<InvoiceItemController> items = [];

  List<Company> companyList = [];

   
  List<Map<String, dynamic>> companies = [];
  String? selectedCompanyId;

  List priceLists = [];
  String? selectedListName;

  String currentRate = "";

  List<Map<String, dynamic>> filteredDealers = [];

  List<Map<String, dynamic>> dealers = [];
  String? selectedDealerId;

  bool sameAsBuying = true;

  List listItems = [];

  List<Map<String, dynamic>> filteredItems = [];

  List<Map<String, dynamic>> itemMasters = [];
  String? selectedItemId; 
   Timer? _debounce; 
  
  String companyStateFromDB = "";
  


  final _formKey = GlobalKey<FormState>();

  // 🔹 HEADER
  final companyId = TextEditingController();
  final invoiceNo = TextEditingController();
  final invoiceDate = TextEditingController();
  final listName = TextEditingController();
  final dealerId = TextEditingController();
  final buyingName = TextEditingController();
  final buyingAddress1 = TextEditingController();
  final buyingAddress2 = TextEditingController();
  final buyingAddress3 = TextEditingController();
  final buyingDistrict = TextEditingController();
  final buyingCity = TextEditingController();
  final buyingState = TextEditingController();
  final buyingPincode = TextEditingController();
  final placeOfSupply = TextEditingController();

  // 🔹 DELIVERY
  final deliveryName = TextEditingController(); 
  final deliveryAddress1 = TextEditingController();
  final deliveryAddress2 = TextEditingController();
  final deliveryAddress3 = TextEditingController();
  final deliveryDistrict = TextEditingController();
  final deliveryCity = TextEditingController();
  final deliveryState = TextEditingController();
  final deliveryPincode = TextEditingController();

   

  // 🔹 OTHER INPUTS
  final otherDiscount = TextEditingController();
  final freight = TextEditingController();

  @override
  void initState() {
    super.initState();
     items.add(InvoiceItemController());
      fetchCompanies();
        fetchDealers();
        fetchItemsByList;
         if (selectedCompanyId != null) {
    getNextInvoiceNumber(selectedCompanyId!);
  }
  }

  //  SAVE API
 Future<void> saveInvoice() async {

   if (selectedCompanyId == null || selectedCompanyId!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Select Company ID")),
    );
    return;
  }
  
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Add at least one item")),
    );
    return;
  }

  var url = Uri.parse("http://192.168.0.4/erp_api/sales_api.php?task=add");

  try {
    
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({

        "company_id": selectedCompanyId,
        "invoice_no": invoiceNo.text,
        "invoice_date": selectedDate != null
    ? "${selectedDate!.year}-"
      "${selectedDate!.month.toString().padLeft(2, '0')}-"
      "${selectedDate!.day.toString().padLeft(2, '0')}"
    : "",
        "list_name": selectedListName,
        "dealer_id": dealerId.text, 
        "buying_name": buyingName.text,
        "buying_address1": buyingAddress1.text,
        "buying_address2": buyingAddress2.text,
        "buying_address3": buyingAddress3.text,
        "buying_district": buyingDistrict.text,
        "buying_city": buyingCity.text,
        "buying_state": buyingState.text,
        "buying_pincode": buyingPincode.text,

        "place_of_supply": placeOfSupply.text,

        "delivery_name": deliveryName.text,
        "delivery_address1": deliveryAddress1.text,
        "delivery_address2": deliveryAddress2.text,
        "delivery_address3": deliveryAddress3.text,
        "delivery_district": deliveryDistrict.text,
        "delivery_city": deliveryCity.text,
        "delivery_state": deliveryState.text,
        "delivery_pincode": deliveryPincode.text,

        "discount": otherDiscount.text,
        "freight": freight.text,
        "grand_total": calculateGrandTotal().toStringAsFixed(2),

        "items": items.map((e) => {
          "item_id": e.itemId.text,
          "part_no": e.partNo.text,
          "product_name": e.productName.text,
          "actual_qty": e.actualQty.text,
          "billed_qty": e.billedQty.text,
          "rate": e.rate.text,
          "discount": e.discount.text,
          "amount": e.amount.text,
          "hsn_code": e.hsnCode.text,
          "gst": e.gst.text,
          "cgst_per": e.cgstPer.text,
          "sgst_per": e.sgstPer.text,
          "igst_per": e.igstPer.text,
          "cgst_amt": e.cgstAmt.text,
          "sgst_amt": e.sgstAmt.text,
          "igst_amt": e.igstAmt.text,
          "net_amt": e.netAmt.text,
        }).toList(),
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["status"] ?? "Saved Successfully")),                
      );

      if (data["status"] == "success") {

  currentRate = data["rate"].toString();

  setState(() {
    for (var item in items) {
      item.rate.text = currentRate;
    }
  });
}
   
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => SalesInvoiceScreen(), 
    ),
  );
    } else {
      throw Exception("Server Error ${response.statusCode}");
    }

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}


 // COMPANY DROPDOWN
Future<void> fetchCompanies() async {
  var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get");

  var res = await http.get(url);

  List data = jsonDecode(res.body);

  setState(() {
    companies = List<Map<String, dynamic>>.from(data);
  });
}
 // DEALER DROPDOWN
Future<void> fetchDealers() async {
  var url = Uri.parse("http://192.168.0.4/erp_api/dealer_api.php?task=get");

  var res = await http.get(url);

  List data = jsonDecode(res.body);

  setState(() {
    dealers = List<Map<String, dynamic>>.from(data);
  });
}

// ITEM ID DROPDOWN


Future<void> fetchItemsByList(String companyId, String listName) async {
  try {
    var url = Uri.parse(
      "http://192.168.0.4/erp_api/item_api.php"
      "?task=get_by_list"
      "&company_id=$companyId"
      "&list_name=$listName"
    );

    print("API URL: $url");

    var res = await http.get(url);

    print("RAW RESPONSE: ${res.body}");

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      var data = jsonDecode(res.body);

      setState(() {
        listItems = data;
      });

      print("FINAL LIST ITEMS: $listItems");
    } else {
      print("Empty response");
      setState(() {
        listItems = [];
      });
    }
  } catch (e) {
    print("ERROR: $e");
  }
}


Future<void> fetchRateForItem(
    String itemId,
    InvoiceItemController item,
) async {
  try {
    if (selectedCompanyId == null || selectedListName == null) {
      print("Missing company or list");
      return;
    }

    var url = Uri.parse(
      "http://192.168.0.4/erp_api/price_list_api.php"
      "?task=get_item_rate"
      "&company_ref_id=$selectedCompanyId"
      "&list_name=$selectedListName"
      "&item_id=$itemId",
    );

    print("RATE API: $url");

    var res = await http.get(url);

    print("RAW RESPONSE: ${res.body}");

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      var data = jsonDecode(res.body);

      if (data["status"] == "success") {
        setState(() {
          item.rate.text = data["rate"].toString();
        });
      } else {
        print("Rate not found");
        item.rate.text = "0";
      }
    } else {
      print("Server error");
    }
  } catch (e) {
    print("ERROR: $e");
  }
}



void copyBuyingToDelivery() {
  deliveryName.text = buyingName.text;

  deliveryAddress1.text = buyingAddress1.text;
  deliveryAddress2.text = buyingAddress2.text;
  deliveryAddress3.text = buyingAddress3.text;

  deliveryDistrict.text = buyingDistrict.text;
  deliveryCity.text = buyingCity.text;
  deliveryState.text = buyingState.text;
  deliveryPincode.text = buyingPincode.text;
  placeOfSupply.text = buyingState.text;
}




void addRow() {
  final item = InvoiceItemController();

  //  USE GLOBAL RATE
  if (currentRate.isNotEmpty) {
    item.rate.text = currentRate;
  }

  item.rate.addListener(() => debounceCalculation(item));
  item.billedQty.addListener(() => debounceCalculation(item));
  item.discount.addListener(() => debounceCalculation(item));
  item.gst.addListener(() => debounceCalculation(item));

  setState(() {
    items.add(item);
  });
}

void debounceCalculation(InvoiceItemController item) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(Duration(milliseconds: 300), () {
    calculateItem(item);
  });
}



double calculateGrandTotal() {
  double totalNet = 0;

  for (var item in items) {
    double net = double.tryParse(item.netAmt.text) ?? 0;
    totalNet += net;
  }

  double discount = double.tryParse(otherDiscount.text) ?? 0;
  double freightAmt = double.tryParse(freight.text) ?? 0;

  return totalNet - discount + freightAmt;
}


DateTime? selectedDate;

Future<void> pickDate() async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    selectedDate = picked;

    //  UI format
    invoiceDate.text =
        "${picked.day.toString().padLeft(2, '0')}/"
        "${picked.month.toString().padLeft(2, '0')}/"
        "${picked.year}";
  }
}

Future<void> getNextInvoiceNumber(String companyId) async {
  try {
    var url = Uri.parse(
      "http://192.168.0.4/erp_api/sales_api.php?task=get_invoice&company_id=$companyId",
    );

    var response = await http.get(url);

    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data["status"] == "success") {
        setState(() {
          invoiceNo.text = data["next_invoice"].toString();
        });
      } else {
        print("Status not success");
      }
    } else {
      print("Server error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}

Future<void> fetchPriceList(String companyId) async {
  var url = Uri.parse(
    "http://192.168.0.4/erp_api/price_list_api.php?task=get_price_list&company_id=$companyId"
  );

  var res = await http.get(url);

  var data = jsonDecode(res.body);

  setState(() {
    priceLists = data;
  });
}


Future<void> fetchRateFromPriceList(String listName) async {

  var url = Uri.parse(
    "http://192.168.0.4/erp_api/price_list_api.php?task=get_rate"
    "&company_id=$selectedCompanyId"
    "&list_name=$listName"
  );

  print("API URL: $url");

  var res = await http.get(url);

  var data = jsonDecode(res.body);

  print("API RESPONSE: $data");

  if (data["status"] == "success") {

    setState(() {
      for (var item in items) {
        item.rate.text = data["rate"].toString(); 
      }
    });

  } else {
    print("Rate not found");
  }
}

Widget buildFieldWithCalc(String label, TextEditingController c) {
  return Expanded(
    child: Padding(
      padding: EdgeInsets.all(4),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          setState(() {}); 
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    ),
  );
}

  // 🔹 FIELD
 Widget buildField(String label, TextEditingController c) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        controller: c,

        enabled: selectedCompanyId != null, 

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      ),
    ),
  );
}

  // 🔹 TABLE CELL
Widget cell(TextEditingController controller, InvoiceItemController item) {
  return Padding(
    padding: EdgeInsets.all(4),
    child: TextField(
      controller: controller,

      keyboardType: TextInputType.number, 

      onChanged: (value) {
        calculateItem(item); 
      },

      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
      ),
    ),
  );
}

 //  ITEM DROPDOWN WIDGET 
Widget itemDropdownCell(InvoiceItemController item) {
  return Padding(
    padding: EdgeInsets.all(4),
    child: DropdownButton<String>(

      value: listItems.any((i) => i["item_id"] == item.itemId.text)
          ? item.itemId.text
          : null,

      hint: Text("Item"),

      items: listItems.map<DropdownMenuItem<String>>((i) {
        return DropdownMenuItem(
          value: i["item_id"].toString(),
          child: Text("${i["description"]}"),
        );
      }).toList(),

      onChanged: (val) {
        var selected = listItems.firstWhere(
          (i) => i["item_id"].toString() == val,
        );

        setState(() {
          item.itemId.text = selected["item_id"].toString();
          item.productName.text = selected["description"];
          item.partNo.text = selected["part_no"];
          item.hsnCode.text = selected["hsn_code"] ?? "";
          item.gst.text = selected["gst_per"].toString();
          item.rate.text = selected["rate"].toString();
        });

        calculateItem(item);
      },
    ),
  );
}

 //  CALCULATION WIDGET 
String normalize(String value) {
  return value.trim().toUpperCase();
}

void calculateItem(InvoiceItemController item) {

  double qty = double.tryParse(item.billedQty.text) ?? 0;
  double rate = double.tryParse(item.rate.text) ?? 0;
  double discountPer = double.tryParse(item.discount.text) ?? 0;
  double gstPer = double.tryParse(item.gst.text) ?? 0;

  //  BASE
  double base = qty * rate;

  //  DISCOUNT
  double discountAmt = (base * discountPer) / 100;
  double amount = base - discountAmt;

  item.amount.text = amount.toStringAsFixed(2);

  double cgstAmt = 0;
  double sgstAmt = 0;
  double igstAmt = 0;

  //  IMPORTANT CHANGE HERE
  String companyState = normalize(companyStateFromDB);
  String buying = normalize(buyingState.text); 



  if (companyState.isNotEmpty &&
      buying.isNotEmpty &&
      companyState == buying) {


    double halfGst = gstPer / 2;

    item.cgstPer.text = halfGst.toStringAsFixed(2);
    item.sgstPer.text = halfGst.toStringAsFixed(2);
    item.igstPer.text = "0";

    cgstAmt = (amount * halfGst) / 100;
    sgstAmt = (amount * halfGst) / 100;

  } else {

    print("❌ DIFFERENT STATE");

    item.igstPer.text = gstPer.toStringAsFixed(2);
    item.cgstPer.text = "0";
    item.sgstPer.text = "0";

    igstAmt = (amount * gstPer) / 100;
  }

  item.cgstAmt.text = cgstAmt.toStringAsFixed(2);
  item.sgstAmt.text = sgstAmt.toStringAsFixed(2);
  item.igstAmt.text = igstAmt.toStringAsFixed(2);

  double net = amount + cgstAmt + sgstAmt + igstAmt;

  item.netAmt.text = net.toStringAsFixed(2);
}

  //  INVENTORY TABLE
  Widget buildInventoryTable() {
  return Column(
    children: [

      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minWidth: MediaQuery.of(context).size.width),

          child: Table(
            border: TableBorder.all(),

           columnWidths: const {
  0: FixedColumnWidth(80), 
  1: FixedColumnWidth(40), 
  2: FixedColumnWidth(60), 
  3: FixedColumnWidth(60),
  4: FixedColumnWidth(60),
  5: FixedColumnWidth(50),
  6: FixedColumnWidth(50),
  7: FixedColumnWidth(50),
  8: FixedColumnWidth(50),
  9: FixedColumnWidth(50),
  10: FixedColumnWidth(50),
  11: FixedColumnWidth(50),
  12: FixedColumnWidth(50),
  13: FixedColumnWidth(50),
  14: FixedColumnWidth(50),
  15: FixedColumnWidth(50),
  16: FixedColumnWidth(50),
},

            children: [

              //  TITLE NAME
              TableRow(
                decoration: BoxDecoration(color: Colors.orange[200]),
                
                children: const [
  Center(child: Text("Item ID")),
  Center(child: Text("Part No")),
  Center(child: Text("Product Name")),
  Center(child: Text("Act Qty")),
  Center(child: Text("Bill Qty")),
  Center(child: Text("Rate")),
  Center(child: Text("Disc")),
  Center(child: Text("Amount")),
  Center(child: Text("HSN")),
  Center(child: Text("GST%")),
  Center(child: Text("CGST%")),
  Center(child: Text("SGST%")),
  Center(child: Text("IGST%")),
  Center(child: Text("CGST Amt")),
  Center(child: Text("SGST Amt")),
  Center(child: Text("IGST Amt")),
  Center(child: Text("Net")),
],
              ),

              //  MULTIPLE ROWS
              ...items.map((item) {
                return TableRow(
  children: [
    itemDropdownCell(item),

    cell(item.partNo, item),
    cell(item.productName, item),
    cell(item.actualQty, item),
    cell(item.billedQty, item),
    cell(item.rate, item),
    cell(item.discount, item),
    cell(item.amount, item),
    cell(item.hsnCode, item),
    cell(item.gst, item),
    cell(item.cgstPer, item),
    cell(item.sgstPer, item),
    cell(item.igstPer, item),
    cell(item.cgstAmt, item),
    cell(item.sgstAmt, item),
    cell(item.igstAmt, item),
    cell(item.netAmt, item),
  ],
);
              }).toList(),
            ],
          ),
        ),
      ),

      SizedBox(height: 10),

      //  ADD ROW BUTTON
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              items.add(InvoiceItemController()); 
            });
          },
          child: Text("+ Add Row"),
        ),
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Invoice")),
      backgroundColor: (const Color.fromARGB(255, 247, 239, 239)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),

        child: Form(
          key: _formKey,
          child: Column(
            children: [

              //  HEADER TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Header", style: TextStyle(fontSize: 18)),
                  IconButton(
                    icon: Icon(showHeader
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                    onPressed: () {
                      setState(() {
                        showHeader = !showHeader;
                      });
                    },
                  )
                ],
              ),

              if (showHeader) ...[

                Row(children: [
               

                             Expanded(
  child: Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: DropdownButtonFormField<String>(

      value: companies.any((c) =>
              c["company_id"].toString() == selectedCompanyId)
          ? selectedCompanyId
          : null,

      decoration: InputDecoration(
        labelText: "Company ID",
        border: OutlineInputBorder(),
      ),

      items: companies.map<DropdownMenuItem<String>>((c) {
        return DropdownMenuItem<String>(
          value: c["company_id"].toString(),
          child: Text(c["company_id"].toString()),
        );
      }).toList(),

      onChanged: (value) async {
        setState(() {
          selectedCompanyId = value;
          companyId.text = value ?? "";

          var selectedCompany = companies.firstWhere(
            (c) => c["company_id"].toString() == value,
          );

          companyStateFromDB = selectedCompany["state"];

          filteredDealers = dealers.where((d) {
            return d["company_id"].toString() == value.toString();
          }).toList();

          filteredItems = itemMasters.where((i) {
            return i["company_id"].toString() == value.toString();
          }).toList();

          dealerId.clear();
          buyingName.clear();

          //  RESET LIST NAME WHEN COMPANY CHANGE
          
          priceLists = [];
        });

        //  DROPDOWN
        await getNextInvoiceNumber(value!);
        await fetchPriceList(value);
      },
    ),
  ),
),



                   //  Invoice No
    Expanded(
      child: Padding(
        padding: EdgeInsets.all(4),
        child:TextFormField(
  controller: invoiceNo,
  readOnly: true, 
  enabled: selectedCompanyId != null,
  decoration: InputDecoration(
    labelText: "Invoice No",
    border: OutlineInputBorder(),
  ),
)
      ),
    ),

    SizedBox(width: 10),

    //  Date Picker
    Expanded(
      child: Padding(
        padding: EdgeInsets.all(4),
        child: TextFormField(
          controller: invoiceDate,
          readOnly: true, 
          onTap: pickDate,
          enabled: selectedCompanyId != null,
          decoration: InputDecoration(
            labelText: "Date",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    ),
                 

              //  LIST NAME DROPDOWN
Expanded(
  child: Padding(
    padding: EdgeInsets.all(4),
    child: DropdownButtonFormField<String>(
  value: priceLists.any((p) => p["list_name"] == selectedListName)
      ? selectedListName
      : null,

  hint: Text("Select List Name"),

  items: priceLists.map<DropdownMenuItem<String>>((p) {
    return DropdownMenuItem(
      value: p["list_name"].toString(),
      child: Text(p["list_name"].toString()),
    );
  }).toList(),

onChanged: (val) async {
  setState(() {
    selectedListName = val;
    
  });

  if (val != null && selectedCompanyId != null) {
    await fetchItemsByList(selectedCompanyId!, val);
   
  }
}
),
  ),
),

                   //  DROPDOWN OR TEXTFIELD SWITCH
                 Expanded(
  child: Autocomplete<Map<String, dynamic>>(

    optionsBuilder: (TextEditingValue textEditingValue) {

      //  USE FILTERED DEALERS
      final list = filteredDealers;

      if (textEditingValue.text.isEmpty) {
        return list;
      }

      return list.where((d) {
        return d["dealer_id"]
            .toString()
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()) ||
            d["dealer_name"]
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase());
      });
    },

    displayStringForOption: (option) =>
        option["dealer_id"].toString(),

    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
      return TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: selectedCompanyId != null,
        decoration: InputDecoration(
          labelText: "Dealer ID",
          border: OutlineInputBorder(),
        ),
      );
    },

    onSelected: (selection) {

      dealerId.text = selection["dealer_id"].toString();

      //  AUTO FILL
      buyingName.text = selection["dealer_name"] ?? "";
      buyingAddress1.text = selection["address1"] ?? "";
      buyingAddress2.text = selection["address2"] ?? "";
      buyingAddress3.text = selection["address3"] ?? "";
      buyingDistrict.text = selection["district"] ?? "";
      buyingCity.text = selection["city"] ?? "";
      buyingState.text = selection["state"] ?? "";
      buyingPincode.text = selection["pincode"] ?? "";

      copyBuyingToDelivery();
    },
  ),
),


                  buildField("Name", buyingName),
                ]),

                Row(children: [
                  buildField("Addr1", buyingAddress1),
                  buildField("Addr2", buyingAddress2),
                  buildField("Addr3", buyingAddress3),
                  buildField("District", buyingDistrict),
                ]),

                Row(children: [
                  buildField("City", buyingCity),
                  buildField("Buying State", buyingState),
                  buildField("Pincode", buyingPincode),
                  buildField("Supply", placeOfSupply),
                ]),

                const SizedBox(height: 10),

               const Text(
  "Delivery",
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),


// 🔹 Row 1
Row(children: [
  buildField("Delivery Name", deliveryName),
  buildField("Del Addr1", deliveryAddress1),
  buildField("Del Addr2", deliveryAddress2),
  buildField("Del Addr3", deliveryAddress3),
  buildField("District", deliveryDistrict),
]),

// 🔹 Row 2
Row(children: [
   buildField("District", deliveryDistrict),
  buildField("City", deliveryCity),
  buildField("Delivery State", deliveryState),
  buildField("Pincode", deliveryPincode),
 
              ]),
              ],
              
              const SizedBox(height: 20),
              
              //  INVENTORY
             Center(
  child: const Text(
    "Inventory Items",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
),

              buildInventoryTable(),

              const SizedBox(height: 20),

              //  OTHER
              Row(children: [
               buildFieldWithCalc("Discount", otherDiscount),
               buildFieldWithCalc("Freight", freight),
                Align(
  alignment: Alignment.centerRight,
  child: Container(
    width: 250,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.yellow[300], 
      border: Border.all(color: Colors.black),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Grand Total",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          calculateGrandTotal().toStringAsFixed(2),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  ),
),
              ]),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveInvoice,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}