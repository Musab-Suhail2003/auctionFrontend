import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:auction_site/gui_elements/mybutton.dart';
import 'package:auction_site/gui_elements/textfield.dart';
import 'package:auction_site/pages/itemspage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class SellerPage extends StatefulWidget {
  final dynamic token;
  const SellerPage({super.key, required this.token});

  @override
  _SellersPageState createState() => _SellersPageState();
}

class _SellersPageState extends State<SellerPage> {
  final String baseUrl = "https://auction-node-server.vercel.app"; // Your server's URL
  final String additems = "/items/additem";
  final itemNameController = TextEditingController();
  final itemPriceController = TextEditingController();
  final description = TextEditingController();
  List<dynamic> items = [];
  int? selectedCategory ; // Variable to hold the selected category
  List<dynamic> categories = [];
  File? _image;
  final _picker = ImagePicker();

  @override
    void initState() {
      super.initState();
      _initializeItems(); // Call the async wrapper
    }

    Future<void> _initializeItems() async {
      final fetchedItems = await getItems();
      final fetchedCategories = await getCategories();
      setState(() {
        items = fetchedItems;
        categories = fetchedCategories;
      });
        print(categories);
    }
  Future<List<dynamic>> getCategories() async{
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/items/getCategori'),
        headers: {
          'Content-Type': 'application/json',
          'Connection': 'keep-alive',
          'Authorization': 'Bearer ${widget.token[0]}'
        },
      );
      final r = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("categories.... $r");
        return List<dynamic>.from(r);
      } else {
                print("categories.... $r");

        print('Error: ${r}');
      }
    }catch (e) {
      print('Exception: $e');
    }
    return [];
  }

  Future<List<dynamic>> getItems() async {
    final url = Uri.parse('$baseUrl/items/ofuser/${widget.token[1]['user_id']}');
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
          'Connection' : 'keep-alive',
          'Authorization': 'Bearer ${widget.token[0]}'
        },
        body: jsonEncode({
          'user_id': widget.token[1]['user_id'],
          'item_name': itemNameController.text,
          'description': description.text,
          'category_id': selectedCategory,
          'min_bid' : double.parse(itemPriceController.text),
        }),
      );

        final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item Added')
        ),
        );
        
      } else {
        final error = jsonDecode(response.body);
        print(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error Adding Item'),
          ),
        );
      }
      uploadFile(_image!, data['item_id']);
    } catch (e) {
      
    }

    itemNameController.clear();
    itemPriceController.clear();
    description.clear();
    selectedCategory = null; // Reset dropdown
    _image = null;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fields Cleared!"),
      ),
    );
  }
  Future<void> uploadFile(File file, int itemId) async {
  final String url = '$baseUrl/upload/upload';

  // Create a multipart request
  final request = http.MultipartRequest('POST', Uri.parse(url));

  // Attach the file
  request.files.add(await http.MultipartFile.fromPath('images', file.path));

  // Add any additional fields
  request.fields['item_id'] = itemId.toString();

  try {
    // Send the request
    final response = await request.send();

    if (response.statusCode == 201) {
      print('Upload successful');
      final res = await http.Response.fromStream(response);
      print(res.body); // Server's response
    } else {
      print('Upload failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading file: $e');
  }
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
    child: SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add a New Item",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        newTextField(hintText: 'Item Name', password: false, controller: itemNameController),
        const SizedBox(height: 10),
        newTextField(hintText: 'Min Bid', password: false, controller: itemPriceController),
        const SizedBox(height: 10),
        newTextField(hintText: 'Description', password: false, controller: description),
        const SizedBox(height: 10),

        // Ensure proper layout for image and buttons
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(_image!, height: 50, width: 50), // Adjusted size
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Dropdown for categories
        DropdownButtonFormField<int>(
          value: selectedCategory,
          hint: const Text("Select a Category"),
          onChanged: (int? value) {
            setState(() {
              selectedCategory = value;
            });
          },
          items: categories.map((category) {
            return DropdownMenuItem<int>(
              value: category['category_id'],  // Ensure the correct key is used
              child: Text(category['category_name'] ?? " "),
            );
          }).toList(),
        ),

        // Add Item button
        Center(
          child: newButton(
            text: "Add Item",
            ontap: ontap
          ),
        ),
      ],
    ),
    )
  );
  }
void ontap(){
  addItem();
}

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  
  Widget itemsTab() {
    print(items);
    return RefreshIndicator(
      onRefresh: _initializeItems,
      child: 
      items.isEmpty
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
                    bool sold = items[index]['sold'];
                    var i = items[index];
                    print(i);
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
                      child: GestureDetector(
                        child: ListTile(
                              title: Text(i['item_name']?? ''), // Ensure this is a string
                              trailing: Column(
                                children: [
                                  Text(sold?"sold":"available", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                                  Text("min bid: ${i['min_bid']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),),
                                Text("user id: ${i['user_id']}", style: TextStyle(color: Theme.of(context).colorScheme.primary),)],
                              ) // Convert to string
                            ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>Itemspage(itemData: i, token: widget.token[0]))),
                      ),
                    );
                  },
                
                )
    );
  }

}
