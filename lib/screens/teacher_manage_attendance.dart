import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_service.dart';

class TeacherManageAttendance extends StatefulWidget {
  const TeacherManageAttendance({Key? key}) : super(key: key);

  @override
  State<TeacherManageAttendance> createState() =>
      _TeacherManageAttendanceState();
}

class _TeacherManageAttendanceState extends State<TeacherManageAttendance> {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];

  int? _selectedClassId;
  DateTime _selectedDate = DateTime.now();

  Map<int, String> _attendance = {};
  bool _isLoading = false;

  int? _teacherId;
  int? _subjectId;
  String? _subjectName;

  @override
  void initState() {
    super.initState();
    _initTeacher();
  }

  Future<void> _initTeacher() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    _teacherId = user['id'];
    _subjectName = user['subject'];
    _subjectId = await _dbService.getSubjectIdByName(_subjectName!);

    final classes = await _dbService.getTeacherClasses(_teacherId!);
    setState(() => _classes = classes);
  }

  Future<void> _loadStudents(int classId) async {
    final students = await _dbService.getClassStudents(classId);
    setState(() {
      _students = students;
      _attendance = {
        for (var s in students) s['id'] as int: 'حاضر',
      };
    });
  }

  Future<void> _saveAttendance() async {
    if (_teacherId == null ||
        _subjectId == null ||
        _selectedClassId == null) {
      _showMsg('يرجى اختيار الفصل');
      return;
    }

    final date =
    _selectedDate.toIso8601String().split('T')[0]; // ✅ String

    setState(() => _isLoading = true);

    try {
      for (final entry in _attendance.entries) {
        final exists = await _dbService.hasAttendanceForDay(
          entry.key,
          _subjectId!,
          date,
        );

        if (exists) continue;

        await _dbService.addAttendance(
          entry.key,
          _teacherId!,
          _subjectId!,
          date,
          entry.value,
        );
      }

      _showMsg('تم حفظ حضور مادة $_subjectName');
    } catch (e) {
      _showMsg('حدث خطأ أثناء الحفظ');
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
          Text(
            'حضور وغياب مادة $_subjectName',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<int>(
            value: _selectedClassId,
            items: _classes
                .map(
                  (c) => DropdownMenuItem<int>(
                value: c['id'],
                child: Text(c['name']),
              ),
            )
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedClassId = v;
                _students.clear();
              });
              if (v != null) _loadStudents(v);
            },
            decoration: _input('اختر الفصل', Icons.class_),
          ),
          const SizedBox(height: 15),

          ListTile(
            title: Text(
              'التاريخ: ${_selectedDate.toString().split(' ')[0]}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _selectedDate = d);
            },
          ),

          const SizedBox(height: 20),

          if (_students.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _students.length,
              itemBuilder: (_, i) {
                final s = _students[i];
                final id = s['id'] as int;

                return Card(
                  child: ListTile(
                    title: Text(s['name']),
                    trailing: DropdownButton<String>(
                      value: _attendance[id],
                      items: const [
                        DropdownMenuItem(
                            value: 'حاضر', child: Text('حاضر')),
                        DropdownMenuItem(
                            value: 'غائب', child: Text('غائب')),
                        DropdownMenuItem(
                            value: 'متأخر', child: Text('متأخر')),
                      ],
                      onChanged: (v) =>
                          setState(() => _attendance[id] = v!),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isLoading ? null : _saveAttendance,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('حفظ الحضور'),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
