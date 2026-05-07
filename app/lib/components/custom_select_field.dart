import 'package:flutter/material.dart';

class CustomSelectField<T extends Object> extends StatelessWidget {
  final Future<List<T>> options;
  final String Function(T) displayStringForOption;
  final String hintText;
  final String? labelText;
  final T? initialValue;
  final void Function(T?)? onSelected;
  final bool isRequired;
  final String? requiredErrorMessage;
  final FormFieldValidator<String>? validator;

  const CustomSelectField({
    super.key,
    required this.options,
    this.displayStringForOption = _defaultDisplayString,
    this.hintText = 'Select an option',
    this.labelText,
    this.initialValue,
    this.onSelected,
    this.isRequired = false,
    this.requiredErrorMessage = 'This field is required',
    this.validator,
  });

  static String _defaultDisplayString(dynamic option) => option.toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<T>>(
      future: options,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final resolvedOptions = snapshot.data ?? [];

        return LayoutBuilder(
          builder: (context, constraints) {
            return Autocomplete<T>(
              initialValue: initialValue != null
                  ? TextEditingValue(
                      text: displayStringForOption(initialValue as T),
                    )
                  : TextEditingValue.empty,
              displayStringForOption: displayStringForOption,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (isLoading) return const Iterable.empty();
                if (textEditingValue.text.isEmpty) {
                  return resolvedOptions; // Show all options when empty to act like a dropdown
                }
                return resolvedOptions.where((T option) {
                  return displayStringForOption(
                    option,
                  ).toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: onSelected,
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      readOnly: isLoading,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (String value) {
                        if (!isLoading) {
                          final matches = resolvedOptions.where(
                            (option) =>
                                displayStringForOption(
                                  option,
                                ).trim().toLowerCase() ==
                                value.trim().toLowerCase(),
                          );
                          if (matches.isNotEmpty && onSelected != null) {
                            onSelected!(matches.first);
                          } else if (onSelected != null) {
                            onSelected!(null);
                          }
                        }
                      },
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                      validator: (value) {
                        // Check if the field is required and empty
                        if (isRequired &&
                            (value == null || value.trim().isEmpty)) {
                          return requiredErrorMessage;
                        }

                        // Use custom validator if provided
                        if (validator != null) {
                          final result = validator!(value);
                          if (result != null) return result;
                        }

                        // Validate if the entered text is part of the options
                        if (value != null && value.isNotEmpty && !isLoading) {
                          final matches = resolvedOptions.where(
                            (option) =>
                                displayStringForOption(
                                  option,
                                ).trim().toLowerCase() ==
                                value.trim().toLowerCase(),
                          );
                          if (matches.isEmpty) {
                            return 'Please select a valid option';
                          }
                        }
                        return null;
                      },
                      style: theme.textTheme.bodySmall,
                      decoration: InputDecoration(
                        labelText: labelText,
                        hintText: isLoading ? 'Loading...' : hintText,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        suffixIcon: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(14.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(Icons.arrow_drop_down),
                      ),
                    );
                  },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<T> onSelected,
                    Iterable<T> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final T option = options.elementAt(index);
                                return InkWell(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 14.0,
                                    ),
                                    child: Text(
                                      displayStringForOption(option),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
            );
          },
        );
      },
    );
  }
}
