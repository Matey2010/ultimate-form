import 'package:flutter/material.dart';
import '../models/u_form_field.dart';
import '../models/u_form_field_validator.dart';
import '../models/u_form_validator_type.dart';
import '../validation/u_form_validator_registry.dart';

/// Type definition for field builder function
/// Takes the field configuration, current value, violated validator (if any), and a callback to update the value
typedef UFormFieldBuilder =
    Widget Function(
      UFormField field,
      dynamic value,
      ValueChanged<dynamic> onChanged,
      UFormFieldValidator? error,
    );

/// Main form widget that renders fields based on configuration
class UForm extends StatefulWidget {
  /// List of field configurations
  final List<UFormField> fields;

  /// Map of field builders for each field type
  /// Key: String (field type like 'text', 'email', 'custom'), Value: Builder function
  final Map<String, UFormFieldBuilder> fieldBuilders;

  /// Callback when form values change
  final ValueChanged<Map<String, dynamic>>? onChanged;

  /// Initial values for the form
  final Map<String, dynamic>? initialValues;

  /// Spacing between fields
  final double fieldSpacing;

  /// Builder for custom field wrapper (e.g., for adding labels, errors, etc.)
  final Widget Function(Widget field, UFormField fieldConfig)? fieldWrapper;

  /// When to validate fields: 'onChange', 'onSubmit', or 'manual'
  final String validationMode;

  /// Optional: Submission handler
  /// Called when form is submitted (via submit() method)
  /// Receives current form values and should return a Future
  final Future<dynamic> Function(Map<String, dynamic> values)? onSubmit;

  /// Optional: Success callback
  /// Called when onSubmit completes successfully
  final void Function(dynamic response)? onSuccess;

  /// Optional: Error callback
  /// Called when onSubmit throws an error
  final void Function(dynamic error)? onError;

  /// Optional: Custom button builder
  /// If not provided and onSubmit is set, a default "Submit" button will be shown
  /// Receives named parameters for building a custom submit button
  final Widget Function({
    required VoidCallback onSubmit,
    required bool isSubmitting,
    required bool isValid,
    required Map<String, dynamic> values,
  })?
  buildButton;

  /// Optional: Custom global error builder
  /// If not provided, a default red text error will be shown
  /// Receives the error object for custom error display
  final Widget Function({required dynamic error})? buildGlobalError;

  const UForm({
    super.key,
    required this.fields,
    required this.fieldBuilders,
    this.onChanged,
    this.initialValues,
    this.fieldSpacing = 16.0,
    this.fieldWrapper,
    this.validationMode = 'onChange',
    this.onSubmit,
    this.onSuccess,
    this.onError,
    this.buildButton,
    this.buildGlobalError,
  });

  @override
  State<UForm> createState() => UFormState();
}

