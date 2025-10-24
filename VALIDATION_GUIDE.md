# Validation System Guide

This guide provides comprehensive documentation for the validation system in Ultimate Form.

## Overview

The Ultimate Form validation system is built with extensibility in mind. It provides:

- 20+ built-in validators for common use cases
- Custom validator registration for domain-specific validation
- Flexible validation modes (onChange, onSubmit, manual)
- Field-level and form-level validation
- Access to all form values for cross-field validation

## Architecture

### Core Components

1. **UFormFieldValidator** - Configuration model for validation rules
2. **UFormValidatorType** - Enum of all available validator types
3. **UFormValidatorRegistry** - Singleton registry for custom validators
4. **Validators** - Static class with built-in validator implementations

### Validation Flow

```
User Input → Field Builder → UFormState
                                ↓
                         Validation Mode Check
                                ↓
                    UFormValidatorRegistry.validate()
                                ↓
                    Built-in or Custom Validator
                                ↓
                    Error Message (if invalid)
                                ↓
                    Field Builder (display error)
```

## Built-in Validators

### String Validators

#### required
Ensures the field is not empty or null.

```dart
UFormFieldValidator(
  type: UFormValidatorType.required,
  message: 'This field is required',
)
```

#### minLength
Validates minimum string length.

```dart
UFormFieldValidator(
  type: UFormValidatorType.minLength,
  message: 'Must be at least 8 characters',
  params: {'length': 8},
)
```

#### maxLength
Validates maximum string length.

```dart
UFormFieldValidator(
  type: UFormValidatorType.maxLength,
  message: 'Must be less than 100 characters',
  params: {'length': 100},
)
```

#### alpha
Only alphabetic characters allowed.

```dart
UFormFieldValidator(
  type: UFormValidatorType.alpha,
  message: 'Only letters are allowed',
)
```

#### alphanumeric
Only alphanumeric characters allowed.

```dart
UFormFieldValidator(
  type: UFormValidatorType.alphanumeric,
  message: 'Only letters and numbers are allowed',
)
```

### Format Validators

#### email
Validates email address format.

```dart
UFormFieldValidator(
  type: UFormValidatorType.email,
  message: 'Please enter a valid email address',
)
```

#### url
Validates URL format.

```dart
UFormFieldValidator(
  type: UFormValidatorType.url,
  message: 'Please enter a valid URL',
)
```

#### phone
Validates phone number format.

```dart
UFormFieldValidator(
  type: UFormValidatorType.phone,
  message: 'Please enter a valid phone number',
)
```

#### pattern
Validates against a custom regex pattern.

```dart
UFormFieldValidator(
  type: UFormValidatorType.pattern,
  message: 'Invalid format',
  params: {'pattern': r'^[A-Z]{3}\d{4}$'}, // String pattern
)

// Or with RegExp object
UFormFieldValidator(
  type: UFormValidatorType.pattern,
  message: 'Invalid format',
  params: {'pattern': RegExp(r'^[A-Z]{3}\d{4}$')},
)
```

### Numeric Validators

#### numeric
Ensures value is a valid number.

```dart
UFormFieldValidator(
  type: UFormValidatorType.numeric,
  message: 'Please enter a valid number',
)
```

#### integer
Ensures value is an integer.

```dart
UFormFieldValidator(
  type: UFormValidatorType.integer,
  message: 'Please enter a whole number',
)
```

#### min
Validates minimum numeric value.

```dart
UFormFieldValidator(
  type: UFormValidatorType.min,
  message: 'Must be at least 18',
  params: {'min': 18},
)
```

#### max
Validates maximum numeric value.

```dart
UFormFieldValidator(
  type: UFormValidatorType.max,
  message: 'Must be less than 100',
  params: {'max': 100},
)
```

### Date Validators

#### date
Ensures value is a valid date.

```dart
UFormFieldValidator(
  type: UFormValidatorType.date,
  message: 'Please enter a valid date',
)
```

