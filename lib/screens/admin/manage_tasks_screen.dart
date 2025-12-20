import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class ManageTasksScreen extends StatefulWidget {
  @override
  _ManageTasksScreenState createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxCountController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();

  String? _selectedLevel;
  String? _selectedCategory;
  bool _isCountable = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _maxCountController.text = '5';
  }

  Future<void> _addTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('براہ کرم سطح منتخب کریں')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.addTask(
        levelId: _selectedLevel!,
        taskName: _taskNameController.text,
        description: _descriptionController.text,
        category: _selectedCategory ?? 'عام',
        isCountable: _isCountable,
        maxCount: int.parse(_maxCountController.text),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('معمول کامیابی سے شامل ہوگیا')));

      _taskNameController.clear();
      _descriptionController.clear();
      _maxCountController.text = '5';
      _selectedCategory = null;
      _isCountable = false;
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
        title: Text('معمولات منیج کریں'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Add Task Form
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
                        'نیا معمول شامل کریں',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Level Dropdown
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _firestore.getAllLevels(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text('سطحیں لوڈ ہو رہی ہیں...');
                          }

                          return DropdownButtonFormField<String>(
                            value: _selectedLevel,
                            decoration: InputDecoration(
                              labelText: 'سطح منتخب کریں',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.layers),
                            ),
                            items: snapshot.data!.map((level) {
                              return DropdownMenuItem<String>(
                                value: level['id'] as String,
                                child: Text(level['levelName']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedLevel = value);
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      TextFormField(
                        controller: _taskNameController,
                        decoration: InputDecoration(
                          labelText: 'معمول کا نام',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.task),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'نام درج کریں' : null,
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
                        maxLines: 2,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'تفصیل درج کریں' : null,
                      ),
                      SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'قسم منتخب کریں',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: [
                          DropdownMenuItem(value: 'نماز', child: Text('نماز')),
                          DropdownMenuItem(
                            value: 'تلاوت',
                            child: Text('تلاوت'),
                          ),
                          DropdownMenuItem(value: 'ذکر', child: Text('ذکر')),
                          DropdownMenuItem(value: 'دعا', child: Text('دعا')),
                          DropdownMenuItem(value: 'عام', child: Text('عام')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                      SizedBox(height: 16),

                      // Countable Checkbox
                      CheckboxListTile(
                        title: Text('شمار ہو'),
                        value: _isCountable,
                        onChanged: (value) {
                          setState(() => _isCountable = value!);
                        },
                      ),

                      if (_isCountable)
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: TextFormField(
                            controller: _maxCountController,
                            decoration: InputDecoration(
                              labelText: 'زیادہ سے زیادہ تعداد',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty ?? true
                                ? 'تعداد درج کریں'
                                : null,
                          ),
                        ),

                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _maxCountController.dispose();
    super.dispose();
  }
}
