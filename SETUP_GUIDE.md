# دليل الإعداد والتثبيت - Setup Guide

## نظام إدارة المدرسة - School Management System

هذا الدليل يشرح خطوات تثبيت وتشغيل تطبيق نظام إدارة المدرسة على جهازك.

---

## المتطلبات الأساسية

قبل البدء، تأكد من أن لديك:

1. **Flutter SDK**: تحميل من https://flutter.dev/docs/get-started/install
2. **Dart SDK**: يأتي تلقائياً مع Flutter
3. **محرر نصوص**: VS Code أو Android Studio
4. **محاكي أو جهاز فعلي**: لتشغيل التطبيق

---

## خطوات التثبيت

### الخطوة 1: تثبيت Flutter

#### على Windows:
1. قم بتحميل Flutter من الموقع الرسمي
2. استخرج الملف في مكان آمن (مثل C:\flutter)
3. أضف مسار Flutter إلى متغيرات البيئة (PATH)
4. افتح Command Prompt وتحقق:
   ```bash
   flutter --version
   ```

#### على macOS:
```bash
# استخدم Homebrew
brew install flutter

# أو قم بالتحميل اليدوي من الموقع الرسمي
# ثم أضفه إلى ~/.zshrc أو ~/.bash_profile
export PATH="$PATH:[path_to_flutter]/bin"
```

#### على Linux:
```bash
# تحميل Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_[version].tar.xz

# استخراج الملف
tar xf flutter_linux_[version].tar.xz

# إضافة المسار
export PATH="$PATH:$HOME/flutter/bin"
```

### الخطوة 2: التحقق من التثبيت

```bash
flutter doctor
```

هذا الأمر سيتحقق من جميع المتطلبات ويخبرك بأي مشاكل.

### الخطوة 3: استنساخ أو نسخ المشروع

```bash
# إذا كان لديك Git
git clone [repository_url]
cd school_management_app

# أو انسخ المجلد مباشرة
```

### الخطوة 4: تثبيت الاعتماديات

```bash
cd school_management_app
flutter pub get
```

### الخطوة 5: تشغيل التطبيق

#### على محاكي Android:
```bash
flutter run
```

#### على جهاز iOS (macOS فقط):
```bash
flutter run
```

#### على متصفح الويب:
```bash
flutter run -d chrome
```

#### على جهاز فعلي:
1. قم بتوصيل جهازك عبر USB
2. فعّل وضع المطور على جهازك
3. شغّل:
   ```bash
   flutter run
   ```

---

## بيانات الدخول الافتراضية

### حساب المدير
- **اسم المستخدم**: `mohamed esam`
- **كلمة المرور**: `1234`
- **الدور**: مدير

---

## استكشاف الأخطاء الشائعة

### المشكلة: "flutter: command not found"
**الحل**: 
- تأكد من إضافة Flutter إلى متغيرات البيئة
- أعد تشغيل Terminal أو Command Prompt

### المشكلة: "No devices found"
**الحل**:
- تأكد من تشغيل محاكي Android أو iOS
- أو قم بتوصيل جهاز فعلي
- شغّل: `flutter devices`

### المشكلة: "Gradle build failed"
**الحل**:
```bash
flutter clean
flutter pub get
flutter run
```

### المشكلة: خطأ في قاعدة البيانات
**الحل**:
```bash
# حذف التطبيق من المحاكي
adb uninstall com.school.management

# إعادة تشغيل التطبيق
flutter run
```

### المشكلة: "Android SDK not found"
**الحل**:
```bash
flutter config --android-sdk [path_to_android_sdk]
```

---

## هيكل المشروع

```
school_management_app/
├── lib/
│   ├── main.dart                      # نقطة الدخول الرئيسية
│   ├── services/
│   │   ├── database_service.dart      # إدارة قاعدة البيانات
│   │   └── auth_provider.dart         # إدارة المصادقة
│   └── screens/
│       ├── login_screen.dart          # شاشة تسجيل الدخول
│       ├── admin_dashboard.dart       # لوحة تحكم المدير
│       ├── teacher_dashboard.dart     # لوحة تحكم المعلم
│       └── student_dashboard.dart     # لوحة تحكم الطالب
├── pubspec.yaml                       # ملف الاعتماديات
├── README.md                          # ملف التوثيق الرئيسي
└── SETUP_GUIDE.md                     # هذا الملف
```

---

## استخدام التطبيق

### كمدير

**تسجيل الدخول**:
1. اختر "مدير" من الخيارات الثلاثة
2. أدخل بيانات الدخول الافتراضية

**الميزات المتاحة**:
- إضافة معلمين جدد
- إضافة طلاب جدد
- إنشاء فصول دراسية
- إدارة الجدول الدراسي
- إدارة لوحات رؤساء المواد والمعامل

**مثال: إضافة معلم**:
1. انقر على "إضافة معلم"
2. أدخل البيانات التالية:
   - الاسم: "أحمد محمد"
   - اسم المستخدم: "ahmed_teacher"
   - كلمة المرور: "password123"
   - المادة: "عربي"
3. انقر على "إضافة معلم"

### كمعلم

**تسجيل الدخول**:
1. اختر "معلم"
2. أدخل بيانات دخول المعلم

**الميزات المتاحة**:
- عرض الفصول المسندة
- إدارة درجات الطلاب
- تسجيل الحضور والغياب

**مثال: إضافة درجة**:
1. انقر على "إدارة الدرجات"
2. اختر الفصل
3. اختر الطالب والمادة
4. أدخل الدرجة
5. انقر على "إضافة درجة"

### كطالب

**تسجيل الدخول**:
1. اختر "طالب"
2. أدخل بيانات دخول الطالب

**الميزات المتاحة**:
- عرض الجدول الدراسي
- عرض الدرجات والمعدل
- عرض سجل الحضور والغياب

---

## نصائح مهمة

1. **الحفظ التلقائي**: جميع البيانات تُحفظ تلقائياً في قاعدة البيانات المحلية

2. **الأمان**: كلمات المرور مخزنة بشكل آمن (يمكن تحسينها بتشفير في الإصدارات المستقبلية)

3. **الأداء**: التطبيق محسّن للعمل على الأجهزة الضعيفة

4. **الاستجابة**: الواجهة مستجيبة وتدعم جميع أحجام الشاشات

---

## الإعدادات المتقدمة

### تغيير اسم التطبيق

في `pubspec.yaml`:
```yaml
name: school_management_app
description: نظام إدارة المدرسة
```

### تغيير الألوان الأساسية

في `lib/main.dart`:
```dart
theme: ThemeData(
  primarySwatch: Colors.blue,  // غيّر اللون هنا
)
```

### إضافة أيقونة التطبيق

1. ضع صورة بحجم 192x192 في `assets/images/icon.png`
2. استخدم أداة مثل `flutter_launcher_icons`

---

## الدعم والمساعدة

إذا واجهت أي مشاكل:

1. تحقق من `flutter doctor` للتأكد من التثبيت الصحيح
2. اقرأ رسائل الخطأ بعناية
3. جرب `flutter clean` و `flutter pub get` من جديد
4. تحقق من أن لديك أحدث إصدار من Flutter

---

## المراجع المفيدة

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [SQLite Flutter Package](https://pub.dev/packages/sqflite)
- [Provider Package](https://pub.dev/packages/provider)

---

**آخر تحديث**: ديسمبر 2024
