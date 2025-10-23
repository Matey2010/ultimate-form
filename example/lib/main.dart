import 'package:flutter/material.dart';
import 'package:ultimate_form/ultimate_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultimate Form Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FormExamplePage(),
    );
  }
}

class FormExamplePage extends StatefulWidget {
  const FormExamplePage({super.key});

  @override
  State<FormExamplePage> createState() => _FormExamplePageState();
}

class _FormExamplePageState extends State<FormExamplePage> {
  final GlobalKey<UFormState> _formKey = GlobalKey<UFormState>();
  Map<String, dynamic> _formValues = {};

  // Define your form fields
  final List<UFormField> _fields = [
    UFormField(
      name: 'username',
      type: UFormFieldType.text,
      label: 'Username',
      placeholder: 'Enter your username',
      required: true,
      order: 0,
    ),
    UFormField(
      name: 'email',
      type: UFormFieldType.email,
      label: 'Email',
      placeholder: 'Enter your email',
      required: true,
      order: 1,
    ),
    UFormField(
      name: 'password',
      type: UFormFieldType.password,
      label: 'Password',
      placeholder: 'Enter your password',
      required: true,
      order: 2,
    ),
    UFormField(
      name: 'age',
      type: UFormFieldType.number,
      label: 'Age',
      placeholder: 'Enter your age',
      order: 3,
    ),
    UFormField(
      name: 'country',
      type: UFormFieldType.select,
      label: 'Country',
      metadata: {
        'options': ['USA', 'Canada', 'UK', 'Australia'],
      },
      order: 4,
    ),
    UFormField(
      name: 'agree_terms',
      type: UFormFieldType.checkbox,
      label: 'I agree to terms and conditions',
      initialValue: false,
      order: 5,
    ),
  ];

  // Define field builders for each type
  Map<UFormFieldType, UFormFieldBuilder> get _fieldBuilders => {
        UFormFieldType.text: _buildTextField,
        UFormFieldType.email: _buildTextField,
        UFormFieldType.password: _buildPasswordField,
        UFormFieldType.number: _buildNumberField,
        UFormFieldType.select: _buildSelectField,
        UFormFieldType.checkbox: _buildCheckboxField,
      };

  Widget _buildTextField(
    UFormField field,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  ) {
    return TextField(
      controller: TextEditingController(text: value?.toString() ?? ''),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField(
    UFormField field,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  ) {
    return TextField(
      controller: TextEditingController(text: value?.toString() ?? ''),
      onChanged: onChanged,
      obscureText: true,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNumberField(
    UFormField field,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  ) {
    return TextField(
      controller: TextEditingController(text: value?.toString() ?? ''),
      onChanged: (val) {
        final number = int.tryParse(val);
        onChanged(number);
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSelectField(
    UFormField field,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  ) {
    final options = field.getMetadata<List<dynamic>>('options') ?? [];
    return DropdownButtonFormField<String>(
      initialValue: value?.toString(),
      items: options
          .map((option) => DropdownMenuItem(
                value: option.toString(),
                child: Text(option.toString()),
              ))
          .toList(),
      onChanged: (val) => onChanged(val),
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCheckboxField(
    UFormField field,
    dynamic value,
    ValueChanged<dynamic> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(field.label ?? ''),
      value: value == true,
      onChanged: (val) => onChanged(val ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _handleSubmit() {
    final values = _formKey.currentState?.values ?? {};
    setState(() {
      _formValues = values;
    });
    // In production, use a logging framework instead of print
    debugPrint('Form submitted: $values');
  }

  void _handleReset() {
    _formKey.currentState?.reset();
    setState(() {
      _formValues = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Ultimate Form Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UForm(
              key: _formKey,
              fields: _fields,
              fieldBuilders: _fieldBuilders,
              onChanged: (values) {
                debugPrint('Form changed: $values');
              },
              fieldSpacing: 16.0,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleReset,
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
            if (_formValues.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Form Values:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formValues.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
