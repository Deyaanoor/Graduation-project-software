// يتم استيراد نسخة FCM المناسبة حسب المنصة
export 'mobile_fcm_setup.dart' if (dart.library.html) 'web_fcm_setup.dart';
