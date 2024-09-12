import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'models/fabric_model.dart';


class FabricPage extends StatefulWidget {
  @override
  _FabricPageState createState() => _FabricPageState();
}


class _FabricPageState extends State<FabricPage> {
  String? selectedStatus = "Pending";
  DateTime? fromDate;
  DateTime? toDate;
  List<FabricItem> fabricItems = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (fromDate == null || toDate == null) {
      // Show a message if dates are not selected
      return;
    }

    try {
      final fromDateStr = DateFormat('dd-MM-yyyy').format(fromDate!);
      final toDateStr = DateFormat('dd-MM-yyyy').format(toDate!);
      final response = await http.get(Uri.parse(
          'http://118.179.223.41:7007/ords/xact_erp/approval/D_FAb_book_approved_list?P_APP_TYPE=1&G_USER_ID=1&P_FROM_DATE=$fromDateStr&P_TO_DATE=$toDateStr'));

      if (response.statusCode == 200) {
        setState(() {
          // Parse the response body and convert it to List<FabricItem>
          final data = jsonDecode(response.body);
          fabricItems = (data['items'] as List)
              .map((item) => FabricItem.fromJson(item))
              .toList();
        });
      } else {
        // Handle server error
        print('Failed to load data');
      }
    } catch (e) {
      // Handle network error
      print('Error fetching data: $e');
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year, // Open with year selection
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
      fetchData(); // Fetch data after selecting the from date
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year, // Open with year selection
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
      fetchData(); // Fetch data after selecting the to date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fabric List"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),  // Back arrow icon
          onPressed: () {
            Navigator.pop(context);  // Go back to the previous screen
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusTab("Pending", selectedStatus == "Pending"),
                _buildStatusTab("Approved", selectedStatus == "Approved"),
                _buildStatusTab("Cancel", selectedStatus == "Cancel"),
              ],
            ),
            SizedBox(height: 16),
            // Date pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => _selectFromDate(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          primary: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              fromDate == null
                                  ? 'Select Date'
                                  : DateFormat('yyyy-MM-dd').format(fromDate!),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('To Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => _selectToDate(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          primary: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              toDate == null
                                  ? 'Select Date'
                                  : DateFormat('yyyy-MM-dd').format(toDate!),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Display API data as cards
            Expanded(
              child: _getFilteredFabricItems().isEmpty
                  ? Center(child: Text('No requests available'))
                  : ListView.builder(
                itemCount: _getFilteredFabricItems().length,
                itemBuilder: (context, index) {
                  var item = _getFilteredFabricItems()[index];
                  return _buildRequisitionCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build status tab button
  Widget _buildStatusTab(String status, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Build requisition card
  Widget _buildRequisitionCard(FabricItem item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requisition: ${item.bookNo}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 4),
            Text('Merchandiser: ${item.merchandiser}'),
            Text('Supplier: ${item.supplier}'),
            Text('Buyer: ${item.buyerName}'),
            Text('Item Type: ${item.itemType}'),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(item.status == 2 ? 'Pending' : item.status == 1 ? 'Approved' : 'Cancelled'),
                Row(
                  children: [
                    _buildActionButton(item.status == 2 ? "Approve" : "Approve", Colors.green, () {
                      if (item.status == 2) {
                        setState(() {
                          item.status = 1; // Change status to Approved
                        });
                      }
                    }),
                    SizedBox(width: 8),
                    _buildActionButton(item.status == 2 ? "Reject" : "Cancel", Colors.red, () {
                      if (item.status == 2) {
                        setState(() {
                          item.status = 3; // Change status to Cancelled
                        });
                      }
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build status badge
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: status == "Pending" ? Colors.orange : status == "Approved" ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Build Approve/Reject button
  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    );
  }

  // Get filtered list of items based on the selected status
  List<FabricItem> _getFilteredFabricItems() {
    if (selectedStatus == "Pending") {
      return fabricItems.where((item) => item.status == 2).toList();
    } else if (selectedStatus == "Approved") {
      return fabricItems.where((item) => item.status == 1).toList();
    } else if (selectedStatus == "Cancel") {
      return fabricItems.where((item) => item.status == 3).toList();
    }
    return [];
  }
}

