import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:darb/core/style/app_colors.dart';
import 'package:darb/core/style/app_text_styles.dart';

/// صف مربعات الرمز. الإدخال من اليسار لليمين (كما في Figma) حتى في RTL.
/// - الانتقال التلقائي للمربع التالي، والرجوع عند الحذف.
/// - يدعم لصق الرمز كاملًا.
/// - [OtpInputRowState.clear] لمسح كل المربعات (عبر GlobalKey).
class OtpInputRow extends StatefulWidget {
  const OtpInputRow({
    super.key,
    required this.onChanged,
    this.length = 4,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final int length;
  final bool enabled;

  @override
  State<OtpInputRow> createState() => OtpInputRowState();
}

class OtpInputRowState extends State<OtpInputRow> {
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());

  late final List<FocusNode> _focusNodes = List.generate(widget.length, (i) {
    final node = FocusNode(onKeyEvent: (_, event) => _onKey(i, event));
    // عند التركيز نحدد المحتوى ليُستبدل بما يُكتب.
    node.addListener(() {
      if (node.hasFocus) {
        _controllers[i].selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controllers[i].text.length,
        );
      }
    });
    return node;
  });

  String get code => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    widget.onChanged(code);
  }

  KeyEventResult _onKey(int i, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _controllers[i - 1].clear();
      _focusNodes[i - 1].requestFocus();
      widget.onChanged(code);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onChanged(int i, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      if (i > 0) _focusNodes[i - 1].requestFocus();
    } else {
      // حرف واحد أو لصق عدة أرقام: نوزعها بدءًا من المربع الحالي.
      var last = i;
      for (var k = 0; k < digits.length && i + k < widget.length; k++) {
        _controllers[i + k].text = digits[k];
        last = i + k;
      }
      if (last < widget.length - 1) {
        _focusNodes[last + 1].requestFocus();
      } else {
        _focusNodes[last].requestFocus();
      }
    }
    widget.onChanged(code);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),
        borderSide: BorderSide(color: color, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        // ⚠️ قياس تقديري: المسافة بين المربعات 16 وارتفاع المربع 58
        // (مأخوذان من لقطة Figma، وليس من لوحة القياسات).
        spacing: 16.w,
        children: [
          for (var i = 0; i < widget.length; i++)
            Expanded(
              child: SizedBox(
                height: 58.h,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  enabled: widget.enabled,
                  autofocus: i == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  cursorColor: AppColors.main600,
                  style: AppTextStyles.font20Regular
                      .copyWith(color: AppColors.grey500),
                  onChanged: (v) => _onChanged(i, v),
                  decoration: InputDecoration(
                    hintText: '-',
                    hintStyle: AppTextStyles.font20Regular
                        .copyWith(color: AppColors.grey100),
                    filled: true,
                    fillColor: AppColors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: _border(AppColors.grey100),
                    disabledBorder: _border(AppColors.grey100),
                    // ⚠️ قياس تقديري: حد التركيز يبدو أزرق (second500) في Figma
                    focusedBorder: _border(AppColors.second500),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
