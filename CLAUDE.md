# Claude AI Instructions for Ultimate Form

## Critical Rules

### 🚫 DO NOT Generate Examples Unless Explicitly Asked
- **NEVER** create example files, demo code, or sample implementations unless the user specifically requests them
- **NEVER** suggest creating examples as part of your response
- **NEVER** proactively offer to write example code
- Focus on the core library implementation only
- If you think an example might help, **ASK FIRST** - don't just create it

### 📝 When Making Changes
- Always read files before editing them
- Update only what's necessary - don't refactor unnecessarily
- Keep changes focused and minimal
- Test your changes by running `flutter analyze`

## Project Overview

**Ultimate Form** is a flexible, extensible Flutter form library that separates form logic from UI implementation.

### Core Principles
1. **Separation of Concerns**: Form configuration is separate from field rendering
2. **Extensibility**: Users can register custom validators and field types
3. **Type Safety**: Models and enums provide compile-time safety
4. **Flexibility**: Builder pattern allows complete UI customization
5. **Optional Features**: Submission handling is optional - forms work without it

## Architecture

```
lib/
├── src/
│   ├── models/
│   │   ├── u_form_field.dart              # Field configuration model
│   │   ├── u_form_field_type.dart         # Field type enum (text, email, etc.)
│   │   ├── u_form_field_validator.dart    # Validator configuration model
│   │   └── u_form_validator_type.dart     # Validator type enum (required, email, etc.)
│   ├── validation/
│   │   ├── u_form_validator_registry.dart # Singleton registry for custom validators
│   │   └── validators.dart                # Built-in validator implementations
│   └── widgets/
│       └── u_form.dart                    # Main form widget and state
└── ultimate_form.dart                     # Public API exports
```

## Key Components

### 1. UFormField (Model)
Represents field configuration with:
- `name`: Unique identifier
- `type`: UFormFieldType enum (text, email, password, etc.)
- `validators`: List of UFormFieldValidator
- `initialValue`, `label`, `placeholder`, `required`, `enabled`, `metadata`, `order`

### 2. UFormFieldValidator (Model)
Represents validation rule with:
- `type`: UFormValidatorType enum (required, email, minLength, etc.)
- `message`: Error message to display
- `params`: Optional parameters for validator (e.g., `{'length': 8}`)
- `customValidationLogic`: Optional void function for inline validation (placeholder - implementation TBD)

### 3. UFormFieldType (Enum)
Field types: `text`, `password`, `email`, `phone`, `date`, `select`, `checkbox`, `radio`, `number`, `textArea`, `custom`

### 4. UFormValidatorType (Enum)
Validator types: `required`, `email`, `url`, `phone`, `minLength`, `maxLength`, `min`, `max`, `pattern`, `match`, `equals`, `notEquals`, `oneOf`, `alpha`, `alphanumeric`, `numeric`, `integer`, `date`, `dateAfter`, `dateBefore`, `custom`

### 5. UFormValidatorRegistry (Singleton)
Allows users to register custom validators:
```dart
UFormValidatorRegistry.instance.registerValidator(
  'validatorName',
  (value, validator, context) => null, // or error message
);
```

### 6. UForm (Widget)
Main form widget that:
- Renders fields based on configuration
- Manages state with ValueNotifier
- Handles validation (onChange, onSubmit, manual modes)
- Provides field builders for custom UI
- Tracks errors and form validity
- **Optional**: Handles async submission with callbacks (onSubmit, onSuccess, onError)
- **Optional**: Renders submit button and global error display
- Submission responses use dynamic type for maximum flexibility

### 7. UFormFieldBuilder (Typedef)
```dart
typedef UFormFieldBuilder = Widget Function(
  UFormField field,
  dynamic value,
  ValueChanged<dynamic> onChanged,
  String? error,
);
```

### 8. Submission Features (Optional)

#### UFormState Properties
- `_isSubmitting` (bool): Tracks submission state
- `_globalError` (dynamic): Stores submission error

#### Submission Flow
1. User triggers submit (button click or programmatic)
2. `submit()` method validates form
3. If invalid, submission stops
4. If valid and `onSubmit` provided, calls `onSubmit(values)`
5. On success: calls `onSuccess(response)`, returns response
6. On error: sets `_globalError`, calls `onError(error)`, returns null

#### Layout Structure (when onSubmit is provided)
```
Column(
  Global Error (if _globalError != null)
  Fields
  Submit Button (via buildButton or default)
)
```

#### Builder Functions
- `buildButton`: Receives onSubmit callback, isSubmitting, isValid, values
- `buildGlobalError`: Receives error object for display

#### Backward Compatibility
All submission features are optional. Forms without `onSubmit` work exactly as before with no button or error display.

## Common Tasks

