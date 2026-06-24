import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kingdom_heir/core/theme/app_colors.dart';
import 'package:kingdom_heir/core/theme/app_spacing.dart';
import 'package:kingdom_heir/core/theme/app_theme.dart' show AppTheme;
import 'package:kingdom_heir/core/theme/app_typography.dart';

/// Styled text field for Kingdom Heir forms.
///
/// Wraps Flutter's [TextFormField] with consistent styling that matches
/// the [AppTheme] `inputDecorationTheme`, plus:
/// - Password visibility toggle
/// - Required field indicator (gold asterisk)
/// - Character counter
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.isRequired = false,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.initialValue,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final String? initialValue;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelText =
        widget.isRequired && widget.label != null ? null : widget.label;

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      onTap: widget.onTap,
      style: AppTypography.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        label: widget.isRequired && widget.label != null
            ? RichText(
                text: TextSpan(
                  text: widget.label,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ],
                ),
              )
            : null,
        hintText: widget.hint,
        helperText: widget.helper,
        helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: AppSpacing.iconSm)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: AppSpacing.iconSm,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )
            : widget.suffixIcon,
        counterStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

/// A labelled group of radio options — e.g. payment method selector.
class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.options,
    required this.labels,
    required this.value,
    required this.onChanged,
    super.key,
    this.title,
    this.direction = Axis.vertical,
  });

  final List<T> options;
  final List<String> labels;
  final T value;
  final void Function(T?) onChanged;
  final String? title;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tiles = List.generate(options.length, (i) {
      final isSelected = options[i] == value;
      return InkWell(
        onTap: () => onChanged(options[i]),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.gold : theme.dividerColor,
              width: isSelected ? 1.5 : 0.5,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: RadioGroup<T>(
                  groupValue: value,
                  onChanged: onChanged,
                  child: Radio<T>(
                    value: options[i],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  labels[i],
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (direction == Axis.vertical)
          ...tiles.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: t,
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            children: tiles,
          ),
      ],
    );
  }
}

/// Numeric stepper widget — quantity selector for bookstore / giving amount.
class AppStepper extends StatelessWidget {
  const AppStepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    super.key,
    this.min = 1,
    this.max = 99,
    this.label,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final int min;
  final int max;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.textTheme.labelMedium),
          const SizedBox(width: AppSpacing.md),
        ],
        _StepBtn(
          icon: Icons.remove_rounded,
          onPressed: value > min ? onDecrement : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _StepBtn(
          icon: Icons.add_rounded,
          onPressed: value < max ? onIncrement : null,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(
              color: disabled
                  ? AppColors.gold.withValues(alpha: 0.3)
                  : AppColors.gold,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            icon,
            size: AppSpacing.iconSm,
            color: disabled
                ? AppColors.gold.withValues(alpha: 0.3)
                : AppColors.gold,
          ),
        ),
      ),
    );
  }
}
