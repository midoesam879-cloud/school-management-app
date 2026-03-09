import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_service.dart';

class StudentViewAttendance extends StatefulWidget {
  const StudentViewAttendance({Key? key}) : super(key: key);

  @override
  State<StudentViewAttendance> createState() => _StudentViewAttendanceState();
}

class _StudentViewAttendanceState extends State<StudentViewAttendance> {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _attendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final studentId = auth.currentUser?['id'];

    if (studentId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final data = await _dbService.getStudentAttendance(studentId);

    setState(() {
      _attendance = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'الحضور والغياب',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_attendance.isEmpty)
            const Center(child: Text('لا توجد سجلات حضور'))
          else
            Column(
              children: [
                _buildSummary(),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _attendance.length,
                  itemBuilder: (context, index) {
                    final record = _attendance[index];

                    final status =
                    (record['status'] ?? 'غير مسجل').toString();
                    final subjectName =
                    (record['subjectName'] ?? 'غير معروف').toString();
                    final teacherName =
                    (record['teacherName'] ?? 'غير معروف').toString();

                    DateTime? date;
                    if (record['date'] != null) {
                      date = DateTime.tryParse(record['date'].toString());
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 4,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color:
                          _statusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subjectName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'التاريخ: ${date != null ? date.toLocal().toString().split(' ')[0] : 'غير محدد'}',
                                ),
                                const SizedBox(height: 4),
                                Text('المعلم: $teacherName'),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _statusColor(status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// ---------- SUMMARY ----------
  Widget _buildSummary() {
    final present =
        _attendance.where((a) => (a['status'] ?? '') == 'حاضر').length;
    final absent =
        _attendance.where((a) => (a['status'] ?? '') == 'غائب').length;
    final late =
        _attendance.where((a) => (a['status'] ?? '') == 'متأخر').length;

    final total = _attendance.length;
    final percent =
    total == 0 ? 0 : (present / total * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الحضور',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 15),
            _row('إجمالي الحصص:', total.toString()),
            _row('حاضر:', present.toString(), color: Colors.green),
            _row('غائب:', absent.toString(), color: Colors.red),
            _row('متأخر:', late.toString(), color: Colors.orange),
            const SizedBox(height: 10),
            _row('نسبة الحضور:', '$percent%',
                color: Colors.blue, big: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {Color? color, bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: big ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'حاضر':
        return Colors.green;
      case 'غائب':
        return Colors.red;
      case 'متأخر':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