### Adding a New Validator Type
1. Add to `UFormValidatorType` enum
2. Add case in `UFormValidatorRegistry.validate()` switch
3. Implement validator in `Validators` class
4. Update documentation

### Adding a New Field Type
1. Add to `UFormFieldType` enum
2. User provides builder in `UForm.fieldBuilders`
3. No library changes needed (fully extensible)

### Modifying Validation Logic
- Main logic is in `UFormValidatorRegistry.validate()`
- Individual validators in `Validators` class
- Custom validators registered via singleton registry

### Updating Form State Management
- State is in `UFormState` class
- Uses `ValueNotifier` for reactive updates
- Validation mode determines when validation runs
- Submission state (`_isSubmitting`, `_globalError`) is separate from field state

### Working with Submission Features
- Submission responses use `dynamic` type for maximum flexibility
- Error type is `dynamic` for maximum flexibility (users can pass any error type)
- `buildButton` receives named parameters (onSubmit, isSubmitting, isValid, values)
- `buildGlobalError` receives error as named parameter
- All submission features are optional - check if `onSubmit != null` before rendering button
- Type safety should be handled at the consumer level (e.g., OpFormBuilder can use generics)

## API Design Guidelines

### For Users of This Library
- **Simple**: Common cases should be straightforward
- **Flexible**: Advanced cases should be possible
- **Extensible**: Users can add their own types and validators
- **Type-Safe**: Use enums and models, not magic strings (except for custom types)

### For Contributors
- Keep the core minimal
- Make everything extensible
- Don't add dependencies unless absolutely necessary
- Maintain backward compatibility
- Write clear documentation

## Testing
**We do not write tests for now.**

- Run `flutter analyze` after changes to ensure code quality
- No broken analyzer errors allowed
- Manual testing is sufficient for current development stage

## Documentation
- **README.md**: User-facing documentation with examples
- **VALIDATION_GUIDE.md**: Comprehensive validation system guide
- **API Reference**: In README.md
- **Code Comments**: For complex logic only

## Important Notes

### Required Field Validation
- **DO NOT** add `UFormValidatorType.required` to the `validators` list
- **USE** `field.required = true` instead
- If required validator is found in validators list, an `ArgumentError` is thrown
- Required validation is handled separately in `_validateField` method
- Optional custom error message via `buildRequiredErrorMessage` callback
- Empty optional fields (required=false) skip all validators automatically

### Submission Features
- Submission responses use `dynamic` type for maximum flexibility
- Error type is `dynamic` to allow any error type (HttpException, String, Exception, etc.)
- Submission features are **completely optional**
- Forms without `onSubmit` work exactly as before
- Default button and error widgets are provided but can be overridden
- `submit()` returns `Future<dynamic>` - null if validation fails or onSubmit not provided
- Type safety can be handled at the consumer level (e.g., OpFormBuilder uses generics)

### customValidationLogic Parameter
- Accepts `bool Function(dynamic value, Map<String, dynamic> context)?`
- Used for inline custom validation logic
- Context provides access to all form values for cross-field validation
- Return `true` if valid, `false` if invalid

### Field Type vs Validator Type
- **UFormFieldType**: Enum for UI field types (text, email, select, etc.)
- **UFormValidatorType**: Enum for validation logic (required, email, minLength, etc.)
- They are separate concerns - don't mix them up!

### Extensibility Pattern
- Built-in types use enums for type safety
- Custom types use registry pattern for extensibility
- `custom` enum value + registry = best of both worlds

## Style Guidelines
- Use clear, descriptive names
- Prefer composition over inheritance
- Keep functions small and focused
- Document public APIs
- Use const constructors where possible
- Follow Flutter/Dart style guide

## Common Mistakes to Avoid
- ❌ Don't create example files unless asked
- ❌ Don't make UFormFieldType a String (it's an enum)
- ❌ Don't make UFormValidatorType a String (it's an enum)
- ❌ Don't add `UFormValidatorType.required` to validators list (use `field.required` instead)
- ❌ Don't add new dependencies without discussion
- ❌ Don't refactor unnecessarily
- ❌ Don't break the public API
- ❌ Don't call `setState` inside `_validateField` (caller is responsible for setState)
- ❌ Don't forget to handle optional submission features (check `onSubmit != null`)
- ❌ Don't add generic type parameters to UForm (it uses dynamic for flexibility)

## When in Doubt
- **Read the code** before making assumptions
- **Ask the user** if requirements are unclear
- **Keep changes minimal** and focused
- **Test your changes** with flutter analyze
- **Remember**: This is a library, not an app - users need flexibility

## Contact
- This is a library project
- User knows the requirements
- Ask questions if anything is unclear
- **NEVER generate examples unless explicitly requested**
