import 'package:flutter/material.dart';
import 'company_form_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/company_model.dart';

class CompanyMasterScreen extends StatefulWidget {
  const CompanyMasterScreen({super.key});
  
  @override
  CompanyMasterScreenState createState() => CompanyMasterScreenState();
}

class CompanyMasterScreenState extends State<CompanyMasterScreen> {

  late Future<List<Company>> companyList;

  String searchText = "";

  @override
  void initState() {
    super.initState();
    companyList = fetchCompanies();
  }

  //  FETCH
  Future<List<Company>> fetchCompanies() async {

    var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get");

    var response = await http.get(url);

    if (response.statusCode == 200) {

      if (response.body.startsWith("<")) {
        throw Exception("Server Error");
      }

      List data = jsonDecode(response.body);

      return data.map((e) => Company.fromJson(e)).toList();

    } else {
      throw Exception("Failed to load data");
    }
  }

  //  DELETE
  Future<void> deleteCompany(int id) async {

    var url = Uri.parse(
        "http://192.168.0.4/erp_api/company_api.php?task=delete&id=$id");

    var response = await http.get(url);

    var data = jsonDecode(response.body);

    if (data["status"] == "deleted") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Deleted Successfully")),
      );
    }
  }

  //  CONFIRM DELETE
  void confirmDelete(int id) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Delete this company?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await deleteCompany(id);
              Navigator.pop(context);

              setState(() {
                companyList = fetchCompanies();
              });
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  //  FILTER FUNCTION
  List<Company> applyFilter(List<Company> companies) {

    if (searchText.isEmpty) return companies;

    return companies.where((c) =>
        c.companyName.toLowerCase().contains(searchText.toLowerCase())
    ).toList();
  }

  //  FILTER DIALOG
  void openFilterDialog() {

    TextEditingController searchController =
        TextEditingController(text: searchText);

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text("Search Company"),

          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Enter company name",
              border: OutlineInputBorder(),
            ),
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
                setState(() {
                  searchText = searchController.text;
                });
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
        title: Text("Company Master"),
      
        actions: [

          // ➕ ADD
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyFormScreen(),
                ),
              );

              setState(() {
                companyList = fetchCompanies();
              });
            },
          ),

          // 🔍 FILTER
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: openFilterDialog,
          ),

        ],
      ),

      body: FutureBuilder<List<Company>>(
        future: companyList,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          var companies = snapshot.data!;

          //  APPLY FILTER
          var filteredCompanies = applyFilter(companies);

          if (filteredCompanies.isEmpty) {
            return Center(child: Text("No Data Found"));
          }

          return ListView.builder(
            itemCount: filteredCompanies.length,
            itemBuilder: (context, index) {

              var company = filteredCompanies[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(company.id.toString()),
                  ),
                  title: Text(company.companyId),
                  subtitle: Text(company.city),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ✏️ EDIT
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompanyFormScreen(company: company),
                            ),
                          );

                          setState(() {
                            companyList = fetchCompanies();
                          });
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          confirmDelete(company.id);
                        },
                      ),

                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}