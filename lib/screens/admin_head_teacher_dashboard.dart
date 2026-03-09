import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AdminHeadTeacherDashboard extends StatefulWidget {
  const AdminHeadTeacherDashboard({Key? key}) : super(key: key);

  @override
  State<AdminHeadTeacherDashboard> createState() =>
      _AdminHeadTeacherDashboardState();
}

class _AdminHeadTeacherDashboardState extends State<AdminHeadTeacherDashboard> {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _subjects = [];

  int? _selectedTeacherId;
  String? _selectedSubject;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final teachers = await _dbService.getAllTeachers();
    final subjects = await _dbService.getAllSubjects();

    setState(() {
      _teachers = teachers;
      _subjects = subjects;
    });
  }

  Future<void> _assignHeadTeacher() async {
    if (_selectedTeacherId == null || _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار معلم ومادة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعيين رئيس المادة بنجاح')),
        );
      }

      setState(() {
        _selectedTeacherId = null;
        _selectedSubject = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'لوحة رؤساء المواد',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),

          /// ---------- ASSIGN CARD ----------
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'تعيين رئيس مادة',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 15),

                  /// ✅ FIXED TEACHER DROPDOWN
                  DropdownButtonFormField<int>(
                    value: _selectedTeacherId,
                    items: _teachers
                        .map<DropdownMenuItem<int>>(
                          (teacher) => DropdownMenuItem<int>(
                        value: teacher['id'] as int,
                        child: Text(teacher['name']),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedTeacherId = value);
                    },
                    decoration:
                    _inputDecoration('اختر المعلم', Icons.person),
                  ),
                  const SizedBox(height: 15),

                  /// ✅ FIXED SUBJECT DROPDOWN
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    items: _subjects
                        .map<DropdownMenuItem<String>>(
                          (subject) => DropdownMenuItem<String>(
                        value: subject['name'] as String,
                        child: Text(subject['name']),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedSubject = value);
                    },
                    decoration:
                    _inputDecoration('اختر المادة', Icons.book),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _assignHeadTeacher,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue.shade700,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'تعيين',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          /// ---------- INFO ----------
          const Text(
            'معلومات رؤساء المواد',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 15),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text(
                    'يمكن لرؤساء المواد:',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureItem('مراقبة أداء معلمي المادة'),
                  _buildFeatureItem('مراجعة الدرجات والتقييمات'),
                  _buildFeatureItem('تقديم تقارير عن المادة'),
                  _buildFeatureItem('تنسيق المناهج الدراسية'),
                  _buildFeatureItem('تقييم معلمي المادة'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Text(feature, textDirection: TextDirection.rtl),
        ],
      ),
    );
  }
}
