import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AdminManageSchedule extends StatefulWidget {
  const AdminManageSchedule({Key? key}) : super(key: key);

  @override
  State<AdminManageSchedule> createState() => _AdminManageScheduleState();
}

class _AdminManageScheduleState extends State<AdminManageSchedule> {
  final DatabaseService _dbService = DatabaseService();

  int? _selectedClassId;
  int? _selectedTeacherId;
  int? _selectedPeriod;
  String? _selectedDay;

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _schedules = [];

  bool _isLoading = false;

  final List<String> _days = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  final List<int> _periods = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final classes = await _dbService.getAllClasses();
    final teachers = await _dbService.getAllTeachers();

    setState(() {
      _classes = classes;
      _teachers = teachers;
    });
  }

  Future<void> _loadSchedule() async {
    if (_selectedClassId == null) return;

    final schedules = await _dbService.getClassSchedule(_selectedClassId!);
    setState(() {
      _schedules = schedules;
    });
  }

  Future<void> _addSchedule() async {
    if (_selectedClassId == null ||
        _selectedTeacherId == null ||
        _selectedDay == null ||
        _selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      /// 📌 المادة تيجي تلقائي من المدرس
      final teacher = _teachers.firstWhere(
            (t) => t['id'] == _selectedTeacherId,
      );

      final subjectName = teacher['subject'] as String;
      final subjectId =
      await _dbService.getSubjectIdByName(subjectName);

      /// 1️⃣ إضافة الحصة
      await _dbService.addSchedule(
        _selectedClassId!,
        _selectedTeacherId!,
        subjectId,
        _selectedDay!,
        _selectedPeriod!,
      );

      /// 2️⃣ ربط المدرس بالفصل
      await _dbService.assignTeacherToClass(
        _selectedClassId!,
        _selectedTeacherId!,
        subjectName,
      );

      setState(() {
        _selectedTeacherId = null;
        _selectedDay = null;
        _selectedPeriod = null;
      });

      await _loadSchedule();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الحصة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
            'إدارة الجدول الدراسي',
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
                      setState(() => _selectedClassId = v);
                      if (v != null) _loadSchedule();
                    },
                    decoration:
                    _inputDecoration('اختر الفصل', Icons.class_),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<int>(
                    value: _selectedTeacherId,
                    items: _teachers
                        .map(
                          (t) => DropdownMenuItem<int>(
                        value: t['id'],
                        child: Text(
                          '${t['name']} (${t['subject']})',
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTeacherId = v),
                    decoration:
                    _inputDecoration('اختر المعلم', Icons.person),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    items: _days
                        .map(
                          (d) => DropdownMenuItem<String>(
                        value: d,
                        child: Text(d),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDay = v),
                    decoration:
                    _inputDecoration('اختر اليوم', Icons.calendar_today),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<int>(
                    value: _selectedPeriod,
                    items: _periods
                        .map(
                          (p) => DropdownMenuItem<int>(
                        value: p,
                        child: Text('الحصة $p'),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPeriod = v),
                    decoration:
                    _inputDecoration('اختر الحصة', Icons.schedule),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _addSchedule,
                    child: const Text('إضافة حصة'),
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
