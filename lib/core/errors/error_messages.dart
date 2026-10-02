import 'package:darb/core/errors/errors_code.dart';

/// رسائل الأخطاء المحلية (التطبيق عربي فقط).
/// تُستخدم عندما لا يرسل السيرفر رسالة خطأ، أو عند أخطاء الشبكة.
const Map<ErrorCode, String> errorMessages = {
  ErrorCode.UNAUTHENTICATED: 'أنت غير مصرح لك.',
  ErrorCode.FORBIDDEN: 'تم رفض الوصول.',
  ErrorCode.BAD_REQUEST: 'الطلب يحوي معلومات خاطئة.',
  ErrorCode.NOT_FOUND: 'لم يتم العثور على العنصر المراد.',
  ErrorCode.NO_INTERNET_CONNECTION: 'لا يوجد اتصال بالإنترنت.',
  ErrorCode.TIMEOUT: 'انتهت مهلة الطلب.',
  ErrorCode.SERVER_ERROR: 'حدث خطأ في الخادم.',
  ErrorCode.EXIST: 'المورد موجود مسبقًا.',
  ErrorCode.NOT_EXIST_ACCOUNT: 'الحساب غير موجود.',
  ErrorCode.APP_ERROR: 'حدث خطأ في معالجة الرد.',
  ErrorCode.USER_DATA_NOT_FOUND: 'لم يتم العثور على بيانات المستخدم.',
  ErrorCode.PENDING_APPROVAL: 'الحساب قيد المراجعة.',
  ErrorCode.UNPROCESSABLE_ENTITY: 'لا يمكن معالجة الطلب.',
  ErrorCode.TOO_MANY_REQUESTS: 'محاولات كثيرة، يرجى الانتظار قليلًا ثم المحاولة مجددًا.',
  ErrorCode.UNKNOWN: 'حدث خطأ غير معروف.',
  ErrorCode.CANCEL: 'تم إلغاء الطلب.',
  ErrorCode.BAD_CERTIFICATE: 'شهادة SSL غير صالحة.',
};

extension ErrorCodeLocalization on ErrorCode {
  String getLocalizedMessage() {
    return errorMessages[this] ?? errorMessages[ErrorCode.UNKNOWN]!;
  }
}
