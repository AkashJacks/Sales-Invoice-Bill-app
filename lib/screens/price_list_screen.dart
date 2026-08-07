import 'package:flutter/material.dart';
import 'price_list_form_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price_list_model.dart';

class PriceListScreen extends StatefulWidget {
   const PriceListScreen({super.key});
   
  @override
  PriceListScreenState createState() => PriceListScreenState();
}

class PriceListScreenState extends State<PriceListScreen> {

  List<PriceList> allPriceList = [];
  List<PriceList> filteredPriceList = [];

  List companies = [];
  String? selectedCompanyFilter;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  //  LOAD DATA
  Future<void> loadData() async {
    await fetchPriceList();
    await fetchCompanies();
  }

  //  FETCH PRICE LIST
  Future<void> fetchPriceList() async {
    var url = Uri.parse("http://192.168.0.4/erp_api/price_list_api.php?task=get");

    var response = await http.get(url);

    List data = jsonDecode(response.body);

    allPriceList = data.map((e) => PriceList.fromJson(e)).toList();
    filteredPriceList = allPriceList;

    setState(() {
      isLoading = false;
    });
  }

  //  FETCH COMPANIES
  Future<void> fetchCompanies() async {
    var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get");

    var response = await http.get(url);

    setState(() {
      companies = jsonDecode(response.body);
    });
  }

  //  FILTER
  void applyFilter(String? companyId) {
    if (companyId == null || companyId.isEmpty) {
      filteredPriceList = allPriceList;
    } else {
      filteredPriceList = allPriceList
          .where((p) => p.companyId == companyId)
          .toList();
    }

    setState(() {});
  }

  //  DELETE
  Future<void> deletePriceList(int id) async {
    var url = Uri.parse(
        "http://192.168.0.4/erp_api/price_list_api.php?task=delete&id=$id");

    await http.get(url);
  }

  //  CONFIRM DELETE
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await deletePriceList(id);
              Navigator.pop(context);

              await fetchPriceList();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  //  FILTER POPUP
  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {

        String? tempValue = selectedCompanyFilter;

        return AlertDialog(
          title: Text("Filter by Company"),

          content: DropdownButtonFormField<String>(
            value: tempValue,
            hint: Text("Select Company"),
            items: companies.map<DropdownMenuItem<String>>((c) {
              return DropdownMenuItem(
                value: c["company_id"],
                child: Text(c["company_id"]),
              );
            }).toList(),
            onChanged: (value) {
              tempValue = value;
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                selectedCompanyFilter = tempValue;
                applyFilter(selectedCompanyFilter);
                Navigator.pop(context);
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Price List"),
        actions: [

          // ➕ ADD
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {

              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PriceListFormScreen(),
                ),
              );

              if (result == true) {
                await fetchPriceList();
              }
            },
          ),

          // 🔍 FILTER
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: showFilterDialog,
          ),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredPriceList.isEmpty
              ? Center(child: Text("No Data Found"))
              : ListView.builder(
                  itemCount: filteredPriceList.length,
                  itemBuilder: (context, index) {

                    var p = filteredPriceList[index];

                    return Card(
                      child: ListTile(
                        title: Text("Company: ${p.companyId}"),
                        subtitle: Text("${p.listName} | ${p.productName} | ₹${p.rate}"),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // ✏️ EDIT
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {

                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PriceListFormScreen(price: p),
                                  ),
                                );

                                if (result == true) {
                                  await fetchPriceList();
                                }
                              },
                            ),

                            // 🗑 DELETE
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                confirmDelete(p.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}