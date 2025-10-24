# Ultimate Form

A flexible Flutter form package that separates field rendering logic from field configuration. Define your form structure with models and provide custom widget builders for each field type.

## Features

- **Clean separation of concerns**: Form logic is separate from UI implementation
- **Flexible field builders**: Pass custom widget builders for each field type
- **Type-safe field configuration**: Use `UFormField` model to configure fields
- **Built-in state management**: Automatic value tracking with `ValueNotifier`
- **Comprehensive validation system**: 20+ built-in validators with custom validator support
- **Extensible architecture**: Register custom validators and field types
- **Flexible validation modes**: Validate on change, on submit, or manually
- **Programmatic control**: Access form state to get/set values, validate, reset, etc.
- **Customizable field rendering**: Optional field wrapper for adding labels, errors, etc.
- **Field ordering**: Built-in support for field ordering
- **Metadata support**: Pass custom data to field builders
- **Built-in submission handling**: Optional async submission with success/error callbacks
- **Flexible submission**: Dynamic response type for maximum flexibility
- **Customizable UI**: Custom button and error display builders

## Getting started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  ultimate_form:
    path: ../ultimate_form
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:ultimate_form/ultimate_form.dart';

class MyForm extends StatelessWidget {
  final GlobalKey<UFormState> formKey = GlobalKey<UFormState>();

  // 1. Define your fields
  final List<UFormField> fields = [
    UFormField(
      name: 'username',
      type: UFormFieldType.text,
      label: 'Username',
      required: true,
      order: 0,
    ),
    UFormField(
      name: 'email',
      type: UFormFieldType.email,
      label: 'Email',
      required: true,
      order: 1,
    ),
  ];

