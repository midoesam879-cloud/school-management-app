import 'package:flutter/material.dart';
import '../services/database_service.dart';

class AdminAddClass extends StatefulWidget {
  const AdminAddClass({Key? key}) : super(key: key);

  @override
  State<AdminAddClass> createState() => _AdminAddClassState();
}

class _AdminAddClassState extends State<AdminAddClass> {
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  String? _selectedGrade;

  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _classes = [];
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
  }

  Future<void> _loadClasses() async {
    final classes = await _dbService.getAllClasses();
    setState(() => _classes = classes);
  }

  Future<void> _addClass() async {
    final name = _nameController.text.trim();
    final capacityText = _capacityController.text.trim();

    if (name.isEmpty || _selectedGrade == null || capacityText.isEmpty) {
      _showMsg('يرجى ملء جميع الحقول');
      return;
    }

    final capacity = int.tryParse(capacityText);
    if (capacity == null) {
      _showMsg('السعة يجب أن تكون رقمًا');
      return;
    }

    if (capacity < 5) {
      _showMsg('لا يمكن إنشاء فصل بسعة أقل من 5 طلاب');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbService.addClass(name, _selectedGrade!, capacity);

      _nameController.clear();
      _capacityController.clear();
      setState(() => _selectedGrade = null);

      await _loadClasses();
      _showMsg('تم إضافة الفصل بنجاح');
    } catch (e) {
      _showMsg('حدث خطأ أثناء الإضافة');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteClass(int id) async {
    await _dbService.deleteClass(id);
    await _loadClasses();
    _showMsg('تم حذف الفصل');
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
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
            'إضافة فصل جديد',
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
                    _input('اسم الفصل', Icons.class_),
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
                    decoration:
                    _input('اختر الصف الدراسي', Icons.school),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration:
                    _input('السعة (عدد الطلاب)', Icons.people),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _addClass,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('إضافة الفصل'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            'قائمة الفصول',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 15),

          _classes.isEmpty
              ? const Center(child: Text('لا توجد فصول'))
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _classes.length,
            itemBuilder: (_, i) {
              final c = _classes[i];
              return Card(
                child: ListTile(
                  title: Text(c['name']),
                  subtitle: Text(
                    'الصف: ${c['gradeLevel']} | السعة: ${c['capacity']}',
                  ),
                  trailing: IconButton(
                    icon:
                    const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteClass(c['id']),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border:
      OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
