import 'package:ultimate_form/src/models/u_form_field_validator.dart';

/// Built-in validator implementations for all standard validation types.
///
/// This class provides static methods for common validation scenarios.
/// Each validator returns `true` if valid, `false` if invalid.
class Validators {
  Validators._();

  /// Validates that a value is not empty or null.
  static bool required(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null) return false;
    if (value is String && value.trim().isEmpty) return false;
    if (value is List && value.isEmpty) return false;
    if (value is Map && value.isEmpty) return false;
    return true;
  }

  /// Validates that a value is a valid email address.
  static bool email(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true; // Empty is valid (use required for mandatory)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(value.toString());
  }

  /// Validates that a value is a valid URL.
  static bool url(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(value.toString());
  }

  /// Validates that a value is a valid phone number.
  static bool phone(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    // Simple phone validation: at least 10 digits, may contain spaces, dashes, parentheses, plus
    final phoneRegex = RegExp(r'^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,9}$');
    final digitsOnly = value.toString().replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10 && phoneRegex.hasMatch(value.toString());
  }

  /// Validates that a value has a minimum length.
  static bool minLength(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final minLength = validator.getParam<int>('length');
    if (minLength == null) return false; // Invalid config
    return value.toString().length >= minLength;
  }

  /// Validates that a value has a maximum length.
  static bool maxLength(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final maxLength = validator.getParam<int>('length');
    if (maxLength == null) return false; // Invalid config
    return value.toString().length <= maxLength;
  }

  /// Validates that a numeric value is greater than or equal to a minimum.
  static bool min(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final min = validator.getParam<num>('min');
    if (min == null) return false; // Invalid config
    final numValue = num.tryParse(value.toString());
    if (numValue == null) return false; // Not a number
    return numValue >= min;
  }

  /// Validates that a numeric value is less than or equal to a maximum.
  static bool max(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final max = validator.getParam<num>('max');
    if (max == null) return false; // Invalid config
    final numValue = num.tryParse(value.toString());
    if (numValue == null) return false; // Not a number
    return numValue <= max;
  }

  /// Validates that a value matches a regular expression pattern.
  static bool pattern(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final patternParam = validator.params?['pattern'];
    if (patternParam == null) return false; // Invalid config

    RegExp regex;
    if (patternParam is RegExp) {
      regex = patternParam;
    } else if (patternParam is String) {
      try {
        regex = RegExp(patternParam);
      } catch (e) {
        return false; // Invalid regex
      }
    } else {
      return false; // Invalid param type
    }

    return regex.hasMatch(value.toString());
  }

  /// Validates that a value matches another field's value.
  static bool match(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    final fieldName = validator.getParam<String>('fieldName');
    if (fieldName == null) return false; // Invalid config
    final otherValue = context[fieldName];
    return value?.toString() == otherValue?.toString();
  }

  /// Validates that a value equals a specific value.
  static bool equals(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    final expectedValue = validator.params?['value'];
    if (expectedValue == null) return false; // Invalid config
    return value?.toString() == expectedValue?.toString();
  }

  /// Validates that a value does not equal a specific value.
  static bool notEquals(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    final forbiddenValue = validator.params?['value'];
    if (forbiddenValue == null) return false; // Invalid config
    return value?.toString() != forbiddenValue?.toString();
  }

  /// Validates that a value is one of the allowed values.
  static bool oneOf(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    final allowedValues = validator.getParam<List>('values');
    if (allowedValues == null) return false; // Invalid config
    final valueStr = value?.toString();
    return allowedValues.any((v) => v?.toString() == valueStr);
  }

  /// Validates that a value contains only alphabetic characters.
  static bool alpha(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final alphaRegex = RegExp(r'^[a-zA-Z]+$');
    return alphaRegex.hasMatch(value.toString());
  }

  /// Validates that a value contains only alphanumeric characters.
  static bool alphanumeric(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumericRegex.hasMatch(value.toString());
  }

  /// Validates that a value is a valid number.
  static bool numeric(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final numValue = num.tryParse(value.toString());
    return numValue != null;
  }

  /// Validates that a value is an integer.
  static bool integer(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    final intValue = int.tryParse(value.toString());
    return intValue != null;
  }

  /// Validates that a value is a valid date.
  static bool date(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;
    if (value is DateTime) return true;

    final dateValue = DateTime.tryParse(value.toString());
    return dateValue != null;
  }

  /// Validates that a date is after a specific date.
  static bool dateAfter(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;

    DateTime? valueDate;
    if (value is DateTime) {
      valueDate = value;
    } else {
      valueDate = DateTime.tryParse(value.toString());
    }

    if (valueDate == null) return false;

    final afterParam = validator.params?['date'];
    if (afterParam == null) return false; // Invalid config

    DateTime? afterDate;
    if (afterParam is DateTime) {
      afterDate = afterParam;
    } else {
      afterDate = DateTime.tryParse(afterParam.toString());
    }

    if (afterDate == null) return false; // Invalid config

    return valueDate.isAfter(afterDate);
  }

  /// Validates that a date is before a specific date.
  static bool dateBefore(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    if (value == null || value.toString().isEmpty) return true;

    DateTime? valueDate;
    if (value is DateTime) {
      valueDate = value;
    } else {
      valueDate = DateTime.tryParse(value.toString());
    }

    if (valueDate == null) return false;

    final beforeParam = validator.params?['date'];
    if (beforeParam == null) return false; // Invalid config

    DateTime? beforeDate;
    if (beforeParam is DateTime) {
      beforeDate = beforeParam;
    } else {
      beforeDate = DateTime.tryParse(beforeParam.toString());
    }

    if (beforeDate == null) return false; // Invalid config

    return valueDate.isBefore(beforeDate);
  }
}
