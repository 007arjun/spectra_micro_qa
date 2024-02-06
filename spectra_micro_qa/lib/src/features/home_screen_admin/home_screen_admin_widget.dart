import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spectra_micro_qa/src/features/add_product_page/add_product_page_widget.dart';
import 'package:spectra_micro_qa/src/features/edit_profile/edit_profile_widget.dart';
import 'package:spectra_micro_qa/src/features/login_page/login_page_widget.dart';
import 'package:spectra_micro_qa/sql_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spectra_micro_qa/src/features/test_form/test_form_widget.dart';
import 'package:spectra_micro_qa/src/features/view_batch_screen/view_batch_widget.dart';
import '../edit_product/edit_product_widget.dart';

class HomeScreenAdminWidget extends StatefulWidget {
  final String userEmail;

  const HomeScreenAdminWidget({Key? key, required this.userEmail}) : super(key: key);

  @override
  _HomeScreenAdminWidgetState createState() => _HomeScreenAdminWidgetState();
}

class _HomeScreenAdminWidgetState extends State<HomeScreenAdminWidget> {
  late int userUniqueIdentifier;
  Map<String, dynamic> userData = {};
  int _currentIndex = 0;
  bool _darkMode = false;
  late Future<List<Product>> _productListFuture;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  File? selectedImageFile;


  @override
  void initState() {
    super.initState();
    _initDefaultData();
    userUniqueIdentifier = 0;
    _getUserData();
    _fetchAndSetProducts();
    _productListFuture = _getProductList();
  }

  Future<void> _initDefaultData() async {
    userUniqueIdentifier = await SQLHelper().initDefaultData();
  }


