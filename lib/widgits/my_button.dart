import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color,
    this.textColor = Colors.white,
    this.backgroundColor,
    this.width,
    this.height = 50,
    this.radius = 12,
    this.elevation = 5,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.shape,
    this.border,
    this.gradient,
  });

  // ✅ إضافة Super Key
  final String title;
  final VoidCallback? onPressed;
  final Color? color;
  final Color textColor;
  final Color? backgroundColor;
  final double? width;
  final double height;
  final double radius;
  final double elevation;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final IconPosition iconPosition;
  final EdgeInsetsGeometry padding;
  final ShapeBorder? shape;
  final BoxBorder? border;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    // ✅ حساب الألوان
    final Color buttonColor =
        color ?? backgroundColor ?? Theme.of(context).primaryColor;
    final bool isClickable = !isDisabled && !isLoading && onPressed != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: Material(
          elevation: isClickable ? elevation : 0,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: isClickable ? onPressed : null,
            borderRadius: BorderRadius.circular(radius),
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient == null ? buttonColor : null,
                borderRadius: BorderRadius.circular(radius),
                border: border,
                boxShadow: isClickable
                    ? [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              padding: padding,
              child: Center(child: _buildChild()),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ بناء محتوى الزر بناءً على الحالة
  Widget _buildChild() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    Widget child = Text(
      title,
      style: TextStyle(
        color: isDisabled ? Colors.grey.shade400 : textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 0.5,
        fontFamily: 'Roboto',
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    // ✅ إضافة أيقونة إذا كانت موجودة
    if (icon != null) {
      child = _buildIconButton(child);
    }

    return child;
  }

  // ✅ بناء الزر مع أيقونة
  Widget _buildIconButton(Widget child) {
    if (iconPosition == IconPosition.left) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(child: child),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: child),
          const SizedBox(width: 8),
          icon!,
        ],
      );
    }
  }

  // ✅ مؤشر التحميل
  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: textColor, strokeWidth: 2.5),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}

// ✅ Enum لموقع الأيقونة
enum IconPosition { left, right }

// ✅ Extension لتسهيل الاستخدام
extension MyButtonExtension on MyButton {
  MyButton copyWith({
    String? title,
    VoidCallback? onPressed,
    Color? color,
    Color? textColor,
    Color? backgroundColor,
    double? width,
    double? height,
    double? radius,
    double? elevation,
    double? fontSize,
    FontWeight? fontWeight,
    bool? isLoading,
    bool? isDisabled,
    Widget? icon,
    IconPosition? iconPosition,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    BoxBorder? border,
    Gradient? gradient,
  }) {
    return MyButton(
      title: title ?? this.title,
      onPressed: onPressed ?? this.onPressed,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      height: height ?? this.height,
      radius: radius ?? this.radius,
      elevation: elevation ?? this.elevation,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      isLoading: isLoading ?? this.isLoading,
      isDisabled: isDisabled ?? this.isDisabled,
      icon: icon ?? this.icon,
      iconPosition: iconPosition ?? this.iconPosition,
      padding: padding ?? this.padding,
      shape: shape ?? this.shape,
      border: border ?? this.border,
      gradient: gradient ?? this.gradient,
    );
  }
}
