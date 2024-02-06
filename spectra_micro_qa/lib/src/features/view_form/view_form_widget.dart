import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spectra_micro_qa/src/features/edit_form/edit_form_Widget.dart';
import 'package:sqflite/sqflite.dart';
import '../../../sql_helper.dart';

class ViewFormWidget extends StatefulWidget {
  final int formId;

  ViewFormWidget({required this.formId});

  @override
  _ViewFormWidgetState createState() => _ViewFormWidgetState();
}

class _ViewFormWidgetState extends State<ViewFormWidget> {
  late int formId;
  late List<Map<String, dynamic>> formFields; // Declare formFields variable

  @override
  void initState() {
    super.initState();
    formId = widget.formId;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          'View Form',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFf7572d),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchFormDetails(formId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> formDetails = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(20.0),
                child: Card(
                  color: Colors.white,
                  elevation: 7,
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    width: screenWidth - 20,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Form Title: ${formDetails[SQLHelper.columnFormTitle]}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_note_outlined),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditFormWidget(
                                        formId: formId,
                                        formTitle: formDetails[SQLHelper.columnFormTitle],
                                      ),
                                    ),
                                  );

                                  if (result != null && result is Map<String, dynamic>) {
                                    if (result.containsKey('formId') && result.containsKey('formTitle')) {
                                      setState(() {
                                        formId = result['formId'];
                                      });

                                      formDetails = await fetchFormDetails(formId);

                                      List<Map<String, dynamic>> updatedFormFields = await fetchFormFields(formId);
                                      setState(() {
                                        formFields = updatedFormFields;
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Created On: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(formDetails[SQLHelper.columnFormCreatedOn]))}',
                        ),
                        SizedBox(height: 32),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: fetchFormFields(formId), // Fetch updated form fields
                          builder: (context, fieldSnapshot) {
                            if (fieldSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (fieldSnapshot.hasError) {
                              return Text('Error: ${fieldSnapshot.error}');
                            } else {
                              formFields = fieldSnapshot.data!; // Assign the value to formFields variable
                              String comment = '';
                              for (Map<String, dynamic> field in formFields) {
                                if (field[SQLHelper.columnFormFieldType] == 'Comment') {
                                  comment = field[SQLHelper.columnFormFieldSelectedOption];
                                  break;
                                }
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(formFields.length, (index) {
                                  Map<String, dynamic> field = formFields[index];
                                  int displayIndex = index + 1;

                                  String title = field[SQLHelper.columnFormFieldTitle];
                                  String fieldType = field[SQLHelper.columnFormFieldType];
                                  String value = '';

                                  if (fieldType == 'Radio Button') {
                                    String selectedOption = field[SQLHelper.columnFormFieldSelectedOption] ?? '';
                                    if (selectedOption.isNotEmpty) {
                                      value = selectedOption;
                                    }
                                  } else if (fieldType == 'Comment') {
                                    return FutureBuilder<String>(
                                      future: fetchComment(field[SQLHelper.columnFormFieldId]),
                                      builder: (context, commentSnapshot) {
                                        if (commentSnapshot.connectionState == ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (commentSnapshot.hasError) {
                                          return Text('Error: ${commentSnapshot.error}');
                                        }
                                        String comment = commentSnapshot.data ?? '';
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$displayIndex.$title: $comment',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            SizedBox(height: 7),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    value = field[SQLHelper.columnFormFieldSelectedOption] ?? '';
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$displayIndex.$title: $value',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 7),
                                    ],
                                  );
                                }),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
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

Future<String> fetchComment(int formFieldId) async {
  Database db = await SQLHelper().database;
  List<Map<String, dynamic>> comments = await db.query(
    SQLHelper.tableFormFields,
    where: '${SQLHelper.columnFormFieldId} = ?',
    whereArgs: [formFieldId],
  );

  return comments.isNotEmpty ? comments.first[SQLHelper.columnFormFieldComment] ?? '' : '';
}

Future<Map<String, dynamic>> fetchFormDetails(int formId) async {
  Database db = await SQLHelper().database;
  List<Map<String, dynamic>> formDetails = await db.query(
    SQLHelper.tableForms,
    where: '${SQLHelper.columnFormId} = ?',
    whereArgs: [formId],
  );

  if (formDetails.isNotEmpty) {
    List<Map<String, dynamic>> updatedDetails = await db.query(
      SQLHelper.tableForms,
      where: '${SQLHelper.columnFormId} = ?',
      whereArgs: [formId],
    );

    return updatedDetails.isNotEmpty ? updatedDetails.first : {};
  }

  return {};
}
