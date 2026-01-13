import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSalikScreen extends StatefulWidget {
  @override
  _AddSalikScreenState createState() => _AddSalikScreenState();
}

class _AddSalikScreenState extends State<AddSalikScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _hidePassword = true;
  String? _selectedMurabiId;

  Future<void> _addSalik() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمام فیلڈز بھریں')),
      );
      return;
    }

    if (_selectedMurabiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مربی منتخب کریں')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Create user in Firebase Auth
      print('Creating Firebase Auth account...');
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;
      print('Auth account created: $uid');

      // Step 2: Save directly to Firestore
      print('Saving to Firestore...');
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': 'salik',
        'assignedMurabiId': _selectedMurabiId,
        'level': 1,
        'currentDay': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Salik saved successfully with Murabi: $_selectedMurabiId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('سالک کامیابی سے شامل ہوگیا'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      print('Auth Error: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خرابی: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: Text('سالک شامل کریں'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'نام',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'نام درج کریں' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'ای میل',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'ای میل درج کریں' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'فون نمبر',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'فون نمبر درج کریں' : null,
              ),
              SizedBox(height: 16),
              // Password Field - NEW
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'پاس ورڈ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                    child: Icon(
                      _hidePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: _hidePassword,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'پاس ورڈ درج کریں';
                  }
                  if (value!.length < 6) {
                    return 'پاس ورڈ کم از کم 6 حروف ہونا چاہیے';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Murabi Dropdown with real-time Firestore
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .where('role', isEqualTo: 'murabi')
                    .snapshots(),
                builder: (context, snapshot) {
                  List<DropdownMenuItem<String>> murabiItems = [];

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DropdownButtonFormField<String>(
                      value: _selectedMurabiId,
                      decoration: InputDecoration(
                        labelText: 'مربی منتخب کریں',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.group),
                      ),
                      items: [],
                      onChanged: null,
                      hint: Text('لوڈ ہو رہا ہے...'),
                    );
                  }

                  if (snapshot.hasError) {
                    print('Snapshot error: ${snapshot.error}');
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

                  if (snapshot.hasData) {
                    print(
                        'Snapshot has ${snapshot.data!.docs.length} Murabis');
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
                  }

                  if (murabiItems.isEmpty) {
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
                    validator: (value) =>
                        value == null ? 'مربی منتخب کریں' : null,
                  );
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addSalik,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'شامل کریں',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
