# Ultimate Form

A flexible Flutter form package that separates field rendering logic from field configuration. Define your form structure with models and provide custom widget builders for each field type.

## Features

- **Clean separation of concerns**: Form logic is separate from UI implementation
- **Flexible field builders**: Pass custom widget builders for each field type
- **Type-safe field configuration**: Use `UFormField` model to configure fields
- **Built-in state management**: Automatic value tracking with `ValueNotifier`
- **Programmatic control**: Access form state to get/set values, reset form, etc.
- **Customizable field rendering**: Optional field wrapper for adding labels, errors, etc.
- **Field ordering**: Built-in support for field ordering
- **Metadata support**: Pass custom data to field builders

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

  // 2. Define field builders
  Map<UFormFieldType, UFormFieldBuilder> get fieldBuilders => {
    UFormFieldType.text: (field, value, onChanged) {
      return TextField(
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
        ),
      );
    },
    UFormFieldType.email: (field, value, onChanged) {
      return TextField(
        controller: TextEditingController(text: value?.toString() ?? ''),
        onChanged: onChanged,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
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
| `metadata` | `Map<String, dynamic>?` | Custom data for the field |
| `order` | `int` | Display order (default: 0) |

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

Main form widget.

| Property | Type | Description |
|----------|------|-------------|
| `fields` | `List<UFormField>` | List of field configurations |
| `fieldBuilders` | `Map<UFormFieldType, UFormFieldBuilder>` | Map of builders for each field type |
| `onChanged` | `ValueChanged<Map<String, dynamic>>?` | Callback when form values change |
| `initialValues` | `Map<String, dynamic>?` | Initial values for the form |
| `fieldSpacing` | `double` | Spacing between fields (default: 16.0) |
| `fieldWrapper` | `Widget Function(Widget, UFormField)?` | Custom wrapper for fields |

### UFormFieldBuilder

Type definition for field builder function:

```dart
typedef UFormFieldBuilder = Widget Function(
  UFormField field,
  dynamic value,
  ValueChanged<dynamic> onChanged,
);
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
