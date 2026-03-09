import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_service.dart';

class StudentViewSchedule extends StatefulWidget {
  const StudentViewSchedule({Key? key}) : super(key: key);

  @override
  State<StudentViewSchedule> createState() => _StudentViewScheduleState();
}

class _StudentViewScheduleState extends State<StudentViewSchedule> {
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _schedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classId = authProvider.currentUser?['classId'];

    if (classId != null) {
      final schedule = await _dbService.getClassSchedule(classId);
      setState(() {
        _schedule = schedule;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
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
            'الجدول الدراسي',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_schedule.isEmpty)
            const Center(child: Text('لا توجد حصص مسجلة'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _schedule.length,
              itemBuilder: (context, index) {
                final item = _schedule[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // المادة + اليوم
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['subject'] ?? 'غير معروف',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Chip(
                              label: Text(
                                item['dayOfWeek'] ?? '—',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // المعلم
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'المعلم: ${item['teacher'] ?? 'غير معروف'}',
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // الحصة
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'الحصة رقم: ${item['period']?.toString() ?? '-'}',
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
