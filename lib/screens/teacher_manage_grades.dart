import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_service.dart';

class TeacherManageGrades extends StatefulWidget {
  const TeacherManageGrades({Key? key}) : super(key: key);

  @override
  State<TeacherManageGrades> createState() => _TeacherManageGradesState();
}

class _TeacherManageGradesState extends State<TeacherManageGrades> {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];

  int? _selectedClassId;
  int? _selectedStudentId;

  final _gradeController = TextEditingController();
  bool _isLoading = false;

  int? _teacherId;
  int? _teacherSubjectId;
  String? _teacherSubjectName;

  @override
  void initState() {
    super.initState();
    _initTeacher();
  }

  Future<void> _initTeacher() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null || user['id'] == null) return;

    _teacherId = user['id'] as int;
    _teacherSubjectName = user['subject'] as String;

    // ✅ نحول اسم المادة لـ subjectId
    _teacherSubjectId =
    await _dbService.getSubjectIdByName(_teacherSubjectName!);

    _loadData();
  }

  Future<void> _loadData() async {
    if (_teacherId == null) return;

    final classes = await _dbService.getTeacherClasses(_teacherId!);
    setState(() {
      _classes = classes;
    });
  }

  Future<void> _loadClassStudents(int classId) async {
    final students = await _dbService.getClassStudents(classId);
    setState(() {
      _students = students;
    });
  }

  Future<void> _addGrade() async {
    if (_selectedClassId == null ||
        _selectedStudentId == null ||
        _teacherSubjectId == null ||
        _gradeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbService.addGrade(
        _selectedStudentId!,
        _teacherId!,
        _teacherSubjectId!, // ✅ مادة المدرس فقط
        double.parse(_gradeController.text),
      );

      _gradeController.clear();
      setState(() {
        _selectedStudentId = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إضافة درجة $_teacherSubjectName بنجاح',
            ),
          ),
        );
      }
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
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_classes.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد فصول مسندة لهذا المدرس',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إدارة درجات مادة $_teacherSubjectName',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// CLASS
                  DropdownButtonFormField<int>(
                    value: _selectedClassId,
                    items: _classes
                        .map(
                          (c) => DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(c['name']),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                        _students = [];
                        _selectedStudentId = null;
                      });
                      if (value != null) {
                        _loadClassStudents(value);
                      }
                    },
                    decoration:
                    _inputDecoration('اختر الفصل', Icons.class_),
                  ),
                  const SizedBox(height: 15),

                  /// STUDENT
                  DropdownButtonFormField<int>(
                    value: _selectedStudentId,
                    items: _students
                        .map(
                          (s) => DropdownMenuItem<int>(
                        value: s['id'] as int,
                        child: Text(s['name']),
                      ),
                    )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedStudentId = value),
                    decoration:
                    _inputDecoration('اختر الطالب', Icons.person),
                  ),
                  const SizedBox(height: 15),

                  /// GRADE
                  TextField(
                    controller: _gradeController,
                    keyboardType: TextInputType.number,
                    decoration:
                    _inputDecoration('الدرجة', Icons.grade),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _addGrade,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('إضافة درجة'),
                  ),
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
    );
  }
}
