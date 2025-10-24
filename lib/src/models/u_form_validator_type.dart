/// Defines the types of validation rules available for form fields.
///
/// This enum provides common validation types out of the box.
/// For custom validation logic, use [UFormValidatorType.custom] and
/// either provide [customValidationLogic] or register a validator
/// using [UFormValidatorRegistry].
enum UFormValidatorType {
  /// Field must not be empty or null.
  required,

  /// Field value must be a valid email address.
  email,

  /// Field value must be a valid URL.
  url,

  /// Field value must be a valid phone number.
  phone,

  /// Field value must have a minimum length.
  /// Requires param: `length` (int)
  minLength,

  /// Field value must have a maximum length.
  /// Requires param: `length` (int)
  maxLength,

  /// Field value must be greater than or equal to a minimum value.
  /// Requires param: `min` (num)
  min,

  /// Field value must be less than or equal to a maximum value.
  /// Requires param: `max` (num)
  max,

  /// Field value must match a regular expression pattern.
  /// Requires param: `pattern` (String or RegExp)
  pattern,

  /// Field value must match another field's value.
  /// Requires param: `fieldName` (String)
  match,

  /// Field value must be equal to a specific value.
  /// Requires param: `value` (dynamic)
  equals,

  /// Field value must not be equal to a specific value.
  /// Requires param: `value` (dynamic)
  notEquals,

  /// Field value must be one of the allowed values.
  /// Requires param: `values` (List)
  oneOf,

  /// Field value must contain only alphabetic characters.
  alpha,

  /// Field value must contain only alphanumeric characters.
  alphanumeric,

  /// Field value must be a valid number.
  numeric,

  /// Field value must be an integer.
  integer,

  /// Field value must be a valid date.
  date,

  /// Field value must be a date after a specific date.
  /// Requires param: `date` (DateTime or String)
  dateAfter,

  /// Field value must be a date before a specific date.
  /// Requires param: `date` (DateTime or String)
  dateBefore,

  /// Custom validation with user-defined logic.
  /// Can use [customValidationLogic] parameter or register in [UFormValidatorRegistry].
  custom,
}
