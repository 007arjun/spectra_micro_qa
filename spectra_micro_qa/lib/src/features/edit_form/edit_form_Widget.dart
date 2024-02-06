import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../sql_helper.dart';

class EditFormWidget extends StatefulWidget {
  final int formId;
  final String formTitle;

  EditFormWidget({required this.formId, required this.formTitle});

  @override
  _EditFormWidgetState createState() => _EditFormWidgetState();
}

class _EditFormWidgetState extends State<EditFormWidget> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _formFields = [];

  List<String> _selectedQuestionTypes = [];
  List<String> _selectedDropDownValue = [];
  List<List<String>> _multipleChoiceOptionsList = [];

  List<TextEditingController> _titleControllers = [];
  List<TextEditingController> _commentControllers = [];
  List<TextEditingController> _multipleChoiceTitleControllers = [];


  TextEditingController _formTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formTitleController.text = widget.formTitle;
    _multipleChoiceOptionsList = [];
    _selectedQuestionTypes = [];
    _selectedDropDownValue = [];
    _titleControllers = [];
    _commentControllers = [];
    _multipleChoiceTitleControllers = [];
    fetchFormFieldsData();
  }

  void fetchFormFieldsData() async {
    _formFields = await fetchFormFields(widget.formId);

    setState(() {
      _selectedQuestionTypes = _formFields.map<String>((field) => field[SQLHelper.columnFormFieldType]).toList();
      _selectedDropDownValue = List<String>.filled(_formFields.length, '');
      _multipleChoiceOptionsList = _formFields.map<List<String>>((field) {
        return field[SQLHelper.columnFormFieldSelectedOption] != null
            ? (field[SQLHelper.columnFormFieldSelectedOption] as String).split(',') : [];
      }
      ).toList();

      _titleControllers = List.generate(_formFields.length, (index) => TextEditingController(text: _formFields[index][SQLHelper.columnFormFieldTitle]));
      _commentControllers = List.generate(_formFields.length, (index) => TextEditingController(text: _formFields[index][SQLHelper.columnFormFieldComment] ?? ''));
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFf7572d),
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: Text(
          'Edit Form',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFf7572d),
      ),
      body: Container(
        width: screenWidth * 1.0,
        height: screenHeight * 1.0,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _formTitleController,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Form Title',
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Created On:',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
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
                              if (pickedDate != null && pickedDate != _selectedDate) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                      : 'Select Date',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Icon(Icons.calendar_today, size: 16, color: Color(0xFFf7572d)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  right: screenWidth * 0.03,
                  child: Text(
                    'Add Fields',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 4,),
                Positioned(
                  top: 25,
                  right: screenWidth * 0.2,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _multipleChoiceOptionsList.add(['OK', 'NOT OK']);
                            _selectedQuestionTypes.add('Radio Button');
                            _selectedDropDownValue.add('');
                            _commentControllers.add(TextEditingController());
                            _titleControllers.add(TextEditingController());
                            _multipleChoiceTitleControllers.add(TextEditingController());
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _multipleChoiceOptionsList.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _titleControllers[index],
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: _selectedQuestionTypes[index],
                                  items: [
                                    _buildDropdownMenuItem('Comment', Icons.short_text),
                                    _buildDropdownMenuItem('Radio Button', Icons.radio_button_checked),
                                    _buildDropdownMenuItem('Delete', Icons.delete),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == 'Delete') {
                                        _selectedQuestionTypes.removeAt(index);
                                        _multipleChoiceOptionsList.removeAt(index);
                                        _selectedDropDownValue.removeAt(index);

                                        _titleControllers[index].dispose();
                                        _commentControllers[index].dispose();
                                        _titleControllers.removeAt(index);
                                        _commentControllers.removeAt(index);
                                      } else {
                                        _selectedQuestionTypes[index] = value!;
                                        if (value == 'Radio Button') {
                                          _multipleChoiceOptionsList[index] = ['OK', 'NOT OK'];
                                        } else {
                                          _multipleChoiceOptionsList[index] = [];
                                        }
                                      }
                                    }
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (_selectedQuestionTypes[index] == 'Radio Button')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: _multipleChoiceOptionsList[index]
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int subIndex = entry.key;
                                String option = entry.value;

                                return Row(
                                  children: [
                                    Radio(
                                      value: option,
                                      groupValue: _selectedDropDownValue.length > index ? _selectedDropDownValue[index] : null,
                                      onChanged: (value) {
                                        setState(() {
                                          if (_selectedDropDownValue.length > index) {
                                            _selectedDropDownValue[index] = value.toString();
                                          }
                                        });
                                      },
                                      activeColor: Color(0xFFF7572D),
                                    ),
                                    Text(
                                      option,
                                      style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),

                          if (_selectedQuestionTypes[index] == 'Comment')
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                controller: _commentControllers[index],
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFf7572d),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  ),
                  onPressed: () async {
                    await SQLHelper().updateFormAndFields(widget.formId, _formTitleController.text, _formFields);

                    for (int index = 0; index < _formFields.length; index++) {
                      Map<String, dynamic> field = _formFields[index];
                      String title = _titleControllers[index].text;
                      String comment = _commentControllers[index].text;
                      String selectedOption = _selectedDropDownValue[index];

                      if (_selectedQuestionTypes[index] == 'Radio Button' && selectedOption.isEmpty) {
                        continue;
                      }

                      await SQLHelper().updateFormField(
                        field[SQLHelper.columnFormFieldId],
                        title,
                        comment,
                        selectedOption,
                      );
                    }
                    Navigator.pop(context, {'formId': widget.formId, 'formTitle': _formTitleController.text});
                  },

                  child: Text("SAVE", style: TextStyle(color: Colors.white, fontSize: 20)),
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownMenuItem(String text, IconData icon) {
    Color? iconColor;

    switch (text) {
      case 'Radio Button':
        iconColor = Color(0xFFF7572D);
        break;
      case 'Delete':
        iconColor = Color(0xFFF7572D);
        break;
      case 'Comment':
        iconColor = Color(0xFFF7572D);
        break;
      default:
        iconColor = null;
    }

    return DropdownMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFormFields(int formId) async {
    Database db = await SQLHelper().database;
    return await db.query(
      SQLHelper.tableFormFields,
      where: '${SQLHelper.columnFormFieldFormId} = ?',
      whereArgs: [formId],
    );
  }
}
