import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import 'package:flutter/services.dart';


class ItemFormScreen extends StatefulWidget {
  final Item? item;

 const ItemFormScreen({super.key, this.item});

  @override
  ItemFormScreenState createState() => ItemFormScreenState();
}

class ItemFormScreenState extends State<ItemFormScreen> {

  final _formKey = GlobalKey<FormState>();

 
  List companies = [];
  String? selectedCompanyId;

 
   
  final companyId = TextEditingController();
  final itemId = TextEditingController();
  final partNo = TextEditingController();
  final description = TextEditingController();
  final unit = TextEditingController();
  final altUnit = TextEditingController();
  final conversion = TextEditingController();
  final dominator = TextEditingController();
  final hsnCode = TextEditingController();
  final gstPer = TextEditingController();
  final openingStk = TextEditingController();
  final openingRate = TextEditingController();
  final openingBal = TextEditingController();

   @override
void initState() {
  super.initState();

  fetchCompanies();

   
  if (widget.item != null) {

    selectedCompanyId = widget.item!.companyRefId.toString();
    companyId.text = widget.item!.companyId;

    itemId.text = widget.item!.itemId;
    partNo.text = widget.item!.partNo;
    description.text = widget.item!.description;
    unit.text = widget.item!.unit;
    altUnit.text = widget.item!.altUnit;
    conversion.text = widget.item!.conversion;
    dominator.text = widget.item!.dominator;
    hsnCode.text = widget.item!.hsnCode;
    gstPer.text = widget.item!.gstPer;
    openingStk.text = widget.item!.openingStk;
    openingRate.text = widget.item!.openingRate;
    calculateOpeningBalance();
  }
}

  //  FETCH COMPANIES
  Future<void> fetchCompanies() async {
  var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get");

  var response = await http.get(url);
  var data = jsonDecode(response.body);

  setState(() {
    companies = data;

    //  safe assign
    if (widget.item != null) {
      selectedCompanyId = widget.item!.companyId;
    }
  });
}
// CALCULATION
void calculateOpeningBalance() {
  double stk = double.tryParse(openingStk.text) ?? 0;
  double rate = double.tryParse(openingRate.text) ?? 0;

  double total = stk * rate;

  openingBal.text = total.toStringAsFixed(2); 
}


  //  ADD
Future<void> addItem() async {

  //  VALIDATION
  if (selectedCompanyId == null || selectedCompanyId!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Select Company ID")),
    );
    return;
  }

  if (description.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Enter Description")),
    );
    return;
  }

  try {

    var url = Uri.parse("http://192.168.0.4/erp_api/item_api.php?task=add");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
         "company_id": companyId.text,             
       "company_ref_id": selectedCompanyId,
        "item_id": itemId.text,
        "part_no": partNo.text,
        "description": description.text.trim(),
        "unit": unit.text,
        "alt_unit": altUnit.text,
        "conversion": conversion.text,
        "dominator": dominator.text,
        "hsn_code": hsnCode.text,
        "gst_per": gstPer.text,
        "opening_stk": openingStk.text,
        "opening_rate": openingRate.text,
        "opening_bal": openingBal.text,
      }),
    );

    //  DEBUG RESPONSE
    print("RESPONSE: ${response.body}");

    //  SAFE JSON PARSE
    if (response.body.startsWith("<")) {
      throw Exception("Server returned HTML (PHP Error)");
    }

    var data = jsonDecode(response.body);

    //  HANDLE RESPONSE
    if (data["status"] == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item Saved Successfully")),
      );

      Navigator.pop(context, true);

    } else if (data["status"] == "exists") {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Description already exists")),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data["error"] ?? "Unknown"}")),
      );
    }

  } catch (e) {

    print("ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Server Error - Check API")),
    );
  }
}