#### dateAfter
Validates date is after a specific date.

```dart
UFormFieldValidator(
  type: UFormValidatorType.dateAfter,
  message: 'Date must be after January 1, 2024',
  params: {'date': DateTime(2024, 1, 1)},
)

// Or with string
UFormFieldValidator(
  type: UFormValidatorType.dateAfter,
  message: 'Date must be after January 1, 2024',
  params: {'date': '2024-01-01'},
)
```

#### dateBefore
Validates date is before a specific date.

```dart
UFormFieldValidator(
  type: UFormValidatorType.dateBefore,
  message: 'Date must be before December 31, 2024',
  params: {'date': DateTime(2024, 12, 31)},
)
```

### Comparison Validators

#### equals
Validates value equals a specific value.

```dart
UFormFieldValidator(
  type: UFormValidatorType.equals,
  message: 'You must agree to continue',
  params: {'value': true},
)
```

#### notEquals
Validates value does not equal a specific value.

```dart
UFormFieldValidator(
  type: UFormValidatorType.notEquals,
  message: 'This value is not allowed',
  params: {'value': 'forbidden'},
)
```

#### oneOf
Validates value is one of allowed values.

```dart
UFormFieldValidator(
  type: UFormValidatorType.oneOf,
  message: 'Please select a valid option',
  params: {'values': ['option1', 'option2', 'option3']},
)
```

#### match
Validates value matches another field's value (useful for password confirmation).

```dart
UFormFieldValidator(
  type: UFormValidatorType.match,
  message: 'Passwords do not match',
  params: {'fieldName': 'password'},
)
```

## Custom Validators

### Creating Custom Validators

Custom validators allow you to implement domain-specific validation logic.

#### Basic Custom Validator

```dart
// Register the validator
UFormValidatorRegistry.instance.registerValidator(
  'customValidatorName',
  (value, validator, context) {
    // Validation logic
    if (/* invalid condition */) {
      return validator.message; // Return error message
    }
    return null; // Return null if valid
  },
);

// Use the validator
UFormFieldValidator(
  type: UFormValidatorType.custom,
  message: 'Validation failed',
  params: {'name': 'customValidatorName'},
)
```

#### Advanced Custom Validator with Context

The `context` parameter provides access to all form values, enabling cross-field validation:

```dart
UFormValidatorRegistry.instance.registerValidator(
  'passwordConfirmation',
  (value, validator, context) {
    final password = context['password'];
    final confirmation = value?.toString();

    if (password?.toString() != confirmation) {
      return validator.message;
    }

    return null;
  },
);
```

#### Custom Validator with Complex Logic

```dart
UFormValidatorRegistry.instance.registerValidator(
  'strongPassword',
  (value, validator, context) {
    final password = value?.toString() ?? '';

    if (password.isEmpty) return null; // Let required validator handle

    final checks = [
      (password.length >= 12, 'at least 12 characters'),
      (password.contains(RegExp(r'[A-Z]')), 'an uppercase letter'),
      (password.contains(RegExp(r'[a-z]')), 'a lowercase letter'),
      (password.contains(RegExp(r'[0-9]')), 'a number'),
      (password.contains(RegExp(r'[!@#$%^&*]')), 'a special character'),
    ];

    for (final check in checks) {
      if (!check.$1) {
        return 'Password must contain ${check.$2}';
      }
    }

    return null;
  },
);
```

### Managing Custom Validators

```dart
// Check if validator exists
if (UFormValidatorRegistry.instance.hasValidator('myValidator')) {
  // Validator is registered
}

// Unregister a validator
UFormValidatorRegistry.instance.unregisterValidator('myValidator');

// Get all registered validator names
final validators = UFormValidatorRegistry.instance.registeredValidators;

// Clear all custom validators (useful for testing)
UFormValidatorRegistry.instance.clear();
```

## Validation Modes

