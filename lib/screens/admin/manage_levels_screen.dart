import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class ManageLevelsScreen extends StatefulWidget {
  @override
  _ManageLevelsScreenState createState() => _ManageLevelsScreenState();
}

class _ManageLevelsScreenState extends State<ManageLevelsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _levelNameController = TextEditingController();
  final _levelNumberController = TextEditingController();
  final _daysRequiredController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();

  bool _isLoading = false;

  Future<void> _addLevel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.addLevel(
        levelName: _levelNameController.text,
        levelNumber: int.parse(_levelNumberController.text),
        daysRequired: int.parse(_daysRequiredController.text),
        description: _descriptionController.text,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('سطح کامیابی سے شامل ہوگئی')));

      _levelNameController.clear();
      _levelNumberController.clear();
      _daysRequiredController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خرابی: ${e.toString()}')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سطحیں منیج کریں'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Add Level Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نئی سطح شامل کریں',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _levelNameController,
                        decoration: InputDecoration(
                          labelText: 'سطح کا نام',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.layers),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'نام درج کریں' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _levelNumberController,
                        decoration: InputDecoration(
                          labelText: 'سطح نمبر',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'نمبر درج کریں' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _daysRequiredController,
                        decoration: InputDecoration(
                          labelText: 'مقررہ دن (مثلاً 40)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'دن درج کریں' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'تفصیل',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addLevel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'شامل کریں',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // List of Levels
            Text(
              'موجودہ سطحیں',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestore.getAllLevels(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('کوئی سطح موجود نہیں'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var level = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${level['levelNumber']}'),
                        ),
                        title: Text(level['levelName']),
                        subtitle: Text('${level['daysRequired']} دن'),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _levelNameController.dispose();
    _levelNumberController.dispose();
    _daysRequiredController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
