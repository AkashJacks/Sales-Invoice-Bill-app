import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/dealer_model.dart';
import 'package:flutter/services.dart';

class DealerFormScreen extends StatefulWidget {

  final Dealer? dealer;
    const DealerFormScreen({super.key, this.dealer});


  @override
  DealerFormScreenState createState() => DealerFormScreenState();
}

class DealerFormScreenState extends State<DealerFormScreen> {

  final _formKey = GlobalKey<FormState>();

  List companies = [];
String? selectedCompanyId;

  final companyId = TextEditingController();
  final dealerId = TextEditingController();
  final dealerName = TextEditingController();
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final address3 = TextEditingController();
  final district = TextEditingController();
  final city = TextEditingController();
  final pincode = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  final gstin = TextEditingController();
  final salesman = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final website = TextEditingController();
  final openingBal = TextEditingController();

  @override
void initState() {
  super.initState();
    fetchCompanies();


  if (widget.dealer != null) {

    selectedCompanyId = widget.dealer!.companyRefId.toString();
    dealerId.text = widget.dealer!.dealerId;
    dealerName.text = widget.dealer!.dealerName;

    address1.text = widget.dealer!.address1;
    address2.text = widget.dealer!.address2;
    address3.text = widget.dealer!.address3;

    district.text = widget.dealer!.district;
    city.text = widget.dealer!.city;

    pincode.text = widget.dealer!.pincode;
    state.text = widget.dealer!.state;
    country.text = widget.dealer!.country;

    gstin.text = widget.dealer!.gstin;
    salesman.text = widget.dealer!.salesman;

    mobile.text = widget.dealer!.mobile;
    email.text = widget.dealer!.email;
    website.text = widget.dealer!.website;

    openingBal.text = widget.dealer!.openingBal;
  }
}

Future<void> fetchCompanies() async {

  var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get");

  var response = await http.get(url);

  var data = jsonDecode(response.body);

  setState(() {
    companies = data;
  });
}

 Future<void> addDealer() async {

  //  BASIC VALIDATION
  if (selectedCompanyId == null || dealerName.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Company & Dealer Name required")),
    );
    return;
  }

  var url = Uri.parse(
      "http://192.168.0.4/erp_api/dealer_api.php?task=add");

  try {

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "company_id": companyId.text,        
        "company_ref_id": selectedCompanyId, 
        "dealer_id": dealerId.text,
        "dealer_name": dealerName.text,
        "address1": address1.text,
        "address2": address2.text,
        "address3": address3.text,
        "district": district.text,
        "city": city.text,
        "pincode": pincode.text,
        "state": state.text,
        "country": country.text,
        "gstin": gstin.text,
        "salesman": salesman.text,
        "mobile": mobile.text,
        "email": email.text,
        "website": website.text,
        "opening_bal": openingBal.text,
      }),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dealer Added Successfully")),
      );

      Navigator.pop(context, true); 

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Add Failed")),
      );

    }

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );

  }
}

Future<void> updateDealer(int id) async {

  var url = Uri.parse(
      "http://192.168.0.4/erp_api/dealer_api.php?task=update");

  try {

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "company_id": companyId.text,        // display
        "company_ref_id": selectedCompanyId, // real FK
        "dealer_id": dealerId.text,
        "dealer_name": dealerName.text,
        "address1": address1.text,
        "address2": address2.text,
        "address3": address3.text,
        "district": district.text,
        "city": city.text,
        "pincode": pincode.text,
        "state": state.text,
        "country": country.text,
        "gstin": gstin.text,
        "salesman": salesman.text,
        "mobile": mobile.text,
        "email": email.text,
        "website": website.text,
        "opening_bal": openingBal.text,
      }),
    );

    var data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["status"] == "updated") {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dealer Updated Successfully")),
      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Update Failed")),
      );

    }

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
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
    bool isEdit = widget.dealer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Dealer":"Add Dealer")),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

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
  });
}
  ),
),
              field("Dealer ID", dealerId),
              field("Dealer Name", dealerName),

              field("Address1", address1),
              field("Address2", address2),
              field("Address3", address3),

              field("District", district),
              field("City", city),

              field("Pincode", pincode),
              field("State", state),
              field("Country", country),

              Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: TextFormField(
    controller: gstin,

    maxLength: 15, //  LIMIT SET

    textCapitalization: TextCapitalization.characters,

    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), //  only valid chars
      LengthLimitingTextInputFormatter(15), //  HARD LIMIT
    ],

    onChanged: (value) {
      gstin.value = TextEditingValue(
        text: value.toUpperCase(),
        selection: TextSelection.collapsed(offset: value.length),
      );
    },

    decoration: InputDecoration(
      labelText: "GSTIN",
      border: OutlineInputBorder(),
      counterText: "", 
    ),

    validator: (value) {
      if (value == null || value.isEmpty) {
        return "GSTIN is required";
      }

      if (value.length != 15) {
        return "GSTIN must be 15 characters";
      }

      return null;
    },
  ),
),
              field("Salesman", salesman),

              field("Mobile", mobile),
              field("Email", email),
              field("Website", website),

              field("Opening Balance", openingBal),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (widget.dealer == null) {
  addDealer();
} else {
  updateDealer(widget.dealer!.id);
}

                },
                child: Text("Save Dealer"),
              )

            ],
          ),
        ),
      ),
    );
  }
}