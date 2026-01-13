import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignMurabiScreen extends StatefulWidget {
  @override
  _AssignMurabiScreenState createState() => _AssignMurabiScreenState();
}

class _AssignMurabiScreenState extends State<AssignMurabiScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSalikId;
  String? _selectedMurabiId;
  bool _isLoading = false;

  Future<void> _assignMurabi() async {
    if (_selectedSalikId == null || _selectedMurabiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سالک اور مربی دونوں منتخب کریں')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('users').doc(_selectedSalikId).update({
        'assignedMurabiId': _selectedMurabiId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('مربی کامیابی سے assign ہوگیا'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedSalikId = null;
          _selectedMurabiId = null;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خرابی: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سالک کو مربی assign کریں'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'موجود سالکین میں سے کسی کو مربی assign کریں',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoNastaliq',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            // Salik Dropdown
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'salik')
                  .snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem<String>> salikItems = [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'خرابی: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'نام نہیں';
                    salikItems.add(
                      DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(
                          name,
                          style: TextStyle(fontFamily: 'NotoNastaliq'),
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedSalikId,
                    decoration: InputDecoration(
                      labelText: 'سالک منتخب کریں',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: salikItems,
                    onChanged: (value) {
                      setState(() => _selectedSalikId = value);
                    },
                  );
                } else {
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'کوئی سالک دستیاب نہیں',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 20),

            // Murabi Dropdown
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'murabi')
                  .snapshots(),
              builder: (context, snapshot) {
                List<DropdownMenuItem<String>> murabiItems = [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'خرابی: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'نام نہیں';
                    murabiItems.add(
                      DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(
                          name,
                          style: TextStyle(fontFamily: 'NotoNastaliq'),
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedMurabiId,
                    decoration: InputDecoration(
                      labelText: 'مربی منتخب کریں',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: murabiItems,
                    onChanged: (value) {
                      setState(() => _selectedMurabiId = value);
                    },
                  );
                } else {
                  return Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Text(
                      'کوئی مربی دستیاب نہیں\nپہلے مربی شامل کریں',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontFamily: 'NotoNastaliq',
                      ),
                    ),
                  );
                }
              },
            ),

            SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _assignMurabi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Assign کریں',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
