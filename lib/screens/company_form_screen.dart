import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/company_model.dart';
import 'package:flutter/services.dart';

class CompanyFormScreen extends StatefulWidget {

  final Company? company; 
  const CompanyFormScreen({super.key,this.company});

  @override
  CompanyFormScreenState createState() => CompanyFormScreenState();
}

class CompanyFormScreenState extends State<CompanyFormScreen> {

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final companyId = TextEditingController();
  final companyName = TextEditingController();
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final address3 = TextEditingController();
  final district = TextEditingController();
  final city = TextEditingController();
  final pincode = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  final gstin = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final website = TextEditingController();

   @override
void initState() {
  super.initState();

  if (widget.company != null) {
    companyId.text = widget.company!.companyId;
    companyName.text = widget.company!.companyName;
    address1.text = widget.company!.address1;
    address2.text = widget.company!.address2;
    address3.text = widget.company!.address3;
    district.text = widget.company!.district;
    city.text = widget.company!.city;
    pincode.text = widget.company!.pincode;
    state.text = widget.company!.state;
    country.text = widget.company!.country;
    gstin.text = widget.company!.gstin;
    mobile.text = widget.company!.mobile;
    email.text = widget.company!.email;
    website.text = widget.company!.website;
  }
}

  //  ADD API
  Future<void> addCompany() async {

    var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=add");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "company_id": companyId.text,
        "company_name": companyName.text,
        "address1": address1.text,
        "address2": address2.text,
        "address3": address3.text,
        "district": district.text,
        "city": city.text,
        "pincode": pincode.text,
        "state": state.text,
        "country": country.text,
        "gstin": gstin.text,
        "mobile": mobile.text,
        "email": email.text,
        "website": website.text,
      }),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Company Saved Successfully")),
      );

      Navigator.pop(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Saving Company")),
      );
    }
  }

  //  UPDATE API
  Future<void> updateCompany(int id) async {

    var url = Uri.parse(
        "http://192.168.0.4/erp_api/company_api.php?task=update");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "company_id": companyId.text,
        "company_name": companyName.text,
        "address1": address1.text,
        "address2": address2.text,
        "address3": address3.text,
        "district": district.text,
        "city": city.text,
        "pincode": pincode.text,
        "state": state.text,
        "country": country.text,
        "gstin": gstin.text,
        "mobile": mobile.text,
        "email": email.text,
        "website": website.text,
      }),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "updated") {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Company Updated Successfully")),
      );

      Navigator.pop(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update Failed")),
      );
    }
  }

  // 🔹 FIELD WIDGET
Widget buildField(
  String label,
  TextEditingController controller, {
  TextInputType type = TextInputType.text,
  bool isLowerCase = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: type,

      onChanged: (value) {

        
        if (isLowerCase) {
          controller.value = TextEditingValue(
            text: value.toLowerCase(),
            selection: TextSelection.collapsed(offset: value.length),
          );
        }

        else {
          controller.value = TextEditingValue(
            text: value
                .split(" ")
                .map((word) => word.isEmpty
                    ? ""
                    : word[0].toUpperCase() + word.substring(1))
                .join(" "),
            selection: TextSelection.collapsed(offset: value.length),
          );
        }
      },

      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
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

    bool isEdit = widget.company != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Company" : "Add Company"),
        backgroundColor:  Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),

        child: Form(
          key: _formKey,
          child: Column(
            children: [

              buildField("Company ID", companyId),
              buildField("Company Name", companyName),

              buildField("Address 1", address1),
              buildField("Address 2", address2),
              buildField("Address 3", address3),

              buildField("District", district),
              buildField("City", city),

              buildField("Pincode", pincode, type: TextInputType.number),

              buildField("State", state),
              buildField("Country", country),

             Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: TextFormField(
    controller: gstin,

    maxLength: 15, 

    textCapitalization: TextCapitalization.characters,

    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), 
      LengthLimitingTextInputFormatter(15), 
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
              buildField("Mobile No", mobile, type: TextInputType.phone),
    buildField(
  "Email ID",
  email,
  type: TextInputType.emailAddress,
  isLowerCase: true,
),

buildField(
  "Website",
  website,
  type: TextInputType.url,
  isLowerCase: true,
),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {

                    if (isEdit) {
                      updateCompany(widget.company!.id); 
                    } else {
                      addCompany(); 
                    }
                  }
                },
                child: Text(isEdit ? "Update Company" : "Save Company"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}