import 'package:darb/core/errors/errors_code.dart';

const Map<String, Map<ErrorCode, String>> errorMessages = {
  'en': {
    ErrorCode.UNAUTHENTICATED: 'You are not authenticated.',
    ErrorCode.FORBIDDEN: 'Access denied.',
    ErrorCode.BAD_REQUEST: 'The sent request has invalid information.',
    ErrorCode.NOT_FOUND: 'Resource not found.',
    ErrorCode.NO_INTERNET_CONNECTION: 'No internet connection.',
    ErrorCode.TIMEOUT: 'Request timed out.',
    ErrorCode.SERVER_ERROR: 'Server error occurred.',
    ErrorCode.EXIST: 'Resource already exists.',
    ErrorCode.NOT_EXIST_ACCOUNT: 'Account does not exist.',
    ErrorCode.APP_ERROR: 'An error occurred processing the response.',
    ErrorCode.USER_DATA_NOT_FOUND: 'User data not found.',
    ErrorCode.PENDING_APPROVAL: 'Account is pending approval.',
    ErrorCode.UNPROCESSABLE_ENTITY: 'Unprocessable request.',
    ErrorCode.UNKNOWN: 'An unknown error occurred.',
    ErrorCode.CANCEL: 'Request was cancelled.',
    ErrorCode.BAD_CERTIFICATE: 'Invalid SSL certificate.',
  },
  'ar': {
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
    ErrorCode.UNKNOWN: 'حدث خطأ غير معروف.',
    ErrorCode.CANCEL: 'تم إلغاء الطلب.',
    ErrorCode.BAD_CERTIFICATE: 'شهادة SSL غير صالحة.',
  },
};

extension ErrorCodeLocalization on ErrorCode {
  String getLocalizedMessage([String langCode = 'ar']) {
    final languageMessages = errorMessages[langCode] ?? errorMessages['ar']!;
    return languageMessages[this] ?? languageMessages[ErrorCode.UNKNOWN]!;
  }
}
