import 'package:darb/core/models/enums/state_value.dart';

class BaseState<T> {
  const BaseState({
    this.stateValue = StateValue.init,
    this.data,
    this.errorMessage,
  });

  final StateValue stateValue;
  final T? data;
  final String? errorMessage;

  BaseState<T> copyWith({
    StateValue? stateValue,
    T? data,
    String? errorMessage,
    bool clearData = false,
    bool clearErrorMessage = false,
  }) => BaseState<T>(
    stateValue: stateValue ?? this.stateValue,
    data: clearData ? null : data ?? this.data,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}

/**
 * 
 * BaseState تم إنشاؤها لتكون الوعاء الجامع الذي يحمل:

نوع الحالة الحالية (StateValue: init, loading, loaded, error).

البيانات المسترجعة (data من النوع T).

رسالة الخطأ (errorMessage) إن وجدت.

هذا يحافظ على نظافة المشروع، ويقلل عدد الملفات للنصف، ويسرّع عملية التطوير عند إضافة أي ميزة جديدة مستقبلاً.
 * 
 */