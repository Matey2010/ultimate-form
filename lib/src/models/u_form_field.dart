import 'u_form_field_validator.dart';

/// Model representing a form field configuration
class UFormField {
  /// Unique identifier for the field
  final String name;

  /// Type of the field (text, email, select, etc.)
  /// Can be any string - common types: 'text', 'password', 'email', 'phone',
  /// 'date', 'select', 'checkbox', 'radio', 'number', 'textArea', 'custom'
  final String type;

  /// Initial value for the field
  final dynamic initialValue;

  /// Label to display for the field
  final String? label;

  /// Placeholder text for the field
  final String? placeholder;

  /// Whether the field is required
  final bool required;

  /// Whether the field is enabled
  final bool enabled;

  /// List of validation rules for this field
  final List<UFormFieldValidator>? validators;

  /// Custom data that can be passed to field builders
  /// For example: list of options for select, validation rules, etc.
  final Map<String, dynamic>? metadata;

  /// Order of the field in the form (for sorting)
  final int order;

  /// Custom function to build the required error message.
  /// If not provided, defaults to '${label ?? name} is required'
  ///
  /// Example:
  /// ```dart
  /// buildRequiredErrorMessage: (field, value) =>
  ///   'Please enter your ${field.label?.toLowerCase()}'
  /// ```
  final String Function(UFormField field, dynamic value)? buildRequiredErrorMessage;

  const UFormField({
    required this.name,
    required this.type,
    this.initialValue,
    this.label,
    this.placeholder,
    this.required = false,
    this.enabled = true,
    this.validators,
    this.metadata,
    this.order = 0,
    this.buildRequiredErrorMessage,
  });

  /// Helper method to get metadata value
  T? getMetadata<T>(String key) {
    return metadata?[key] as T?;
  }

  /// Create a copy of the field with updated properties
  UFormField copyWith({
    String? name,
    String? type,
    dynamic initialValue,
    String? label,
    String? placeholder,
    bool? required,
    bool? enabled,
    List<UFormFieldValidator>? validators,
    Map<String, dynamic>? metadata,
    int? order,
    String Function(UFormField field, dynamic value)? buildRequiredErrorMessage,
  }) {
    return UFormField(
      name: name ?? this.name,
      type: type ?? this.type,
      initialValue: initialValue ?? this.initialValue,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      required: required ?? this.required,
      enabled: enabled ?? this.enabled,
      validators: validators ?? this.validators,
      metadata: metadata ?? this.metadata,
      order: order ?? this.order,
      buildRequiredErrorMessage: buildRequiredErrorMessage ?? this.buildRequiredErrorMessage,
    );
  }
}