  // 2. Define field builders (note: error parameter added for validation)
  Map<UFormFieldType, UFormFieldBuilder> get fieldBuilders => {
    UFormFieldType.text: (field, value, onChanged, error) {
      return TextField(
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
          errorText: error,
        ),
      );
    },
    UFormFieldType.email: (field, value, onChanged, error) {
      return TextField(
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: onChanged,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
          errorText: error,
        ),
      );
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UForm(
          key: formKey,
          fields: fields,
          fieldBuilders: fieldBuilders,
          onChanged: (values) {
            debugPrint('Form values: $values');
          },
        ),
        ElevatedButton(
          onPressed: () {
            final values = formKey.currentState?.values;
            debugPrint('Submit: $values');
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
```

### Validation

The package includes a comprehensive validation system with 20+ built-in validators and support for custom validation logic.

#### Basic Validation

Add validators to your fields:

```dart
UFormField(
  name: 'email',
  type: UFormFieldType.email,
  label: 'Email',
  validators: [
    UFormFieldValidator(
      type: UFormValidatorType.required,
      message: 'Email is required',
    ),
    UFormFieldValidator(
      type: UFormValidatorType.email,
      message: 'Please enter a valid email address',
    ),
  ],
)
```

#### Built-in Validators

The package provides these built-in validators:

| Validator | Parameters | Description |
|-----------|------------|-------------|
| `required` | - | Field must not be empty or null |
| `email` | - | Must be a valid email address |
| `url` | - | Must be a valid URL |
| `phone` | - | Must be a valid phone number |
| `minLength` | `length` (int) | Minimum string length |
| `maxLength` | `length` (int) | Maximum string length |
| `min` | `min` (num) | Minimum numeric value |
| `max` | `max` (num) | Maximum numeric value |
| `pattern` | `pattern` (String/RegExp) | Must match regex pattern |
| `match` | `fieldName` (String) | Must match another field's value |
| `equals` | `value` (dynamic) | Must equal specific value |
| `notEquals` | `value` (dynamic) | Must not equal specific value |
| `oneOf` | `values` (List) | Must be one of the allowed values |
| `alpha` | - | Only alphabetic characters |
| `alphanumeric` | - | Only alphanumeric characters |
| `numeric` | - | Must be a valid number |
| `integer` | - | Must be an integer |
| `date` | - | Must be a valid date |
| `dateAfter` | `date` (DateTime/String) | Date must be after specified date |
| `dateBefore` | `date` (DateTime/String) | Date must be before specified date |
| `custom` | `name` (String) | Custom validator (must be registered) |

#### Validation Examples

```dart
// Password with minimum length
UFormField(
  name: 'password',
  type: UFormFieldType.password,
  validators: [
    UFormFieldValidator(
      type: UFormValidatorType.required,
      message: 'Password is required',
    ),
    UFormFieldValidator(
      type: UFormValidatorType.minLength,
      message: 'Password must be at least 8 characters',
      params: {'length': 8},
    ),
  ],
)

// Age with range validation
UFormField(
  name: 'age',
  type: UFormFieldType.number,
  validators: [
    UFormFieldValidator(
      type: UFormValidatorType.min,
      message: 'Age must be at least 18',
      params: {'min': 18},
    ),
    UFormFieldValidator(
      type: UFormValidatorType.max,
      message: 'Age must be less than 120',
      params: {'max': 120},
    ),
  ],
)

// Username with alphanumeric validation
UFormField(
  name: 'username',
  type: UFormFieldType.text,
  validators: [
    UFormFieldValidator(
      type: UFormValidatorType.required,
      message: 'Username is required',
    ),
    UFormFieldValidator(
      type: UFormValidatorType.alphanumeric,
      message: 'Username must contain only letters and numbers',
    ),
  ],
)
```

#### Validation Modes

Control when validation occurs:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  validationMode: 'onChange', // Validate as user types (default)
  // validationMode: 'onSubmit', // Validate only when form is submitted
  // validationMode: 'manual', // Only validate when explicitly called
)
```

#### Manual Validation

Validate the form programmatically:

```dart
void handleSubmit() {
  final isValid = formKey.currentState?.validate() ?? false;

  if (!isValid) {
    // Show error message
    print('Form has errors');
    return;
  }

  // Process form
  final values = formKey.currentState?.values;
  print('Form is valid: $values');
}
```

#### Custom Validators

Register your own validation logic:

```dart
// 1. Register a custom validator
UFormValidatorRegistry.instance.registerValidator(
  'creditCard',
  (value, validator, context) {
    if (value == null || value.toString().isEmpty) return null;

    // Custom credit card validation logic
    final cardNumber = value.toString().replaceAll(' ', '');
    if (cardNumber.length != 16 || !_luhnCheck(cardNumber)) {
      return validator.message;
    }

    return null;
  },
);

// 2. Use the custom validator
UFormField(
  name: 'card_number',
  type: UFormFieldType.text,
  validators: [
    UFormFieldValidator(
      type: UFormValidatorType.custom,
      message: 'Invalid credit card number',
      params: {'name': 'creditCard'},
    ),
  ],
)

// 3. Advanced custom validator with field comparison
UFormValidatorRegistry.instance.registerValidator(
  'passwordStrength',
  (value, validator, context) {
    final password = value?.toString() ?? '';

    if (password.length < 12) {
      return 'Password must be at least 12 characters';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*]'))) {
      return 'Password must contain a special character';
    }

    return null;
  },
);
```

### Form Submission

UForm includes optional built-in submission handling with async support, success/error callbacks, and customizable UI.

#### Basic Submission

Add submission handling to your form with async callbacks:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  onSubmit: (values) async {
    // Call your API
    final response = await authService.signIn(
      email: values['email'],
      password: values['password'],
    );
    return response;
  },
  onSuccess: (response) {
    // Handle successful submission
    print('Signed in with token: ${response.token}');
    Navigator.pushNamed(context, '/dashboard');
  },
  onError: (error) {
    // Handle submission error
    print('Sign in failed: $error');
  },
)
```

#### Custom Submit Button

Customize the submit button using the `buildButton` parameter:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  onSubmit: (values) async => await authService.signIn(values),
  onSuccess: (response) => Navigator.pushNamed(context, '/dashboard'),
  onError: (error) => print('Error: $error'),
  buildButton: ({
    required onSubmit,
    required isSubmitting,
    required isValid,
    required values,
  }) {
    return ElevatedButton(
      onPressed: isSubmitting ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: isSubmitting
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Sign In'),
    );
  },
)
```

#### Custom Global Error Display

Customize how submission errors are displayed:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  onSubmit: (values) async => await authService.signIn(values),
  buildGlobalError: ({required error}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              error.toString(),
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
        ],
      ),
    );
  },
)
```

#### Manual Submission

You can also trigger submission programmatically:

```dart
final formKey = GlobalKey<UFormState>();

// ... later in your code

Future<void> handleCustomSubmit() async {
  final response = await formKey.currentState?.submit();

  if (response != null) {
    // Submission was successful
    print('Got response: $response');
  } else {
    // Submission failed or form is invalid
    print('Submission failed');
  }
}
```

#### Backward Compatibility

All submission features are **optional**. You can use UForm without submission handling:

```dart
// Without submission - works exactly as before
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  onChanged: (values) => print(values),
)

// With your own submit button
Column(
  children: [
    UForm(
      key: formKey,
      fields: fields,
      fieldBuilders: fieldBuilders,
    ),
    ElevatedButton(
      onPressed: () {
        final values = formKey.currentState?.values;
        // Handle submission yourself
      },
      child: Text('Submit'),
    ),
  ],
)
```

### Advanced Usage

#### Field Metadata

Pass custom data to your field builders using the `metadata` property:

```dart
UFormField(
  name: 'country',
  type: UFormFieldType.select,
  metadata: {
    'options': ['USA', 'Canada', 'UK'],
    'allowClear': true,
  },
)

// In your builder:
(field, value, onChanged) {
  final options = field.getMetadata<List<String>>('options') ?? [];
  final allowClear = field.getMetadata<bool>('allowClear') ?? false;
  // Build your widget...
}
```

#### Initial Values

Set initial values when creating the form:

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  initialValues: {
    'username': 'john_doe',
    'email': 'john@example.com',
  },
)
```

#### Programmatic Control

Access the form state to control the form programmatically:

