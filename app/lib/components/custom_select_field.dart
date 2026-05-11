import 'package:flutter/material.dart';

class CustomSelectField<T extends Object> extends StatefulWidget {
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
  State<CustomSelectField<T>> createState() => _CustomSelectFieldState<T>();
}

class _CustomSelectFieldState<T extends Object>
    extends State<CustomSelectField<T>> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _syncInitialValue();
  }

  @override
  void didUpdateWidget(CustomSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _syncInitialValue();
    }
  }

  void _syncInitialValue() {
    if (widget.initialValue != null) {
      _textEditingController.text = widget.displayStringForOption(
        widget.initialValue as T,
      );
    } else {
      _textEditingController.clear();
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<T>>(
      future: widget.options,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final resolvedOptions = snapshot.data ?? [];
        return LayoutBuilder(
          builder: (context, constraints) {
            return Autocomplete<T>(
              displayStringForOption: widget.displayStringForOption,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (isLoading) return const Iterable.empty();
                if (textEditingValue.text.isEmpty) {
                  return resolvedOptions;
                }
                return resolvedOptions.where((T option) {
                  return widget
                      .displayStringForOption(option)
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (T selection) {
                if (widget.onSelected != null) {
                  widget.onSelected!(selection);
                }
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    // Sychronize the Autocomplete's internal controller with our controller
                    // We use a post-frame callback to avoid build-time exceptions
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (textEditingController.text !=
                          _textEditingController.text) {
                        textEditingController.text =
                            _textEditingController.text;
                      }
                    });

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      readOnly: isLoading,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (String value) {
                        _textEditingController.text = value;
                        if (!isLoading) {
                          final matches = resolvedOptions.where(
                            (option) =>
                                widget
                                    .displayStringForOption(option)
                                    .trim()
                                    .toLowerCase() ==
                                value.trim().toLowerCase(),
                          );
                          if (matches.isNotEmpty && widget.onSelected != null) {
                            widget.onSelected!(matches.first);
                          } else if (widget.onSelected != null) {
                            widget.onSelected!(null);
                          }
                        }
                      },
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                      validator: (value) {
                        if (widget.isRequired &&
                            (value == null || value.trim().isEmpty)) {
                          return widget.requiredErrorMessage;
                        }

                        if (widget.validator != null) {
                          final result = widget.validator!(value);
                          if (result != null) return result;
                        }

                        if (value != null && value.isNotEmpty && !isLoading) {
                          final matches = resolvedOptions.where(
                            (option) =>
                                widget
                                    .displayStringForOption(option)
                                    .trim()
                                    .toLowerCase() ==
                                value.trim().toLowerCase(),
                          );
                          if (matches.isEmpty) {
                            return 'Please select a valid option';
                          }
                        }
                        return null;
                      },
                      style: theme.textTheme.labelSmall,
                      decoration: InputDecoration(
                        labelText: widget.labelText,
                        hintText: isLoading ? 'Loading...' : widget.hintText,
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
                                    _textEditingController.text = widget
                                        .displayStringForOption(option);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 14.0,
                                    ),
                                    child: Text(
                                      widget.displayStringForOption(option),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 14),
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
