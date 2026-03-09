import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'admin_add_teacher.dart';
import 'admin_add_student.dart';
import 'admin_add_class.dart';
import 'admin_manage_schedule.dart';
import 'admin_social_worker_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildContent(),
    );
  }

  // ================= Drawer =================
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade700),
            child: Consumer<AuthProvider>(
              builder: (_, auth, __) {
                return Column(
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
                    Text(
                      'مرحبًا ${auth.currentUser?['fullName'] ?? 'المدير'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
          _drawerItem(0, Icons.dashboard, 'الصفحة الرئيسية'),
          _drawerItem(1, Icons.person_add, 'إضافة معلم'),
          _drawerItem(2, Icons.school, 'إضافة طالب'),
          _drawerItem(3, Icons.class_, 'إضافة فصل'),
          _drawerItem(4, Icons.schedule, 'إدارة الجدول'),
          const Divider(),
          _drawerItem(5, Icons.people, 'لوحة الأخصائي الاجتماعي'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  // ================= Content =================
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 1:
        return const AdminAddTeacher();
      case 2:
        return const AdminAddStudent();
      case 3:
        return const AdminAddClass();
      case 4:
        return const AdminManageSchedule();
      case 5:
        return const AdminSocialWorkerDashboard();
      default:
        return _buildHomePage();
    }
  }

  // ================= Home =================
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'مرحبًا بك في نظام إدارة المدرسة',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 30),
          _statCard('المعلمون', Icons.person, Colors.blue),
          const SizedBox(height: 15),
          _statCard('الطلاب', Icons.school, Colors.green),
          const SizedBox(height: 15),
          _statCard('الفصول', Icons.class_, Colors.orange),
        ],
      ),
    );
  }

  Widget _statCard(String title, IconData icon, Color color) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getStatData(title),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final count = snapshot.data?.length ?? 0;

        return Card(
          elevation: 4,
          child: ListTile(
            leading: Icon(icon, size: 40, color: color),
            title: Text(title),
            trailing: Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getStatData(String type) async {
    if (type == 'المعلمون') {
      return _dbService.getAllTeachers();
    } else if (type == 'الطلاب') {
      return _dbService.getAllStudents();
    } else if (type == 'الفصول') {
      return _dbService.getAllClasses();
    }
    return [];
  }
}
