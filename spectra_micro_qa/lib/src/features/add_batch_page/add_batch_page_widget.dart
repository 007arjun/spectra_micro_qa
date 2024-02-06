import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../sql_helper.dart';

class AddBatchPageWidget extends StatefulWidget {
  const AddBatchPageWidget({Key? key}) : super(key: key);

  @override
  _BatchPageState createState() => _BatchPageState();
}

class _BatchPageState extends State<AddBatchPageWidget> {
  DateTime? _selectedDate;
  final _formKey = GlobalKey<FormState>();

  final _batchNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();

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
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                bottomRight: Radius.circular(60.0),
              ),
            ),
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
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 59),
                    child: Text(
                      'Add Batch',
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
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            controller: _batchNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Batch Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Batch Name',
                              hintStyle: TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
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
                                decoration: InputDecoration(
                                  hintText: 'Batch Date',
                                  hintStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(35.0),
                                  ),
                                ),
                                controller: TextEditingController(
                                  text: _selectedDate != null
                                      ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                                      : '',
                                ),
                                validator: (value) {
                                  if (_selectedDate == null) {
                                    return 'Please select Batch Date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 0),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: _quantityController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Quantity';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Quantity',
                              hintStyle: TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
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
                            controller: _serialNumberController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Serial Number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Serial Number',
                              hintStyle: TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
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
                            controller: _manufacturerController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Manufacturer Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Name Of Manufacturer',
                              hintStyle: TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_validateForm()) {
                                _saveBatchData();
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
      ),
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
      });
    }
  }

  void _saveBatchData() async {
    try {
      Map<String, dynamic> batchData = {
        SQLHelper.columnBranchName: _batchNameController.text,
        SQLHelper.columnBranchDate: _selectedDate!.toLocal().toString(),
        SQLHelper.columnBranchQuantity: _quantityController.text,
        SQLHelper.columnBranchSerialNumber: _serialNumberController.text,
        SQLHelper.columnBranchManufacturer: _manufacturerController.text,
      };

      int result = await SQLHelper().insertBranch(batchData);

      if (result > 0) {
        Navigator.pop(context, _batchNameController.text);
      } else {
        // Handle error
        print("Error saving batch data");
      }
    } catch (e) {
      // Handle exceptions
      print("Exception: $e");
    }
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }
}