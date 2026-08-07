import 'package:flutter/material.dart';
import 'price_level_form_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price_level_model.dart';

class PriceLevelScreen extends StatefulWidget {
  const PriceLevelScreen({super.key});
  
  @override
  PriceLevelScreenState createState() => PriceLevelScreenState();
}

class PriceLevelScreenState extends State<PriceLevelScreen> {

  List<PriceLevel> allPriceList = [];
  List<PriceLevel> filteredPriceList = [];

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
    await fetchPriceLevels();
    await fetchCompanies();
  }

  //  FETCH PRICE LEVEL
  Future<void> fetchPriceLevels() async {
    var url = Uri.parse("http://192.168.0.4/erp_api/price_level_api.php?task=get");

    var response = await http.get(url);

    List data = jsonDecode(response.body);

    allPriceList = data.map((e) => PriceLevel.fromJson(e)).toList();
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
  Future<void> deletePriceLevel(int id) async {
    var url = Uri.parse(
        "http://192.168.0.4/erp_api/price_level_api.php?task=delete&id=$id");

    await http.get(url);
  }

  //  CONFIRM DELETE
  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Delete this Price Level?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await deletePriceLevel(id);
              Navigator.pop(context);

              await fetchPriceLevels();
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
              onPressed: () {
                Navigator.pop(context);
              },
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
        title: Text("Price Level"),
        actions: [

          // ➕ ADD
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PriceLevelFormScreen(),
                ),
              );

              if (result == true) {
                await fetchPriceLevels();
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
                        subtitle: Text(p.listName),

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
                                        PriceLevelFormScreen(price: p),
                                  ),
                                );

                                if (result == true) {
                                  await fetchPriceLevels();
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