// UPDATE CODE
 Future<void> updateItem(int id) async {

  //  VALIDATION
  if (selectedCompanyId == null || selectedCompanyId!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Select Company ID")),
    );
    return;
  }

  if (description.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Enter Description")),
    );
    return;
  }

  var url = Uri.parse(
      "http://192.168.0.4/erp_api/item_api.php?task=update");

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "id": id,
       "company_id": companyId.text,             
       "company_ref_id": selectedCompanyId,
      "item_id": itemId.text,
      "part_no": partNo.text,
      "description": description.text.trim(), 
      "unit": unit.text,
      "alt_unit": altUnit.text,
      "conversion": conversion.text,
      "dominator": dominator.text,
      "hsn_code": hsnCode.text,
      "gst_per": gstPer.text,
      "opening_stk": openingStk.text,
      "opening_rate": openingRate.text,
      "opening_bal": openingBal.text,
    }),
  );

  var data = jsonDecode(response.body);

  //  HANDLE RESPONSE
  if (data["status"] == "updated") {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Item Updated Successfully")),
    );

    Navigator.pop(context);

  } else if (data["status"] == "exists") {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Description already exists")),
    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Update Failed")),
    );
  }
}

  Widget field(String label, TextEditingController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: c,
         onChanged: (value) {
        c.value = TextEditingValue(
          text: value
              .split(" ")
              .map((word) =>
                  word.isEmpty ? "" : word[0].toUpperCase() + word.substring(1))
              .join(" "),
          selection: TextSelection.collapsed(offset: value.length),
        );
      },
      
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Item" : "Add Item"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              //  DROPDOWN FIXED
                Padding(
  padding: EdgeInsets.only(bottom: 10),
  child: DropdownButtonFormField<String>(
      value: companies.any((c) => c["id"].toString() == selectedCompanyId)
    ? selectedCompanyId
    : null,

    decoration: InputDecoration(
      labelText: "Company ID",
      border: OutlineInputBorder(),
    ),

    items: companies.map<DropdownMenuItem<String>>((c) {
      return DropdownMenuItem<String>(
        value: c["id"].toString(),
        child: Text(c["company_id"]), 
      );
    }).toList(),

    onChanged: (value) {
      setState(() {
        selectedCompanyId = value;

        //  GET FULL OBJECT
        var selectedCompany = companies.firstWhere(
          (c) => c["id"].toString() == value,
        );

        //  DISPLAY VALUE SET
        companyId.text = selectedCompany["company_id"];
      });
    },
  ),
),

              field("Item ID", itemId),
              field("Part No", partNo),
              field("Description", description),

              field("Unit", unit),
              field("Alt Unit", altUnit),
              field("Conversion", conversion),
              field("Dominator", dominator),

              field("HSN Code", hsnCode),

              Padding(
  padding: EdgeInsets.all(4),
  child: TextFormField(
    controller: gstPer,

    keyboardType: TextInputType.number,

    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
    ],

    decoration: InputDecoration(
      labelText: "GST %",
      border: OutlineInputBorder(),
    ),
  ),
),

              Padding(
  padding: EdgeInsets.only(bottom: 10),
  child: TextFormField(
    controller: openingStk,
    keyboardType: TextInputType.number,
    onChanged: (value) {
      calculateOpeningBalance(); 
    },
    decoration: InputDecoration(
      labelText: "Opening Stock",
      border: OutlineInputBorder(),
    ),
  ),
),
              
              Padding(
  padding: EdgeInsets.only(bottom: 10),
  child: TextFormField(
    controller: openingRate,
    keyboardType: TextInputType.number,
    onChanged: (value) {
      calculateOpeningBalance(); 
    },
    decoration: InputDecoration(
      labelText: "Opening Rate",
      border: OutlineInputBorder(),
    ),
  ),
),
             
             Padding(
  padding: EdgeInsets.only(bottom: 10),
  child: TextFormField(
    controller: openingBal,
    readOnly: true,
    decoration: InputDecoration(
      labelText: "Opening Balance",
      border: OutlineInputBorder(),
    ),
  ),
),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (widget.item == null) {
                    addItem();
                  } else {
                    updateItem(widget.item!.id);
                  }
                },
                child: Text("Save Item"),
              )
            ],
          ),
        ),
      ),
    );
  }
}