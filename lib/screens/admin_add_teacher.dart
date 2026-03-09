import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AdminAddTeacher extends StatefulWidget {
  const AdminAddTeacher({Key? key}) : super(key: key);

  @override
  State<AdminAddTeacher> createState() => _AdminAddTeacherState();
}

class _AdminAddTeacherState extends State<AdminAddTeacher> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedSubject;

  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _teachers = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _loadTeachers();
  }

  Future<void> _loadSubjects() async {
    final subjects = await _dbService.getAllSubjects();
    setState(() => _subjects = subjects);
  }

  Future<void> _loadTeachers() async {
    final teachers = await _dbService.getAllTeachers();
    setState(() => _teachers = teachers);
  }

  // ================= VALIDATORS =================

  bool _isValidName(String value) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(value);
  }

  bool _isValidUsername(String value) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF]+$').hasMatch(value);
  }

  bool _usernameExists(String username) {
    return _teachers.any((t) => t['username'] == username);
  }

  // ================= ADD TEACHER =================

  Future<void> _addTeacher() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        _selectedSubject == null) {
      _showMsg('يرجى ملء جميع الحقول');
      return;
    }

    if (!_isValidName(name)) {
      _showMsg('الاسم يجب أن يحتوي على حروف فقط');
      return;
    }

    if (!_isValidUsername(username)) {
      _showMsg('اسم المستخدم يجب أن يحتوي على حروف فقط');
      return;
    }

    if (_usernameExists(username)) {
      _showMsg('اسم المستخدم مستخدم من قبل');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbService.addTeacher(
        name,
        _selectedSubject!,
        username,
        password,
      );

      _nameController.clear();
      _usernameController.clear();
      _passwordController.clear();
      _selectedSubject = null;

      await _loadTeachers();

      _showMsg('تم إضافة المعلم بنجاح');
    } catch (e) {
      _showMsg('خطأ أثناء الإضافة');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'إضافة معلم / أخصائي',
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
                    _inputDecoration('الاسم', Icons.person),
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
                    value: _selectedSubject,
                    items: _subjects
                        .map(
                          (s) => DropdownMenuItem<String>(
                        value: s['name'],
                        child: Text(s['name']),
                      ),
                    )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSubject = value),
                    decoration:
                    _inputDecoration('المادة', Icons.book),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _addTeacher,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('حفظ'),
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
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }
}