### onChange (Default)

Validates fields as the user types:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  validationMode: 'onChange',
)
```

### onSubmit

Validates only when the form is submitted:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  validationMode: 'onSubmit',
)
```

### manual

Validation only occurs when explicitly called:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  validationMode: 'manual',
)

// Later...
formKey.currentState?.validate();
```

## Form-Level Validation

### Validate All Fields

```dart
final isValid = formKey.currentState?.validate() ?? false;

if (isValid) {
  // All fields are valid
  final values = formKey.currentState?.values;
  // Process form
} else {
  // Show error message
}
```

### Check if Form is Valid

```dart
final isValid = formKey.currentState?.isValid ?? false;
```

### Get All Errors

```dart
final errors = formKey.currentState?.errors ?? {};

for (final entry in errors.entries) {
  print('${entry.key}: ${entry.value}');
}
```

### Get Specific Field Error

```dart
final emailError = formKey.currentState?.getError('email');
```

## Best Practices

### 1. Order Validators Appropriately

Place `required` validator first, then format validators, then business logic validators:

```dart
validators: [
  UFormFieldValidator(
    type: UFormValidatorType.required,
    message: 'Email is required',
  ),
  UFormFieldValidator(
    type: UFormValidatorType.email,
    message: 'Invalid email format',
  ),
  UFormFieldValidator(
    type: UFormValidatorType.custom,
    message: 'Email already registered',
    params: {'name': 'emailAvailable'},
  ),
]
```

### 2. Use Descriptive Error Messages

Be specific about what's wrong and how to fix it:

```dart
// ❌ Bad
message: 'Invalid input'

// ✅ Good
message: 'Password must be at least 8 characters with uppercase, lowercase, number, and special character'
```

### 3. Handle Empty Values in Custom Validators

Let the `required` validator handle empty values:

```dart
UFormValidatorRegistry.instance.registerValidator(
  'myValidator',
  (value, validator, context) {
    if (value == null || value.toString().isEmpty) {
      return null; // Don't validate empty values
    }

    // Your validation logic here
  },
);
```

### 4. Register Custom Validators Early

Register validators in `initState` or at app startup:

```dart
@override
void initState() {
  super.initState();
  _registerCustomValidators();
}

void _registerCustomValidators() {
  UFormValidatorRegistry.instance.registerValidator(/* ... */);
}
```

### 5. Provide Helper Text

Use helper text to guide users:

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Password',
    errorText: error,
    helperText: 'At least 12 characters with uppercase, lowercase, number, and special character',
    helperMaxLines: 3,
  ),
)
```

## Examples

See the example app for complete working examples:

- `example/lib/main.dart` - Basic validation with built-in validators
- `example/lib/custom_validator_example.dart` - Custom validators (password strength, credit card, etc.)
- `example/lib/custom_field_type_example.dart` - Custom field types with validation

## API Reference

### ValidatorFunction Type

```dart
typedef ValidatorFunction = String? Function(
  dynamic value,           // The field value to validate
  UFormFieldValidator validator, // Validator configuration
  Map<String, dynamic> context,  // All form values
);
```

### UFormValidatorRegistry Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `registerValidator(String, ValidatorFunction)` | `void` | Register a custom validator |
| `unregisterValidator(String)` | `void` | Remove a custom validator |
| `hasValidator(String)` | `bool` | Check if validator exists |
| `getValidator(String)` | `ValidatorFunction?` | Get validator function |
| `clear()` | `void` | Remove all custom validators |
| `registeredValidators` | `List<String>` | Get all registered validator names |
| `validate(dynamic, UFormFieldValidator, Map)` | `String?` | Execute validation |

### UFormState Validation Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `validate()` | `bool` | Validate all fields, returns true if valid |
| `getError(String)` | `String?` | Get error for specific field |
| `errors` | `Map<String, String?>` | Get all errors |
| `isValid` | `bool` | Check if form is currently valid |
