import 'package:flutter/material.dart';
import '../models/dealer_model.dart';
import 'dealer_form_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DealerMasterScreen extends StatefulWidget {
  const DealerMasterScreen({super.key});
  
  @override
  DealerMasterScreenState createState() => DealerMasterScreenState();
}

class DealerMasterScreenState extends State<DealerMasterScreen> {

  late Future<List<Dealer>> dealerList;

  String? selectedCompanyFilter;
  List companies = [];

  @override
  void initState() {
    super.initState();
    dealerList = fetchDealers();
    fetchCompanies();
  }

  //  FETCH DEALERS
  Future<List<Dealer>> fetchDealers() async {

    var url = Uri.parse("http://192.168.0.4/erp_api/dealer_api.php?task=get");

    var response = await http.get(url);

    List data = jsonDecode(response.body);

    return data.map((e) => Dealer.fromJson(e)).toList();
  }

  //  FETCH COMPANIES (FOR FILTER)
  Future<void> fetchCompanies() async {

    var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get");

    var response = await http.get(url);

    setState(() {
      companies = jsonDecode(response.body);
    });
  }

  //  DELETE
  Future<void> deleteDealer(int id) async {

    var url = Uri.parse(
        "http://192.168.0.4/erp_api/dealer_api.php?task=delete&id=$id");

    var response = await http.get(url);

    var data = jsonDecode(response.body);

    if (data["status"] == "deleted") {
      print("Deleted Successfully");
    }
  }

  //  CONFIRM DELETE
  void confirmDelete(int id) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Delete this dealer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {

              await deleteDealer(id);

              Navigator.pop(context);

              setState(() {
                dealerList = fetchDealers();
              });
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  //  FILTER FUNCTION
  List<Dealer> applyFilter(List<Dealer> dealers) {

    if (selectedCompanyFilter == null || selectedCompanyFilter!.isEmpty) {
      return dealers;
    }

    return dealers
        .where((d) => d.companyId == selectedCompanyFilter)
        .toList();
  }

  //  FILTER DIALOG
  void openFilterDialog() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text("Filter by Company"),

          content: DropdownButtonFormField<String>(
            value: selectedCompanyFilter,
            hint: Text("Select Company"),
            items: companies.map<DropdownMenuItem<String>>((c) {
              return DropdownMenuItem(
                value: c["company_id"],
                child: Text(c["company_id"]),
              );
            }).toList(),
            onChanged: (value) {
              selectedCompanyFilter = value;
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
                setState(() {}); 
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
        title: Text("Dealer Master"),
        actions: [

          // ➕ ADD
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DealerFormScreen(),
                ),
              );

              setState(() {
                dealerList = fetchDealers();
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

      body: FutureBuilder<List<Dealer>>(
        future: dealerList,
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var dealers = snapshot.data!;
          print(snapshot.data);

          //  APPLY FILTER HERE
          var filteredDealers = applyFilter(dealers);

          if (filteredDealers.isEmpty) {
            return Center(child: Text("No Dealers Found"));
          }

          return ListView.builder(
            itemCount: filteredDealers.length,
            itemBuilder: (context, index) {

              var d = filteredDealers[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(d.id.toString()),
                  ),

                  title: Text("Company: ${d.companyId}"),
                  subtitle: Text(d.dealerName),

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
                                  DealerFormScreen(dealer: d),
                            ),
                          );

                          setState(() {
                            dealerList = fetchDealers();
                          });
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          confirmDelete(d.id);
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