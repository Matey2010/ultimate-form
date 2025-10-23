import 'u_form_field_type.dart';

/// Model representing a form field configuration
class UFormField {
  /// Unique identifier for the field
  final String name;

  /// Type of the field (text, email, select, etc.)
  final UFormFieldType type;

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

  /// Custom data that can be passed to field builders
  /// For example: list of options for select, validation rules, etc.
  final Map<String, dynamic>? metadata;

  /// Order of the field in the form (for sorting)
  final int order;

  const UFormField({
    required this.name,
    required this.type,
    this.initialValue,
    this.label,
    this.placeholder,
    this.required = false,
    this.enabled = true,
    this.metadata,
    this.order = 0,
  });

  /// Helper method to get metadata value
  T? getMetadata<T>(String key) {
    return metadata?[key] as T?;
  }

  /// Create a copy of the field with updated properties
  UFormField copyWith({
    String? name,
    UFormFieldType? type,
    dynamic initialValue,
    String? label,
    String? placeholder,
    bool? required,
    bool? enabled,
    Map<String, dynamic>? metadata,
    int? order,
  }) {
    return UFormField(
      name: name ?? this.name,
      type: type ?? this.type,
      initialValue: initialValue ?? this.initialValue,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      required: required ?? this.required,
      enabled: enabled ?? this.enabled,
      metadata: metadata ?? this.metadata,
      order: order ?? this.order,
    );
  }
}