```dart
// Get all values
final values = formKey.currentState?.values;

// Get a specific value
final username = formKey.currentState?.getValue('username');

// Set a value
formKey.currentState?.setValue('username', 'new_value');

// Set multiple values
formKey.currentState?.setValues({
  'username': 'john',
  'email': 'john@example.com',
});

// Reset form to initial values
formKey.currentState?.reset();
```

#### Custom Field Wrapper

Add custom wrappers around fields (e.g., for labels, error messages):

```dart
UForm(
  fields: fields,
  fieldBuilders: fieldBuilders,
  fieldWrapper: (widget, fieldConfig) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fieldConfig.label != null)
          Text(
            fieldConfig.label!,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        SizedBox(height: 8),
        widget,
        if (fieldConfig.required)
          Text(
            'Required field',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
      ],
    );
  },
)
```

## API Reference

### UFormField

Configuration model for a form field.

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Unique identifier for the field |
| `type` | `UFormFieldType` | Type of the field |
| `initialValue` | `dynamic` | Initial value for the field |
| `label` | `String?` | Label to display |
| `placeholder` | `String?` | Placeholder text |
| `required` | `bool` | Whether the field is required |
| `enabled` | `bool` | Whether the field is enabled |
| `validators` | `List<UFormFieldValidator>?` | List of validation rules |
| `metadata` | `Map<String, dynamic>?` | Custom data for the field |
| `order` | `int` | Display order (default: 0) |

### UFormFieldValidator

Configuration model for a validation rule.

| Property | Type | Description |
|----------|------|-------------|
| `type` | `UFormValidatorType` | Type of validation to perform |
| `message` | `String` | Error message to display on failure |
| `params` | `Map<String, dynamic>?` | Optional parameters for the validator |

### UFormFieldType

Enum of available field types:

- `text`
- `password`
- `email`
- `phone`
- `date`
- `select`
- `checkbox`
- `radio`
- `number`
- `textArea`
- `custom`

### UForm

Main form widget with optional submission handling.

| Property | Type | Description |
|----------|------|-------------|
| `fields` | `List<UFormField>` | List of field configurations |
| `fieldBuilders` | `Map<UFormFieldType, UFormFieldBuilder>` | Map of builders for each field type |
| `onChanged` | `ValueChanged<Map<String, dynamic>>?` | Callback when form values change |
| `initialValues` | `Map<String, dynamic>?` | Initial values for the form |
| `fieldSpacing` | `double` | Spacing between fields (default: 16.0) |
| `fieldWrapper` | `Widget Function(Widget, UFormField)?` | Custom wrapper for fields |
| `validationMode` | `String` | When to validate: 'onChange', 'onSubmit', or 'manual' (default: 'onChange') |
| `onSubmit` | `Future<dynamic> Function(Map<String, dynamic>)?` | Optional submission handler (returns response) |
| `onSuccess` | `void Function(dynamic)?` | Optional callback when submission succeeds |
| `onError` | `void Function(dynamic)?` | Optional callback when submission fails |
| `buildButton` | `Widget Function({required VoidCallback, required bool, required bool, required Map})?` | Optional custom submit button builder |
| `buildGlobalError` | `Widget Function({required dynamic})?` | Optional custom global error display builder |

### UFormState

Methods available on the form state:

| Method | Return Type | Description |
|--------|-------------|-------------|
| `values` | `Map<String, dynamic>` | Get all form values |
| `getValue(String)` | `dynamic` | Get value for a specific field |
| `setValue(String, dynamic)` | `void` | Set value for a specific field |
| `setValues(Map<String, dynamic>)` | `void` | Set multiple values at once |
| `reset()` | `void` | Reset form to initial values |
| `validate()` | `bool` | Validate all fields, returns true if valid |
| `getError(String)` | `String?` | Get error message for a specific field |
| `errors` | `Map<String, String?>` | Get all errors |
| `isValid` | `bool` | Check if form is currently valid |
| `submit()` | `Future<dynamic>` | Submit the form (validates, then calls onSubmit if provided) |

### UFormFieldBuilder

Type definition for field builder function:

```dart
typedef UFormFieldBuilder = Widget Function(
  UFormField field,
  dynamic value,
  ValueChanged<dynamic> onChanged,
  String? error, // Error message, if any
);
```

### UFormValidatorRegistry

Singleton registry for custom validators:

```dart
// Register a custom validator
UFormValidatorRegistry.instance.registerValidator(
  'validatorName',
  (value, validator, context) {
    // Return null if valid, error message if invalid
    return null;
  },
);

// Unregister a validator
UFormValidatorRegistry.instance.unregisterValidator('validatorName');

// Check if validator exists
bool hasValidator = UFormValidatorRegistry.instance.hasValidator('validatorName');
```

## Architecture

The package follows a clean architecture approach:

1. **Models** (`UFormField`, `UFormFieldType`): Define the structure and configuration of form fields
2. **Widget** (`UForm`): Handles rendering, state management, and coordination
3. **Builders**: You provide the actual field widgets through builder functions

This separation allows you to:
- Reuse field configurations across different UI implementations
- Easily test form logic without UI dependencies
- Customize field rendering without changing form logic
- Share form configurations between teams

## Example

See the [example](example/lib/main.dart) directory for a complete working example.
