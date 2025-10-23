import 'package:flutter/widgets.dart';
import '../models/u_form_field.dart';
import '../models/u_form_field_type.dart';

/// Type definition for field builder function
/// Takes the field configuration, current value, and a callback to update the value
typedef UFormFieldBuilder = Widget Function(
  UFormField field,
  dynamic value,
  ValueChanged<dynamic> onChanged,
);

/// Main form widget that renders fields based on configuration
class UForm extends StatefulWidget {
  /// List of field configurations
  final List<UFormField> fields;

  /// Map of field builders for each field type
  /// Key: UFormFieldType, Value: Builder function
  final Map<UFormFieldType, UFormFieldBuilder> fieldBuilders;

  /// Callback when form values change
  final ValueChanged<Map<String, dynamic>>? onChanged;

  /// Initial values for the form
  final Map<String, dynamic>? initialValues;

  /// Spacing between fields
  final double fieldSpacing;

  /// Builder for custom field wrapper (e.g., for adding labels, errors, etc.)
  final Widget Function(Widget field, UFormField fieldConfig)? fieldWrapper;

  const UForm({
    super.key,
    required this.fields,
    required this.fieldBuilders,
    this.onChanged,
    this.initialValues,
    this.fieldSpacing = 16.0,
    this.fieldWrapper,
  });

  @override
  State<UForm> createState() => UFormState();
}

class UFormState extends State<UForm> {
  late Map<String, dynamic> _values;
  late Map<String, ValueNotifier<dynamic>> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeValues();
    _initializeControllers();
  }

  void _initializeValues() {
    _values = {};
    for (final field in widget.fields) {
      _values[field.name] = widget.initialValues?[field.name] ?? field.initialValue;
    }
  }

  void _initializeControllers() {
    _controllers = {};
    for (final field in widget.fields) {
      final controller = ValueNotifier<dynamic>(_values[field.name]);
      controller.addListener(() {
        _updateValue(field.name, controller.value);
      });
      _controllers[field.name] = controller;
    }
  }

  void _updateValue(String fieldName, dynamic value) {
    setState(() {
      _values[fieldName] = value;
    });
    widget.onChanged?.call(_values);
  }

  /// Get current form values
  Map<String, dynamic> get values => Map.unmodifiable(_values);

  /// Get value for a specific field
  dynamic getValue(String fieldName) => _values[fieldName];

  /// Set value for a specific field
  void setValue(String fieldName, dynamic value) {
    if (_controllers.containsKey(fieldName)) {
      _controllers[fieldName]!.value = value;
    }
  }

  /// Set multiple values at once
  void setValues(Map<String, dynamic> values) {
    values.forEach((key, value) {
      if (_controllers.containsKey(key)) {
        _controllers[key]!.value = value;
      }
    });
  }

  /// Reset form to initial values
  void reset() {
    for (final field in widget.fields) {
      final initialValue = widget.initialValues?[field.name] ?? field.initialValue;
      if (_controllers.containsKey(field.name)) {
        _controllers[field.name]!.value = initialValue;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort fields by order
    final sortedFields = List<UFormField>.from(widget.fields)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < sortedFields.length; i++) ...[
          _buildField(sortedFields[i]),
          if (i < sortedFields.length - 1)
            SizedBox(height: widget.fieldSpacing),
        ],
      ],
    );
  }

  Widget _buildField(UFormField field) {
    final builder = widget.fieldBuilders[field.type];

    if (builder == null) {
      // If no builder provided for this type, show error widget
      return Container(
        padding: const EdgeInsets.all(8),
        color: const Color(0xFFFFEBEE),
        child: Text(
          'No builder provided for field type: ${field.type}',
          style: const TextStyle(color: Color(0xFFD32F2F)),
        ),
      );
    }

    return ValueListenableBuilder<dynamic>(
      valueListenable: _controllers[field.name]!,
      builder: (context, value, child) {
        final fieldWidget = builder(
          field,
          value,
          (newValue) => _controllers[field.name]!.value = newValue,
        );

        // Apply wrapper if provided
        if (widget.fieldWrapper != null) {
          return widget.fieldWrapper!(fieldWidget, field);
        }

        return fieldWidget;
      },
    );
  }
}
