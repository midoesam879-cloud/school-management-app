import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'teacher_manage_grades.dart';
import 'teacher_manage_attendance.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];

  int? _teacherId;

  @override
  void initState() {
    super.initState();
    _initTeacher();
  }

  void _initTeacher() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null || user['id'] == null) {
      return;
    }

    _teacherId = user['id'] as int;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_teacherId == null) return;

    final classes = await _dbService.getTeacherClasses(_teacherId!);
    setState(() {
      _classes = classes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المعلم'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildContent(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'نظام إدارة المدرسة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Text(
                      'مرحبا ${authProvider.currentUser?['name'] ?? 'المعلم'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildDrawerItem(0, Icons.dashboard, 'الصفحة الرئيسية'),
          _buildDrawerItem(1, Icons.grade, 'إدارة الدرجات'),
          _buildDrawerItem(2, Icons.check_circle, 'إدارة الحضور والغياب'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const TeacherManageGrades();
      case 2:
        return const TeacherManageAttendance();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Text(
                'مرحبا ${authProvider.currentUser?['name'] ?? 'المعلم'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              );
            },
          ),
          const SizedBox(height: 10),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Text(
                'المادة: ${authProvider.currentUser?['subject'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                textDirection: TextDirection.rtl,
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            'فصولك الدراسية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 15),

          _classes.isEmpty
              ? const Center(child: Text('لا توجد فصول مسندة إليك'))
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _classes.length,
            itemBuilder: (context, index) {
              final classItem = _classes[index];
              final classId = classItem['id'] as int;

              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  title: Text(classItem['name']),
                  subtitle: Text(
                    'الصف: ${classItem['gradeLevel']} | المادة: ${classItem['subject']}',
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    _loadClassStudents(classId);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadClassStudents(int classId) async {
    final students = await _dbService.getClassStudents(classId);
    setState(() {
      _students = students;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('عدد الطلاب: ${students.length}')),
      );
    }
  }
}
