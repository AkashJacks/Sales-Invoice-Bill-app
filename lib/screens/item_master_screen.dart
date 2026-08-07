import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import 'item_form_screen.dart';

class ItemMasterScreen extends StatefulWidget {
  const ItemMasterScreen({super.key});
  
  @override
  ItemMasterScreenState createState() => ItemMasterScreenState();
}

class ItemMasterScreenState extends State<ItemMasterScreen> {

  late Future<List<Item>> itemList;

  String? selectedCompanyFilter;
  List companies = [];

  @override
  void initState() {
    super.initState();
    itemList = fetchItems();
    fetchCompanies();
  }

  //  FETCH ITEMS
  Future<List<Item>> fetchItems() async {
    var url = Uri.parse("http://192.168.0.4/erp_api/item_api.php?task=get");

    var response = await http.get(url);

    List data = jsonDecode(response.body);

    return data.map((e) => Item.fromJson(e)).toList();
  }

  //  FETCH COMPANIES FOR FILTER
  Future<void> fetchCompanies() async {
    var url = Uri.parse("http://192.168.0.4/erp_api/company_api.php?task=get");

    var response = await http.get(url);

    setState(() {
      companies = jsonDecode(response.body);
    });
  }

  //  DELETE
  Future<void> deleteItem(int id) async {
    var url = Uri.parse(
        "http://192.168.0.4/erp_api/item_api.php?task=delete&id=$id");

    var response = await http.get(url);

    var data = jsonDecode(response.body);

    if (data["status"] == "deleted") {
      print("Deleted");
    }
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
              await deleteItem(id);
              Navigator.pop(context);

              setState(() {
                itemList = fetchItems(); // refresh
              });
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  //  FILTER FUNCTION
  List<Item> applyFilter(List<Item> items) {

    if (selectedCompanyFilter == null || selectedCompanyFilter!.isEmpty) {
      return items;
    }

    return items
        .where((item) => item.companyId == selectedCompanyFilter)
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
        title: Text("Item Master"),
        actions: [

          // ➕ ADD
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {

              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemFormScreen(),
                ),
              );

              if (result == true) {
                setState(() {
                  itemList = fetchItems();
                });
              }
            },
          ),

          // 🔍 FILTER
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: openFilterDialog,
          ),
        ],
      ),

      //  MAIN BODY
      body: FutureBuilder<List<Item>>(
        future: itemList,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading data"));
          }

          var items = snapshot.data!;

          //  APPLY FILTER HERE
          var filteredItems = applyFilter(items);

          if (filteredItems.isEmpty) {
            return Center(child: Text("No Items Found"));
          }

          return ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {

              var item = filteredItems[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(item.id.toString()),
                  ),

                  title: Text("Company: ${item.companyId}"),
                  subtitle: Text(item.description),

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
                                  ItemFormScreen(item: item),
                            ),
                          );

                          setState(() {
                            itemList = fetchItems();
                          });
                        },
                      ),

                      // 🗑 DELETE
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          confirmDelete(item.id);
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