  Future<void> _getUserData() async {
    Map<String, dynamic>? user = await SQLHelper().getUserByEmail(widget.userEmail);
    if (user != null) {
      setState(() {
        userData = user;
        userUniqueIdentifier = user['id'];
      }
      );
    }
  }
  Future<void> _insertProduct(
      Map<String, dynamic> productData, File imageFile) async {
    try {
      // Save the image to the documents directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String imagePath = '${appDocDir.path}/${productData['name']}.jpg';
      imageFile.copySync(imagePath);

      // Update productData with the image path
      productData['imagePath'] = imagePath;

      await SQLHelper().insertProduct(productData, userUniqueIdentifier);
      await _refreshProfile();
      await _fetchAndSetProducts();

      Product newProduct = Product(
        productData['id'],
        productData['name'],
        productData['description'],
        productData['addedDate'],
        productData['imagePath'],
        productData['batchName'],
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product added successfully: ${newProduct.name}'),
        duration: Duration(seconds: 2),
      ));

      Scrollable.ensureVisible(_refreshIndicatorKey.currentContext!);
    } catch (e) {
      print('Error inserting product: $e');
    }
  }
  Future<List<Product>> _getProductList() async {
    try {
      List<Map<String, dynamic>> productListFromDB =
      await SQLHelper().getAllProducts();

      List<Product> productList = productListFromDB.map((productMap) {
        return Product(
          productMap['id'],
          productMap['name'],
          productMap['description'],
          productMap['addedDate'],
          productMap['imagePath'],
          productMap['batchName'],
        );
      }).toList();

      return productList;
    } catch (e) {
      print('Error fetching product list: $e');
      return [];
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await SQLHelper().deleteProduct(product.name);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product deleted successfully'),
        duration: Duration(seconds: 2),
      )
      );
      setState(() {
        _productListFuture = _getProductList();
      }
      );
    }
    catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting product. Please try again.'),
        duration: Duration(seconds: 2),
      )
      );
    }
  }
  Future<void> _refresh() async {

    await Future.delayed(Duration(seconds: 1));

    await _getUserData();
    setState(() {
      _productListFuture = _getProductList();
    }
    );
  }

  Future<void> _updateProduct(
      String productName, Map<String, dynamic> updatedProductData) async {
    try {
      await SQLHelper().updateProduct(productName, updatedProductData);

      // Refresh the product list
      setState(() {
        _productListFuture = _getProductList();
      });

      // Display a snackbar or perform any other UI update
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Product updated successfully: $productName'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating product. Please try again.'),
        duration: Duration(seconds: 2),
      ));
    }
  }


  Future<void> _refreshProfile() async {
    await _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            title: _getAppBarTitle(_currentIndex),
            backgroundColor: Colors.white,
            leading: Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFf7572d),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userData['profileImage'] != null
                        ? FileImage(File(userData['profileImage']!)) as ImageProvider<Object>
                        : AssetImage('assets/prof.png'),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      userData['name'] ?? 'Name',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.add_box_outlined, color: Colors.black),
              title: Text('Add Product'),
              onTap: () {
                _handleImageSelection(); // Call the method to handle image selection

                // Navigate to AddProductPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPageWidget(
                      userEmail: widget.userEmail,
                      userUniqueIdentifier: userUniqueIdentifier,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.view_list_outlined, color: Colors.black),
              title: Text('View Batch'),
              onTap: () async {
                final Map<String, dynamic>? result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewBatchWidget()),
                );
                if (result != null) {
                  _insertProduct(result, selectedImageFile!);
                }
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _getBody(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          }
          );
        },
        backgroundColor: Color(0xFFf7572d),
        selectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return _buildContent();
      case 1:
        return Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height:20 ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPageWidget()),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 10),
                          Text('Logout',style: TextStyle(fontSize: 20),),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      case 2:
        return _buildProfileContent();
      default:
        return Container();
    }
  }
  Widget _buildContent() {
    return FutureBuilder<List<Product>>(
      future: _productListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmer();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<Product> productList = snapshot.data ?? [];

          // Filter out the default product from the list
          productList.removeWhere((product) => product.name == 'Default Product');

          return Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: productList.length,
              itemBuilder: (context, index) {
                // Display the newly added product card and others
                return _buildProductListItem(productList[index]);
              },
            ),
          );
        }
      },
    );
  }
  Widget _buildProductListItem(Product product) {
    File imageFile = File(product.imagePath);
    return Card(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: ExpansionTile(
            tilePadding: EdgeInsets.all(16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Name: ${product.name}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Description: ${product.description}',
                  maxLines: 30,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Added Date: ${product.addedDate}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Batch: ${product.batchName}',
                  style: TextStyle(fontSize: 16),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TestFormWidget(product: product)),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFf7572d),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TEST',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_arrow_down),
                PopupMenuButton<String>(
                  itemBuilder: (context) {
                    return {'Edit', 'Delete'}.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                  onSelected: (String choice) async {
                    if (choice == 'Edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProductPageWidget(product: product),
                        ),
                      );
                    } else if (choice == 'Delete') {
                      await _deleteProduct(product);
                    }
                  },
                )
              ],
            ),
            children: [
              Container(
                width: double.infinity,
                height: 300,
                child: product.name == 'SkyVoiceAlert 500'
                    ? Image.asset('assets/product.jpeg')
                    : Image.file(imageFile, fit: BoxFit.cover),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(

                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return Text(
          'Home',
          style: TextStyle(color: Colors.black),
        );
      case 1:
        return Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        );
      case 2:
        return Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        );
      default:
        return Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        );
    }
  }
  Widget _buildProfileContent() {
    return  SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: SQLHelper().getUserByEmail(widget.userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null) {
            return Center(child: Text('No user data available.'));
          } else {
            Map<String, dynamic> updatedUserData = snapshot.data!;
            return Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: updatedUserData['profileImage'] != null
                          ? FileImage(File(updatedUserData['profileImage']!)) as ImageProvider<Object>
                          : AssetImage('assets/product.jpeg'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileWidget(userData: updatedUserData),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFf7572d),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(updatedUserData['name'] ?? 'Username', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(updatedUserData['email'] ?? 'Email', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(updatedUserData['phone'] ?? 'Phone Number', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
  getApplicationDocumentsDirectory() {}

}
class _handleImageSelection {
}

class _fetchAndSetProducts {}

class Product {
  int id;
  final String name;
  final String description;
  final String addedDate;
  final String imagePath;
  final String? batchName;

  Product(this.id, this.name, this.description, this.addedDate, this.imagePath, this.batchName);
}