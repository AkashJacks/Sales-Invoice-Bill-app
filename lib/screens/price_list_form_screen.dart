import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/price_list_model.dart';

class PriceListFormScreen extends StatefulWidget {
  final PriceList? price;

  const PriceListFormScreen({super.key, this.price});

  @override
  PriceListFormScreenState createState() => PriceListFormScreenState();
}

class PriceListFormScreenState extends State<PriceListFormScreen> {
  List companies = [];
  List priceLevels = [];
  List items = [];

  List filteredPriceLevels = [];
  List filteredItems = [];

  String? selectedCompanyId;
  String? selectedListName;
  String? selectedItemId; 

  final companyId = TextEditingController();
  final productName = TextEditingController();
  final rate = TextEditingController();
  final applyFrom = TextEditingController();
  final itemId = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchCompanies();
    await fetchPriceLevels();
    await fetchItems();

   if (widget.price != null) {
  setState(() {
    selectedCompanyId = widget.price!.companyRefId.toString();
    companyId.text = widget.price!.companyId;

    selectedListName = widget.price!.listName;
    applyFrom.text = widget.price!.applyFrom;
    rate.text = widget.price!.rate;

    selectedItemId = widget.price!.itemId.toString();
    itemId.text = selectedItemId ?? "";

  
    var itemData = items.firstWhere(
      (i) => i["item_id"].toString() == selectedItemId,
      orElse: () => {},
    );


    productName.text = itemData["description"]?.toString() ?? "";

        
        filteredPriceLevels = priceLevels.where((p) {
          return p["company_ref_id"].toString() ==
              selectedCompanyId.toString();
        }).toList();

        filteredItems = items.where((i) {
          return i["company_ref_id"].toString() ==
              selectedCompanyId.toString();
        }).toList();
      });
    }
  }

  Future<void> fetchCompanies() async {
    var res = await http.get(
        Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get"));

    companies = jsonDecode(res.body);
  }

  Future<void> fetchPriceLevels() async {
    var res = await http.get(
        Uri.parse("http://192.168.0.4/erp_api/price_level_api.php?task=get"));

    priceLevels = jsonDecode(res.body);
  }

  Future<void> fetchItems() async {
    var res = await http.get(
        Uri.parse("http://192.168.0.4/erp_api/item_api.php?task=get"));

    items = jsonDecode(res.body);
  }

  //  ADD
  Future<void> addPriceList() async {
    var parts = applyFrom.text.split('/');
    String dbDate = "${parts[2]}-${parts[1]}-${parts[0]}";

    var res = await http.post(
      Uri.parse("http://192.168.0.4/erp_api/price_list_api.php?task=add"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "company_id": companyId.text,
        "company_ref_id": selectedCompanyId,
        "list_name": selectedListName,
        "apply_from": dbDate,
        "product_name": productName.text,
        "rate": rate.text,
        "item_id": itemId.text,
      }),
    );

    var data = jsonDecode(res.body);

    if (data["status"] == "success") {
      Navigator.pop(context, true);
    }
  }

  Future<void> updatePriceList(int id) async {
    var res = await http.post(
      Uri.parse("http://192.168.0.4/erp_api/price_list_api.php?task=update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "company_id": companyId.text,
        "company_ref_id": selectedCompanyId,
        "list_name": selectedListName,
        "apply_from": applyFrom.text,
        "product_name": productName.text,
        "rate": rate.text,
        "item_id": itemId.text,
      }),
    );

    var data = jsonDecode(res.body);

    if (data["status"] == "updated") {
      Navigator.pop(context, true);
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      applyFrom.text =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Price List")),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [

            //  COMPANY
            DropdownButtonFormField<String>(
              value: selectedCompanyId,
              decoration: InputDecoration(
                labelText: "Company ID",
                border: OutlineInputBorder(),
              ),
              items: companies.map<DropdownMenuItem<String>>((c) {
                return DropdownMenuItem(
                  value: c["id"].toString(),
                  child: Text(c["company_id"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCompanyId = value;

                  var selectedCompany = companies.firstWhere(
                    (c) => c["id"].toString() == value,
                  );

                  companyId.text = selectedCompany["company_id"];

                  filteredPriceLevels = priceLevels.where((p) {
                    return p["company_ref_id"].toString() ==
                        selectedCompanyId.toString();
                  }).toList();

                  filteredItems = items.where((i) {
                    return i["company_ref_id"].toString() ==
                        selectedCompanyId.toString();
                  }).toList();

                  selectedListName = null;
                  selectedItemId = null;
                  productName.clear();
                  itemId.clear();
                });
              },
            ),

            SizedBox(height: 10),

            //  LIST NAME
            DropdownButtonFormField<String>(
              value: selectedListName,
              decoration: InputDecoration(
                labelText: "List Name",
                border: OutlineInputBorder(),
              ),
              items: filteredPriceLevels.map<DropdownMenuItem<String>>((p) {
                return DropdownMenuItem(
                  value: p["list_name"],
                  child: Text(p["list_name"]),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedListName = val;
                });
              },
            ),

            SizedBox(height: 10),
             
            //  DATE
            TextFormField(
              controller: applyFrom,
              readOnly: true,
              onTap: pickDate,
              decoration: InputDecoration(
                labelText: "Apply From",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            //  ITEM DROPDOWN (FIXED)
            DropdownButtonFormField<String>(
              value: filteredItems.any((i) =>
                      i["item_id"].toString() == selectedItemId)
                  ? selectedItemId
                  : null,
              decoration: InputDecoration(
                labelText: "Product",
                border: OutlineInputBorder(),
              ),
              items: filteredItems.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem(
                  value: item["item_id"].toString(),
                  child: Text(item["description"]),
                );
              }).toList(),
             onChanged: (val) {
  var selected = filteredItems.firstWhere(
    (i) => i["item_id"].toString() == val,
  );

  setState(() {
    selectedItemId = val;

    itemId.text = selected["item_id"].toString();

    productName.text = selected["description"] ?? "";
  });
}
            ),

            SizedBox(height: 10),

            //  RATE
            TextFormField(
              controller: rate,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Rate",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            TextFormField(
              controller: itemId,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Item ID",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (widget.price == null) {
                  addPriceList();
                } else {
                  updatePriceList(widget.price!.id);
                }
              },
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}