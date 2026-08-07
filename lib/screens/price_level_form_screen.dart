import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/price_level_model.dart';

class PriceLevelFormScreen extends StatefulWidget {

final PriceLevel? price;
const PriceLevelFormScreen({super.key, this.price});

  @override
  PriceLevelFormScreenState createState() => PriceLevelFormScreenState();
}

class PriceLevelFormScreenState extends State<PriceLevelFormScreen> {

  final _formKey = GlobalKey<FormState>();

  List companies = [];
  String? selectedCompanyId;
  String? selectedListId;
String? selectedListName;

  final companyRefId= TextEditingController();
  final companyId = TextEditingController();
  final listName = TextEditingController();

  @override
void initState() {
  super.initState();
  fetchCompanies();

 if (widget.price != null) {
  selectedCompanyId = widget.price!.companyRefId.toString();
  companyId.text = widget.price!.companyId;
  listName.text = widget.price!.listName;
}
}

  //  FETCH COMPANY
  Future<void> fetchCompanies() async {

    var url = Uri.parse("http://192.168.0.10/erp_api/company_api.php?task=get");

    var response = await http.get(url);

    var data = jsonDecode(response.body);

    setState(() {
      companies = data;
    });
  }

  //  ADD PRICE LEVEL
  Future<void> addPriceLevel() async {

    if (selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Select Company")),
      );
      return;
    }

    var url = Uri.parse("http://192.168.0.10/erp_api/price_level_api.php?task=add");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
       "company_id": companyId.text,
      "company_ref_id": selectedCompanyId,
        "list_name": listName.text,
      }),
    );

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      Navigator.pop(context, true);
    }
  }

  Future<void> updatePriceLevel(int id) async {

  var url = Uri.parse(
      "http://192.168.0.10/erp_api/price_level_api.php?task=update");

  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "id": id,
      "company_id": companyId.text,
      "company_ref_id": selectedCompanyId,
      "list_name": listName.text,
    }),
  );

  var data = jsonDecode(response.body);

  if (data["status"] == "updated") {
    Navigator.pop(context, true);
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Price Level"),
      ),

      body: Padding(
        padding: EdgeInsets.all(15),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              //  COMPANY DROPDOWN
              DropdownButtonFormField<String>(

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

    //  get full company object
    var selectedCompany = companies.firstWhere(
      (c) => c["id"].toString() == value,
    );

    //  IMPORTANT
    companyId.text = selectedCompany["company_id"]; // display value

  });
},
              ),

              SizedBox(height: 15),

              //  LIST NAME
              TextFormField(
                controller: listName,
                 onChanged: (value) {
                 listName.value = TextEditingValue(
          text: value
              .split(" ")
              .map((word) =>
                  word.isEmpty ? "" : word[0].toUpperCase() + word.substring(1))
              .join(" "),
          selection: TextSelection.collapsed(offset: value.length),
        );
      },
                decoration: InputDecoration(
                  labelText: "List Name",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
  if (widget.price == null) {
    addPriceLevel();
  } else {
    updatePriceLevel(widget.price!.id);
  }
},
                child: Text("Save"),
              )

            ],
          ),
        ),
      ),
    );
  }
}