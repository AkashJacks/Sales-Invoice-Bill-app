import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class SalesRegisterScreen extends StatefulWidget {
  const SalesRegisterScreen({super.key});

  @override
  State<SalesRegisterScreen> createState() => _SalesRegisterScreenState();
}

//  DATE FORMATTER (DD/MM/YYYY)
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // max 8 digits (DDMMYYYY)
    if (digits.length > 8) {
      return oldValue;
    }

    String formatted = '';

    if (digits.length >= 1) {
      formatted += digits.substring(0, digits.length >= 2 ? 2 : digits.length);
    }
    if (digits.length >= 3) {
      formatted += '/' + digits.substring(2, digits.length >= 4 ? 4 : digits.length);
    }
    if (digits.length >= 5) {
      formatted += '/' + digits.substring(4, digits.length);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _SalesRegisterScreenState extends State<SalesRegisterScreen> {
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();

  List<Map<String, dynamic>> companies = [];
  String? selectedCompanyId;

  List salesList = [];

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  //  FETCH COMPANIES
  Future<void> fetchCompanies() async {
    var url = Uri.parse(
        "http://192.168.0.4/erp_api/company_api.php?task=get");

    var res = await http.get(url);

    var decoded = jsonDecode(res.body);

    setState(() {
      companies = List<Map<String, dynamic>>.from(decoded);
    });
  }

  // CONVERT DATE TO API FORMAT
  String convertToApiDate(String input) {
    try {
      var parts = input.split('/');
      return "${parts[2]}-${parts[1]}-${parts[0]}";
    } catch (e) {
      return "";
    }
  }


  String formatDate(String date) {
  try {
    DateTime dt = DateTime.parse(date); 
    return "${dt.day}/${dt.month}/${dt.year}";
  } catch (e) {
    return date;
  }
}

  //  FETCH SALES
  Future<void> fetchSalesData() async {
    if (selectedCompanyId == null ||
        fromDate.text.isEmpty ||
        toDate.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fill all filters")),
      );
      return;
    }

    var from = convertToApiDate(fromDate.text);
    var to = convertToApiDate(toDate.text);

    var url = Uri.parse(
        "http://192.168.0.4/erp_api/sales_api.php?task=sales_register"
        "&company_id=$selectedCompanyId"
        "&from_date=$from"
        "&to_date=$to");

    print("URL: $url");

    var response = await http.get(url);

    var data = jsonDecode(response.body);

    if (data["status"] == "success") {
      setState(() {
        salesList = data["data"];
      });
    }
  }

  //  DATE FIELD
  Widget dateField(TextEditingController controller, String label) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          DateInputFormatter(),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: "DD/MM/YYYY",
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );

              if (picked != null) {
                controller.text =
                    "${picked.day.toString().padLeft(2, '0')}/"
                    "${picked.month.toString().padLeft(2, '0')}/"
                    "${picked.year}";
              }
            },
          ),
        ),
      ),
    );
  }

  //  FILTER UI
  Widget filterSection() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedCompanyId,
            hint: Text("Select Company"),
            items: companies.map((c) {
              return DropdownMenuItem<String>(
                value: c["company_id"].toString(),
                child: Text("${c["company_id"]}"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCompanyId = value;
              });
            },
          ),

          SizedBox(height: 10),

          Row(
            children: [
              dateField(fromDate, "From Date"),
              SizedBox(width: 10),
              dateField(toDate, "To Date"),
              SizedBox(width: 10),

              ElevatedButton(
                onPressed: fetchSalesData,
                child: Text("Search"),
              )
            ],
          ),
        ],
      ),
    );
  }

  //  TABLE
 Widget tableSection() {
  return 
     SingleChildScrollView(
      scrollDirection: Axis.vertical, 
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, 
        child: DataTable(
          columnSpacing: 150,
          headingRowHeight: 50,
          dataRowHeight: 50,
          columns: [
            DataColumn(label: Text("Invoice No")),
            DataColumn(label: Text("Invoice Date")),
            DataColumn(label: Text("Dealer ID")),
            DataColumn(label: Text("Buying Name")),
            DataColumn(label: Text("Grand Total")),
          ],
          rows: salesList.map<DataRow>((e) {
            return DataRow(cells: [
              DataCell(Text(e["invoice_no"].toString())),
              DataCell(
                  Text(
               formatDate(e["invoice_date"].toString()),
                ),
               ),
              DataCell(Text(e["dealer_id"].toString())),
              DataCell(Text(e["buying_name"].toString())),
              DataCell(
             Align(
             alignment: Alignment.centerRight,
             child:  Text(
             double.tryParse(e["grand_total"].toString()) != null
             ? double.parse(e["grand_total"].toString()).toStringAsFixed(2)
             : "0.00",
             ),
          ),
          ),
            ]);
          }).toList(),
        ),
      ),
    
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sales Register")),
      backgroundColor: (const Color.fromARGB(255, 184, 213, 166)),
      body: Column(
        children: [
          filterSection(),
          Expanded(child: tableSection()),
        ],
      ),
    );
  }
}












