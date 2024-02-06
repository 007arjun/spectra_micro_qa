import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spectra_micro_qa/src/features/edit_batch/edit_batch_widget.dart';
import '../../../sql_helper.dart';

class ViewBatchWidget extends StatefulWidget {
  const ViewBatchWidget({Key? key}) : super(key: key);

  @override
  _ViewBatchWidgetState createState() => _ViewBatchWidgetState();
}

class _ViewBatchWidgetState extends State<ViewBatchWidget> {
  late Future<List<Map<String, dynamic>>> _batchData;

  @override
  void initState() {
    super.initState();
    _batchData = _getBranches();
  }

  Future<List<Map<String, dynamic>>> _getBranches() async {
    return await SQLHelper().getAllBranches();
  }

  void _navigateToEditBatch(Map<String, dynamic> batchDetails) async {
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBatchWidget(batchDetails: batchDetails),
      ),
    );

    if (updatedData != null) {
      await _batchData.then((batchData) {
        int index = batchData.indexWhere((element) => element[SQLHelper.columnBranchId] == batchDetails[SQLHelper.columnBranchId]);

        setState(() {
          _batchData = Future.value(List.from(batchData)..[index] = updatedData);
        });
      });
    }
  }
  Future<void> _deleteBatch(int batchId) async {
    try {
      await SQLHelper().deleteBatch(batchId);
      _refreshData();
    } catch (error) {
      print('Error deleting batch: $error');
    }
  }

  Future<void> _refreshData() async {
    try {
      List<Map<String, dynamic>> updatedData = await _getBranches();

      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _batchData = Future.value(updatedData);
      });
    } catch (error) {
      print('Error refreshing data: $error');
    }
  }
  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'View Batch',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFf7572d),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Card(
            color: Colors.white,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _batchData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No batch data available.'),
                  );
                } else {
                  final batchDetails = snapshot.data!;
                  return ListView.builder(
                    itemCount: batchDetails.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Batch Name: ${batchDetails[index]['name']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Batch Date: ${_formatDate(batchDetails[index]['date'])}'),
                              Text('Serial Number: ${batchDetails[index][SQLHelper.columnBranchSerialNumber]}'),
                              Text('Manufacturer: ${batchDetails[index]['manufacturer']}'),
                              Text('Quantity: ${batchDetails[index]['quantity']}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
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
                                _navigateToEditBatch(batchDetails[index]);
                              } else if (choice == 'Delete') {
                                await _deleteBatch(batchDetails[index][SQLHelper.columnBranchId]);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
