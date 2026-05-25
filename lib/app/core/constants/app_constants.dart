class AppConstants {
  static const String appName = 'نظام إدارة توزيع المساعدات الخيرية';
  static const String appVersion = '1.0.0';
  static const String dbName = 'khire_database.db';
  static const int dbVersion = 1;

  static const String defaultAdminUsername = 'admin';
  static const String defaultAdminPassword = 'admin123';
  static const String defaultAdminName = 'المدير العام';

  static const String roleAdmin = 'ADMIN';
  static const String roleUser = 'USER';

  static const String statusPending = 'PENDING';
  static const String statusPartial = 'PARTIAL';
  static const String statusReceived = 'RECEIVED';

  static const String pendingArabic = 'لم يستلم';
  static const String partialArabic = 'استلام جزئي';
  static const String receivedArabic = 'تم الاستلام';
}
