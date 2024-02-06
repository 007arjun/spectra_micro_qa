import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:spectra_micro_qa/src/features/add_batch_page/add_batch_page_widget.dart';
import 'package:spectra_micro_qa/src/features/home_screen_admin/home_screen_admin_widget.dart';
import '../../../sql_helper.dart';

class AddProductPageWidget extends StatefulWidget {
  final String userEmail;
  final int userUniqueIdentifier;

  const AddProductPageWidget({Key? key, required this.userEmail,required this.userUniqueIdentifier}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<AddProductPageWidget> {
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addedDateController = TextEditingController();
  final _imagePathController = TextEditingController();

  XFile? _selectedImage;
  String? _selectedBatch;
  List<String> _batchList = [];

  @override
  void initState() {
    super.initState();
    _selectedBatch = '';
    fetchBatchNames();
  }

  Future<void> fetchBatchNames() async {
    List<String>? batchesFromDatabase = await SQLHelper().getAllBatchNames();
    setState(() {
      _batchList = batchesFromDatabase ?? [];
      print('Batch List: $_batchList');
    }
    );
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _imagePathController.text = _selectedImage?.path ?? '';
      }
      );
    }
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
            colorScheme: ColorScheme.light(primary: Color(0xFFf7572d)),
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
      }
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = {
        'name': _productNameController.text,
        'description': _descriptionController.text,
        'addedDate': DateFormat('dd-MM-yyyy').format(_selectedDate!),
        'imagePath': _imagePathController.text,
        'userId': widget.userUniqueIdentifier,
        'batchName': _selectedBatch,
      };

      try {
        int productId = await SQLHelper().insertProduct(product, widget.userUniqueIdentifier);

        await fetchBatchNames();

        print('Product added with ID: $productId');
        if (context != null) {
          if (_batchList.contains(_selectedBatch)) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreenAdminWidget(userEmail: widget.userEmail),
              ),
            );
          } else {
            print('Error: Batch list not updated');
          }
        }
      } catch (e) {
        print('Error adding product: $e');
      }
    }
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
          padding: const EdgeInsets.only(bottom: 55.0),
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
            child: ListView(
              children: [
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
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 59),
                  child: Text(
                    'Add Product',
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
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: ),
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
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _addedDateController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the added date';
                                }
                                return null;
                              },
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
                        ),
                      ),
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
                        child:   Row(
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
                      SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveProduct,
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
                                'ADD',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
