import 'package:ultimate_form/src/models/u_form_field_validator.dart';
import 'package:ultimate_form/src/models/u_form_validator_type.dart';
import 'package:ultimate_form/src/validation/validators.dart';

/// Internal validator registry.
///
/// Handles routing validation requests to the appropriate built-in validators.
/// This is an internal utility class - users should use [UFormFieldValidator.customValidationLogic]
/// for custom validation instead of registering validators.
class UFormValidatorRegistry {
  UFormValidatorRegistry._();

  static final UFormValidatorRegistry instance = UFormValidatorRegistry._();

  /// Validates a value using the validator configuration.
  ///
  /// Returns:
  /// - `null` if the value is valid
  /// - The [UFormFieldValidator] object if validation failed (violated validator)
  ///
  /// The [context] parameter should contain all form values for validators
  /// that need to compare with other fields.
  UFormFieldValidator? validate(
    dynamic value,
    UFormFieldValidator validator,
    Map<String, dynamic> context,
  ) {
    // Check for inline custom validation logic first
    if (validator.customValidationLogic != null) {
      final isValid = validator.customValidationLogic!(value, context);
      return isValid ? null : validator;
    }

    // Handle built-in validator types
    bool isValid = false;

    switch (validator.type) {
      case UFormValidatorType.required:
        isValid = Validators.required(value, validator, context);
        break;
      case UFormValidatorType.email:
        isValid = Validators.email(value, validator, context);
        break;
      case UFormValidatorType.url:
        isValid = Validators.url(value, validator, context);
        break;
      case UFormValidatorType.phone:
        isValid = Validators.phone(value, validator, context);
        break;
      case UFormValidatorType.minLength:
        isValid = Validators.minLength(value, validator, context);
        break;
      case UFormValidatorType.maxLength:
        isValid = Validators.maxLength(value, validator, context);
        break;
      case UFormValidatorType.min:
        isValid = Validators.min(value, validator, context);
        break;
      case UFormValidatorType.max:
        isValid = Validators.max(value, validator, context);
        break;
      case UFormValidatorType.pattern:
        isValid = Validators.pattern(value, validator, context);
        break;
      case UFormValidatorType.match:
        isValid = Validators.match(value, validator, context);
        break;
      case UFormValidatorType.equals:
        isValid = Validators.equals(value, validator, context);
        break;
      case UFormValidatorType.notEquals:
        isValid = Validators.notEquals(value, validator, context);
        break;
      case UFormValidatorType.oneOf:
        isValid = Validators.oneOf(value, validator, context);
        break;
      case UFormValidatorType.alpha:
        isValid = Validators.alpha(value, validator, context);
        break;
      case UFormValidatorType.alphanumeric:
        isValid = Validators.alphanumeric(value, validator, context);
        break;
      case UFormValidatorType.numeric:
        isValid = Validators.numeric(value, validator, context);
        break;
      case UFormValidatorType.integer:
        isValid = Validators.integer(value, validator, context);
        break;
      case UFormValidatorType.date:
        isValid = Validators.date(value, validator, context);
        break;
      case UFormValidatorType.dateAfter:
        isValid = Validators.dateAfter(value, validator, context);
        break;
      case UFormValidatorType.dateBefore:
        isValid = Validators.dateBefore(value, validator, context);
        break;
      case UFormValidatorType.custom:
        // Custom type requires customValidationLogic
        throw ArgumentError(
          'UFormValidatorType.custom requires customValidationLogic parameter. '
          'Example: UFormFieldValidator(type: UFormValidatorType.custom, '
          'customValidationLogic: (value, context) => ..., message: "...")',
        );
    }

    return isValid ? null : validator;
  }
}
