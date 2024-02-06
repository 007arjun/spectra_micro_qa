import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../sql_helper.dart';

class EditBatchWidget extends StatefulWidget {
  final Map<String, dynamic> batchDetails;

  const EditBatchWidget({Key? key, required this.batchDetails}) : super(key: key);

  @override
  _EditBatchState createState() => _EditBatchState();
}

class _EditBatchState extends State<EditBatchWidget> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final _batchNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.batchDetails != null) {
      _batchNameController.text = widget.batchDetails['name'];
      _selectedDate = DateTime.parse(widget.batchDetails['date']);
      _quantityController.text = widget.batchDetails['quantity'];
      _serialNumberController.text = widget.batchDetails['serialNumber'];
      _manufacturerController.text = widget.batchDetails['manufacturer'];
    }
  }

  Future<void> updateBatchInDatabase(
      String batchName,
      DateTime? selectedDate,
      String quantity,
      String serialNumber,
      String manufacturer,
      ) async {
    SQLHelper sqlHelper = SQLHelper();

    Map<String, dynamic> updatedBatch = {
      SQLHelper.columnBranchName: batchName,
      SQLHelper.columnBranchDate: selectedDate?.toLocal().toString(),
      SQLHelper.columnBranchQuantity: quantity,
      SQLHelper.columnBranchSerialNumber: serialNumber,
      SQLHelper.columnBranchManufacturer: manufacturer,
    };

    try {
      int result = await sqlHelper.updateBatch(widget.batchDetails['name'], updatedBatch);

      if (result > 0) {
        print('Batch details updated in the database');
        Navigator.pop(context, updatedBatch);
      } else {
        print('No rows were updated. Check your update conditions.');
      }
    } catch (e) {
      print('Error updating batch details: $e');
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
                      'Edit Batch',
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
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Batch Name
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextFormField(
                              controller: _batchNameController,
                              decoration: InputDecoration(
                                hintText: 'Batch Name',
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(35.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Batch Name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 0),
                          // Batch Date
                          Padding(
                            padding: const EdgeInsets.all(5),
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
                          // Quantity
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _quantityController,
                              decoration: InputDecoration(
                                hintText: 'Quantity',
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(35.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 0),
                          // Serial Number
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextFormField(
                              controller: _serialNumberController,
                              decoration: InputDecoration(
                                hintText: 'Serial Number',
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(35.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Serial Number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 0),
                          // Manufacturer
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: TextFormField(
                              controller: _manufacturerController,
                              decoration: InputDecoration(
                                hintText: 'Name Of Manufacturer',
                                hintStyle: TextStyle(color: Colors.black),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(35.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Manufacturer Name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          // Save Button
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_validateForm()) {
                                  updateBatchInDatabase(
                                    _batchNameController.text,
                                    _selectedDate,
                                    _quantityController.text,
                                    _serialNumberController.text,
                                    _manufacturerController.text,
                                  ).then((_) {});
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFf7572d),
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

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }
}