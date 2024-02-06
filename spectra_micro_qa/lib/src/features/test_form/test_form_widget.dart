import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spectra_micro_qa/src/features/create_form/create_form_widget.dart';
import 'package:spectra_micro_qa/src/features/view_form/view_form_widget.dart';
import '../../../sql_helper.dart';
import '../home_screen_admin/home_screen_admin_widget.dart';

class TestFormWidget extends StatefulWidget {
  final Product product;

  TestFormWidget({required this.product});

  @override
  TestFormPageState createState() => TestFormPageState();
}

class TestFormPageState extends State<TestFormWidget> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> formsData = [];

  @override
  void initState() {
    super.initState();
    _loadFormsData();
  }

  Future<void> _loadFormsData() async {
    List<Map<String, dynamic>> forms = await SQLHelper().getAllForms();
    setState(() {
      formsData = forms;
    }
    );
  }

  Future<void> _refreshData() async {
    await _loadFormsData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFf7572d),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      ),
      body: Center(
        child: Container(
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Text(
                    'Test Form',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      itemCount: formsData.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewFormWidget(
                                  formId: formsData[index][SQLHelper.columnFormId],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${formsData[index][SQLHelper.columnFormTitle]}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Created On :${DateFormat('dd-MM-yyyy').format(DateTime.parse(formsData[index][SQLHelper.columnFormCreatedOn]))}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 80.0,
        height: 80.0,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateFormWidget(product: widget.product),
              ),
            );
          },
          child: Icon(Icons.add, color: Colors.white, size: 40.0),
          backgroundColor: Color(0xFFf7572d),
          shape: CircleBorder(),
        ),
      ),
    );
  }
}
