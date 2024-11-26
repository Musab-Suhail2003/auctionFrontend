import 'dart:convert';

import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SellerPage extends StatefulWidget {
  final dynamic token;
  const SellerPage({super.key, required this.token});

  @override
  _SellersPageState createState() => _SellersPageState();
}

class _SellersPageState extends State<SellerPage> {
  final String baseUrl = "http://10.0.2.2:3000"; // Your server's URL
  final String additems = "/items/additem";
  final itemNameController = TextEditingController();
  final itemPriceController = TextEditingController();
  final description = TextEditingController();
  List<dynamic> items = [];
  String? selectedCategory; // Variable to hold the selected category
  final List<String> categories = ['Vehicle', 'Mens Wear'];

  @override
    void initState() {
      super.initState();
      _initializeItems(); // Call the async wrapper
    }

    Future<void> _initializeItems() async {
      final fetchedItems = await getItems();
      setState(() {
        items = fetchedItems;
      });
      print(items);
    }


  Future<List<dynamic>> getItems() async {
    final url = Uri.parse('$baseUrl/items/');
    print(widget.token);
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': 'Bearer ${widget.token[0]}'
        },
      );

      if (response.statusCode == 200) {
        return List<dynamic>.from(jsonDecode(response.body));
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    return [];
  }

  void addItem() async{
    if (itemNameController.text.isEmpty || 
        itemPriceController.text.isEmpty || 
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill out all fields."),
        ),
      );
      return;
    }

      items.add({
        'name': itemNameController.text,
        'price': itemPriceController.text,
        'category': selectedCategory,
      });
      var url = Uri.parse('$baseUrl$additems');
      try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Connection' : 'keep-alive'
      },
      body: jsonEncode({
        'user_id': widget.token[1],
        'item_name': itemNameController.text,
        'description': description.text,
        'category_id': categories.indexOf(selectedCategory!),
        'min_bid' : int.parse(itemPriceController.text),

      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('asdasd')
      ),
      );
      
    } else {
      final error = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('error'),
      ),
    );
    }
    } catch (e) {
      
    }

    itemNameController.clear();
    itemPriceController.clear();
    description.clear();
    selectedCategory = null; // Reset dropdown

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item added successfully!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('Sellers Page', style: TextStyle(color: Theme.of(context).colorScheme.tertiary,),),
          bottom: TabBar(
                labelColor: Theme.of(context).colorScheme.tertiary,
            indicatorColor: Theme.of(context).colorScheme.tertiary,
            tabs: [
              Tab(icon: Icon(Icons.add, color: Theme.of(context).colorScheme.tertiary), text: "Add Item"),
              Tab(icon: Icon(Icons.list, color: Theme.of(context).colorScheme.tertiary), text: "Items"),
            ],
          ),
        ),
        body: TabBarView(
          
          children: [
            addItemTab(),
            itemsTab(),
          ],
        ),
      ),
    );
  }

  Widget addItemTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add a New Item",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)
          ),
          const SizedBox(height: 10),
          TextField(
            controller: itemNameController,
            decoration: const InputDecoration(
              labelText: "Item Name",
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: itemPriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Min Bid",
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: description,
            decoration: const InputDecoration(
              labelText: "description",
              border: OutlineInputBorder(),
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            hint: const Text("Select a Category"),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          newButton(text: "Add Item", ontap: addItem),
        ],
      ),
    );
  }

  Widget itemsTab() {
    
    return items.isEmpty
        ? const Center(
            child: Text(
              'No items added yet!',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ListView.builder(
                itemCount: items.length,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  var i = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 7,
                          color: Theme.of(context).colorScheme.primary,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 5),
                    child: ListTile(

                      title: Text(i['item_name']), // Ensure this is a string
                      trailing: Column(
                        children: [const SizedBox(height: 10,),
                          Text("min bid: ${i['min_bid']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                        Text("user id: ${i['user_id']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),)],
                      ) // Convert to string
                    ),
                  );
                },
              
              );
  }
}
