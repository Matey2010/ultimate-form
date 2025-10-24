import 'package:ultimate_form/src/models/u_form_validator_type.dart';

/// Represents a validation rule for a form field.
///
/// Each validator has a [type] that determines the validation logic,
/// a [message] to display when validation fails, optional [params]
/// for configuring the validator behavior, and optional [customValidationLogic]
/// for inline custom validation.
///
/// Example:
/// ```dart
/// UFormFieldValidator(
///   type: UFormValidatorType.minLength,
///   message: 'Must be at least 8 characters',
///   params: {'length': 8},
/// )
///
/// // Or with custom logic
/// UFormFieldValidator(
///   type: UFormValidatorType.custom,
///   message: 'Invalid value',
///   customValidationLogic: () {
///     // Your validation logic here
///   },
/// )
/// ```
class UFormFieldValidator {
  /// The type of validation to perform.
  final UFormValidatorType type;

  /// The error message to display when validation fails.
  final String message;

  /// Optional parameters for the validator.
  /// Different validator types may require different parameters.
  ///
  /// Common parameters:
  /// - `length`: For minLength/maxLength validators
  /// - `min`/`max`: For number range validators
  /// - `pattern`: For regex validators
  /// - `value`: For custom comparisons
  final Map<String, dynamic>? params;

  /// Optional custom validation logic function.
  /// This allows inline validation without needing a registry.
  ///
  /// The function receives:
  /// - [value]: The field value to validate
  /// - [context]: All form values (for cross-field validation)
  ///
  /// Returns:
  /// - `true` if valid
  /// - `false` if invalid (will return this validator object as error)
  ///
  /// Example:
  /// ```dart
  /// customValidationLogic: (value, context) {
  ///   return value.toString().length >= 8;
  /// }
  /// ```
  final bool Function(dynamic value, Map<String, dynamic> context)?
  customValidationLogic;

  const UFormFieldValidator({
    required this.type,
    required this.message,
    this.params,
    this.customValidationLogic,
  });

  /// Creates a copy of this validator with the given fields replaced.
  UFormFieldValidator copyWith({
    UFormValidatorType? type,
    String? message,
    Map<String, dynamic>? params,
    bool Function(dynamic value, Map<String, dynamic> context)?
    customValidationLogic,
  }) {
    return UFormFieldValidator(
      type: type ?? this.type,
      message: message ?? this.message,
      params: params ?? this.params,
      customValidationLogic:
          customValidationLogic ?? this.customValidationLogic,
    );
  }

  /// Helper method to get a typed parameter value.
  T? getParam<T>(String key) {
    if (params == null) return null;
    final value = params![key];
    if (value is T) return value;
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UFormFieldValidator &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          _mapsEqual(params, other.params);

  @override
  int get hashCode => type.hashCode ^ message.hashCode ^ params.hashCode;

  bool _mapsEqual(Map? a, Map? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'UFormFieldValidator(type: $type, message: $message, params: $params)';
}
