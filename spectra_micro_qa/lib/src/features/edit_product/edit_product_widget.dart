import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:spectra_micro_qa/src/features/add_batch_page/add_batch_page_widget.dart';
import '../../../sql_helper.dart';
import '../home_screen_admin/home_screen_admin_widget.dart';

class EditProductPageWidget extends StatefulWidget {
  final Product product;

  const EditProductPageWidget({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPageWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBatch;
  List<String> _batchList = [];

  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addedDateController = TextEditingController();
  final _imagePathController = TextEditingController();
  final _batchNameController = TextEditingController();

  XFile? _selectedImage;
  DateTime? _selectedDate;

  Future<void> fetchBatchNames() async {
    List<String>? batchesFromDatabase = await SQLHelper().getAllBatchNames();
    setState(() {
      _batchList = batchesFromDatabase ?? [];
      print('Batch List: $_batchList');
    });
  }


  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _imagePathController.text = _selectedImage?.path ?? '';
      });
    }
  }

  Future<void> _pickBatch(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: ListView.builder(
            itemCount: _batchList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // "Create batch" item
                return ListTile(
                  title: Text('Create batch'),
                  onTap: () {
                    // Navigate to AddBatchWidget
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBatchPageWidget(),
                      ),
                    ).then((result) {
                      if (result != null) {
                      }
                      Navigator.pop(context);
                    });
                  },
                );
              } else {
                String batchName = _batchList[index - 1];
                return ListTile(
                  title: Text(batchName),
                  onTap: () {
                    setState(() {
                      _batchNameController.text = batchName;
                    });
                    // Navigator.pop(context);
                  },
                );
              }
            },
          ),
        );
      },
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFFf7572d),
            hintColor: Color(0xFFf7572d),
            colorScheme: ColorScheme.light(primary: Color(0xFFf7572d)
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _addedDateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
    }
  }

  Future<void> _updateProduct(Map<String, dynamic> updatedProduct) async {
    try {
      await SQLHelper().updateProduct(widget.product.name, updatedProduct);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product updated successfully'),
          duration: Duration(seconds: 1),
        ),
      );

      // Pass the updated product data back to the calling widget
      Navigator.of(context).pop(updatedProduct);
    } catch (e) {
      print('Error updating product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBatchNames();
    _productNameController.text = widget.product.name;
    _descriptionController.text = widget.product.description;
    _addedDateController.text = widget.product.addedDate;
    _imagePathController.text = widget.product.imagePath;
    _batchNameController.text = widget.product.batchName!; // Set the initial value
    _selectedBatch = widget.product.batchName;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFf7572d),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 45.0),
          child: Container(
            width: screenWidth >= 1800 ? 1800 : screenWidth,
            height: screenHeight >= 2000 ? 2000 : screenHeight,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                bottomRight: Radius.circular(60.0),
              ),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 59),
                      child: Text(
                        'Edit Product',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _productNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the product name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Product Name',
                          hintStyle: TextStyle(color: Color(0xFF000000)),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _descriptionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          hintText: 'Description',
                          hintStyle: TextStyle(color: Color(0xFF000000)),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        controller: _addedDateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the added date';
                          }
                          return null;
                        },
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          hintText: 'Added Date',
                          hintStyle: TextStyle(color: Color(0xFF000000)),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: TextFormField(
                          enabled: false,
                          controller: _imagePathController,
                          decoration: InputDecoration(
                            hintText: 'Choose Image',
                            hintStyle: TextStyle(color: Color(0xFF000000)),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(35.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                TextFormField(
                                  enabled: false,
                                  controller: TextEditingController(text: _selectedBatch),
                                  decoration: InputDecoration(
                                    hintText: 'Select batch',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Color(0xFFFFFFFF),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(35.0),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            height: 200,
                                            child: ListView.builder(
                                              itemCount: _batchList.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index == 0) {
                                                  return ListTile(
                                                    title: Text('Create batch'),
                                                    onTap: () async {
                                                      var result = await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => AddBatchPageWidget(),
                                                        ),
                                                      );
                                                      if (result != null && result is String) {
                                                        setState(() {
                                                          _selectedBatch = result;
                                                          _batchList.add(result);
                                                        }
                                                        );
                                                      }
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                } else {
                                                  String batchName = _batchList[index - 1];
                                                  return ListTile(
                                                    title: Text(batchName),
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedBatch = batchName;
                                                      }
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Map<String, dynamic> updatedProduct = {
                              'name': _productNameController.text,
                              'description': _descriptionController.text,
                              'addedDate': _addedDateController.text,
                              'imagePath': _imagePathController.text,
                            };

                            _updateProduct(updatedProduct);

                            // Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFf7572d),
                          fixedSize: Size(118, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Container(
                          child: Center(
                            child: Text(
                              'SAVE',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

