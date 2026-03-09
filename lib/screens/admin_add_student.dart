import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AdminAddStudent extends StatefulWidget {
  const AdminAddStudent({Key? key}) : super(key: key);

  @override
  State<AdminAddStudent> createState() => _AdminAddStudentState();
}

class _AdminAddStudentState extends State<AdminAddStudent> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedGrade;
  int? _selectedClassId;

  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];

  bool _isLoading = false;

  final List<String> _grades = [
    'الصف الأول الابتدائي',
    'الصف الثاني الابتدائي',
    'الصف الثالث الابتدائي',
    'الصف الرابع الابتدائي',
    'الصف الخامس الابتدائي',
    'الصف السادس الابتدائي',
    'الصف الأول الإعدادي',
    'الصف الثاني الإعدادي',
    'الصف الثالث الإعدادي',
    'الصف الأول الثانوي',
    'الصف الثاني الثانوي',
    'الصف الثالث الثانوي',
  ];

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    final classes = await _dbService.getAllClasses();
    setState(() => _classes = classes);
  }

  Future<void> _loadStudents() async {
    final students = await _dbService.getAllStudents();
    setState(() => _students = students);
  }

  bool _isValidName(String value) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(value);
  }

  bool _usernameExists(String username) {
    return _students.any((s) => s['username'] == username);
  }

  Future<void> _addStudent() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        _selectedGrade == null ||
        _selectedClassId == null) {
      _showMsg('يرجى ملء جميع الحقول');
      return;
    }

    if (!_isValidName(name)) {
      _showMsg('اسم الطالب يجب أن يحتوي على حروف فقط');
      return;
    }

    if (_usernameExists(username)) {
      _showMsg('اسم المستخدم مستخدم من قبل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbService.addStudent(
        name,
        username,
        password,
        _selectedGrade!,
        _selectedClassId!, // ✅ غير nullable
      );

      _nameController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _selectedGrade = null;
      _selectedClassId = null;

      await _loadStudents();
      _showMsg('تم إضافة الطالب بنجاح');
    } catch (e) {
      _showMsg('حدث خطأ أثناء الإضافة');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'إضافة طالب جديد',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration:
                    _inputDecoration('اسم الطالب', Icons.person),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _usernameController,
                    decoration: _inputDecoration(
                        'اسم المستخدم', Icons.account_circle),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration:
                    _inputDecoration('كلمة المرور', Icons.lock),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    items: _grades
                        .map(
                          (g) => DropdownMenuItem<String>(
                        value: g,
                        child: Text(g),
                      ),
                    )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedGrade = v),
                    decoration: _inputDecoration(
                        'اختر الصف الدراسي', Icons.school),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<int>(
                    value: _selectedClassId,
                    items: _classes
                        .map<DropdownMenuItem<int>>(
                          (c) => DropdownMenuItem<int>(
                        value: c['id'] as int,
                        child: Text(c['name']),
                      ),
                    )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedClassId = v),
                    decoration:
                    _inputDecoration('اختر الفصل', Icons.class_),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _addStudent,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('إضافة الطالب'),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