class UFormState extends State<UForm> {
  late Map<String, ValueNotifier<dynamic>> _controllers;
  late Map<String, UFormFieldValidator?> _errors;
  bool _isSubmitting = false;
  dynamic _globalError;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeErrors();
  }

  void _initializeControllers() {
    _controllers = {};
    for (final field in widget.fields) {
      final initialValue =
          widget.initialValues?[field.name] ?? field.initialValue;
      final controller = ValueNotifier<dynamic>(initialValue);
      controller.addListener(() {
        _updateValue(field.name, controller.value);
      });
      _controllers[field.name] = controller;
    }
  }

  void _initializeErrors() {
    _errors = {};
    for (final field in widget.fields) {
      _errors[field.name] = null;
    }
  }

  /// Helper method to build a map of all current values from controllers
  Map<String, dynamic> _getValuesFromControllers() {
    return Map.fromEntries(
      _controllers.entries.map((e) => MapEntry(e.key, e.value.value)),
    );
  }

  void _updateValue(String fieldName, dynamic value) {
    setState(() {
      // Validate on change if validation mode is onChange
      if (widget.validationMode == 'onChange') {
        _validateField(fieldName);
      }
    });
    widget.onChanged?.call(_getValuesFromControllers());
  }

  /// Validates a single field
  /// Note: This method only updates the _errors map, it does NOT call setState.
  /// The caller is responsible for wrapping this in setState if needed.
  UFormFieldValidator? _validateField(String fieldName) {
    final field = widget.fields.firstWhere((f) => f.name == fieldName);
    final value = _controllers[fieldName]?.value;

    // Check for misuse of required validator
    if (field.validators != null && field.validators!.isNotEmpty) {
      final hasRequiredValidator = field.validators!.any(
        (validator) => validator.type == UFormValidatorType.required,
      );
      if (hasRequiredValidator) {
        throw ArgumentError(
          'Field "${field.name}" has a required validator in the validators list. '
          'Do not add UFormValidatorType.required to validators. '
          'Instead, set field.required = true and optionally provide buildRequiredErrorMessage.',
        );
      }
    }

    // Check if value is empty
    final isEmpty = _isValueEmpty(value);

    // If field is required and value is empty, return required error
    if (field.required && isEmpty) {
      final errorMessage =
          field.buildRequiredErrorMessage?.call(field, value) ??
          '${field.label ?? field.name} is required';

      final requiredError = UFormFieldValidator(
        type: UFormValidatorType.required,
        message: errorMessage,
      );
      _errors[fieldName] = requiredError;
      return requiredError;
    }

    // If field is NOT required and value is empty, skip all validators (valid)
    // This allows optional fields to pass validation when empty, even with validators like numeric/dateAfter
    if (!field.required && isEmpty) {
      _errors[fieldName] = null;
      return null;
    }

    // Value is not empty, run validators
    if (field.validators == null || field.validators!.isEmpty) {
      _errors[fieldName] = null;
      return null;
    }

    // Run all validators for this field
    // Build validation context from all controller values
    final validationContext = _getValuesFromControllers();
    for (final validator in field.validators!) {
      final error = UFormValidatorRegistry.instance.validate(
        value,
        validator,
        validationContext,
      );
      if (error != null) {
        _errors[fieldName] = error;
        return error;
      }
    }

    _errors[fieldName] = null;
    return null;
  }

  /// Helper method to check if a value is considered empty
  bool _isValueEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.trim().isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    if (value is Map && value.isEmpty) return true;
    return false;
  }

  /// Get current form values
  Map<String, dynamic> get values =>
      Map.unmodifiable(_getValuesFromControllers());

  /// Get value for a specific field
  dynamic getValue(String fieldName) => _controllers[fieldName]?.value;

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
      final initialValue =
          widget.initialValues?[field.name] ?? field.initialValue;
      if (_controllers.containsKey(field.name)) {
        _controllers[field.name]!.value = initialValue;
      }
    }
    // Clear all errors
    setState(() {
      _errors = {};
      for (final field in widget.fields) {
        _errors[field.name] = null;
      }
    });
  }

  /// Validates all fields in the form
  /// Returns true if all fields are valid, false otherwise
  bool validate() {
    bool isValid = true;
    setState(() {
      for (final field in widget.fields) {
        final error = _validateField(field.name);
        if (error != null) {
          isValid = false;
        }
      }
    });
    return isValid;
  }

  /// Submits the form
  /// Validates all fields, then calls onSubmit if provided
  /// Returns the response from onSubmit, or null if submission is not configured
  Future<dynamic> submit() async {
    // Clear global error
    setState(() {
      _globalError = null;
    });

    // Validate form
    final isValid = validate();

    // If invalid, don't submit
    if (!isValid) {
      return null;
    }

    // If no onSubmit handler, do nothing
    if (widget.onSubmit == null) {
      return null;
    }

    // Get current values
    final values = _getValuesFromControllers();

    // Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call onSubmit handler
      final dynamic response = await widget.onSubmit!(values);

      // Clear submitting state
      setState(() {
        _isSubmitting = false;
      });

      // Call onSuccess callback if provided
      widget.onSuccess?.call(response);

      return response;
    } catch (error) {
      // Set error state
      setState(() {
        _isSubmitting = false;
        _globalError = error;
      });

      // Call onError callback if provided
      widget.onError?.call(error);

      return null;
    }
  }

  /// Gets the violated validator for a specific field
  UFormFieldValidator? getError(String fieldName) => _errors[fieldName];

  /// Gets all errors (violated validators)
  Map<String, UFormFieldValidator?> get errors => Map.unmodifiable(_errors);

  /// Checks if the form is valid (no errors)
  bool get isValid => _errors.values.every((error) => error == null);

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Builds the default global error widget
  Widget _buildDefaultGlobalError({required dynamic error}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD32F2F)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error?.toString() ?? 'Error while submitting form',
              style: const TextStyle(color: Color(0xFFD32F2F), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the default submit button
  Widget _buildDefaultButton({
    required VoidCallback onSubmit,
    required bool isSubmitting,
    required bool isValid,
    required Map<String, dynamic> values,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Submit'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort fields by order
    final sortedFields = List<UFormField>.from(widget.fields)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Global error (if present)
        if (_globalError != null) ...[
          widget.buildGlobalError?.call(error: _globalError) ??
              _buildDefaultGlobalError(error: _globalError),
          SizedBox(height: widget.fieldSpacing),
        ],

        // Fields
        for (int i = 0; i < sortedFields.length; i++) ...[
          _buildField(sortedFields[i]),
          if (i < sortedFields.length - 1)
            SizedBox(height: widget.fieldSpacing),
        ],

        // Submit button (if onSubmit is provided)
        if (widget.onSubmit != null) ...[
          SizedBox(height: widget.fieldSpacing * 1.5),
          widget.buildButton?.call(
                onSubmit: submit,
                isSubmitting: _isSubmitting,
                isValid: isValid,
                values: _getValuesFromControllers(),
              ) ??
              _buildDefaultButton(
                onSubmit: submit,
                isSubmitting: _isSubmitting,
                isValid: isValid,
                values: _getValuesFromControllers(),
              ),
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
          _errors[field.name],
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
