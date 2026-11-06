import 'package:darb/core/errors/error_messages.dart';
import 'package:darb/core/errors/errors_code.dart';
import 'package:darb/core/errors/remote_exceptions.dart';
import 'package:darb/core/models/base_state.dart';
import 'package:darb/core/models/enums/state_value.dart';
import 'package:darb/features/subscription/data/models/package_model.dart';
import 'package:darb/features/subscription/data/models/payment_method_model.dart';
import 'package:darb/features/subscription/data/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionData {
  const SubscriptionData({
    this.packages = const [],
    this.methods = const [],
    this.redeeming = false,
  });

  final List<PackageModel> packages;
  final List<PaymentMethodModel> methods;
  final bool redeeming;

  SubscriptionData copyWith({
    List<PackageModel>? packages,
    List<PaymentMethodModel>? methods,
    bool? redeeming,
  }) =>
      SubscriptionData(
        packages: packages ?? this.packages,
        methods: methods ?? this.methods,
        redeeming: redeeming ?? this.redeeming,
      );
}

/// صفحة الاشتراك: وسائل الدفع (payment-methods/all) + تفعيل كود (subscriptions/add).
class SubscriptionCubit extends Cubit<BaseState<SubscriptionData>> {
  SubscriptionCubit(this._repository) : super(const BaseState());

  final SubscriptionRepository _repository;

  String _messageOf(Object e) => e is RemoteExceptions
      ? e.errorMsg
      : ErrorCode.UNKNOWN.getLocalizedMessage();

  Future<void> load({bool silent = false}) async {
    if (!silent || state.data == null) {
      emit(const BaseState<SubscriptionData>(stateValue: StateValue.loading));
    }
    try {
      // الباقات للنافذة التفصيلية ووسائل الدفع لشاشة الدفع الشكلية:
      // فشل أحدهما لا يعطّل صفحة الاشتراك (تعتمد على الكود).
      final packages = await _repository
          .getPackages()
          .catchError((_) => <PackageModel>[]);
      final methods = await _repository
          .getPaymentMethods()
          .catchError((_) => <PaymentMethodModel>[]);
      if (isClosed) return;
      emit(BaseState<SubscriptionData>(
        stateValue: StateValue.loaded,
        data: SubscriptionData(packages: packages, methods: methods),
      ));
    } catch (e) {
      if (isClosed) return;
      emit(BaseState<SubscriptionData>(
        stateValue: StateValue.error,
        errorMessage: _messageOf(e),
      ));
    }
  }

  /// يعيد null عند النجاح، وإلا رسالة الخطأ.
  Future<String?> redeem(String code) async {
    final data = state.data;
    if (data == null || data.redeeming) return null;
    if (code.trim().isEmpty) return 'أدخل كود الاشتراك';
    emit(state.copyWith(data: data.copyWith(redeeming: true)));
    try {
      await _repository.subscribeWithCode(code);
      if (!isClosed) emit(state.copyWith(data: data.copyWith(redeeming: false)));
      return null;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(data: data.copyWith(redeeming: false)));
      return _messageOf(e);
    }
  }
}
