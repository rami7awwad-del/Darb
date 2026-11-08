import 'package:darb/core/models/enums/state_value.dart';

/// Generic state wrapper shared by every cubit.
class BaseState<T> {
  const BaseState({
    this.stateValue = StateValue.init,
    this.data,
    this.errorMessage,
  });

  final StateValue stateValue;
  final T? data;
  final String? errorMessage;

  /// Returns a copy with the given fields replaced.
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
