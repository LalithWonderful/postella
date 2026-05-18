import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/categories/field_spec.dart';

/// Rend un `FieldSpec` en widget de formulaire approprié.
///
/// Renvoie la valeur saisie via [onChanged] dès qu'elle change. La
/// validation est dérivée automatiquement du `required` flag.
class DynamicField extends StatelessWidget {
  const DynamicField({
    super.key,
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final FieldSpec spec;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    switch (spec.kind) {
      case FieldKind.text:
        return _TextField(spec: spec, value: value as String?, onChanged: onChanged);
      case FieldKind.textarea:
        return _TextField(
          spec: spec,
          value: value as String?,
          onChanged: onChanged,
          maxLines: 4,
        );
      case FieldKind.number:
        return _NumberField(
          spec: spec,
          value: value is num ? value as num : null,
          onChanged: onChanged,
        );
      case FieldKind.select:
        return _SelectField(
          spec: spec,
          value: value as String?,
          onChanged: onChanged,
        );
      case FieldKind.multiSelect:
        return _MultiSelectField(
          spec: spec,
          value: (value as List?)?.cast<String>() ?? const [],
          onChanged: onChanged,
        );
      case FieldKind.boolean:
        return _BooleanField(
          spec: spec,
          value: (value as bool?) ?? false,
          onChanged: onChanged,
        );
      case FieldKind.date:
        return _DateField(
          spec: spec,
          value: value as String?,
          onChanged: onChanged,
        );
    }
  }
}

String _label(FieldSpec spec) =>
    spec.required ? '${spec.label} *' : spec.label;

String? _requiredValidator(FieldSpec spec, Object? value) {
  if (!spec.required) return null;
  if (value == null) return 'Champ requis';
  if (value is String && value.trim().isEmpty) return 'Champ requis';
  if (value is List && value.isEmpty) return 'Champ requis';
  return null;
}

class _TextField extends StatefulWidget {
  const _TextField({
    required this.spec,
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
  });

  final FieldSpec spec;
  final String? value;
  final ValueChanged<Object?> onChanged;
  final int maxLines;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: _label(widget.spec),
        hintText: widget.spec.hint,
      ),
      validator: (v) => _requiredValidator(widget.spec, v),
      onChanged: (v) => widget.onChanged(v.trim().isEmpty ? null : v),
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final FieldSpec spec;
  final num? value;
  final ValueChanged<Object?> onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: false,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: _label(widget.spec),
        hintText: widget.spec.hint,
        suffixText: widget.spec.unit,
      ),
      validator: (v) {
        if (widget.spec.required && (v == null || v.trim().isEmpty)) {
          return 'Champ requis';
        }
        if (v == null || v.isEmpty) return null;
        final parsed = num.tryParse(v.replaceAll(',', '.'));
        if (parsed == null) return 'Nombre invalide';
        return null;
      },
      onChanged: (v) {
        if (v.trim().isEmpty) {
          widget.onChanged(null);
          return;
        }
        final parsed = num.tryParse(v.replaceAll(',', '.'));
        if (parsed != null) widget.onChanged(parsed);
      },
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final FieldSpec spec;
  final String? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: _label(spec),
        hintText: spec.hint,
      ),
      items: [
        for (final opt in spec.options!)
          DropdownMenuItem(value: opt.value, child: Text(opt.label)),
      ],
      validator: (v) => _requiredValidator(spec, v),
      onChanged: (v) => onChanged(v),
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final FieldSpec spec;
  final List<String> value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<List<String>>(
      initialValue: value,
      validator: (v) => _requiredValidator(spec, v),
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label(spec), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opt in spec.options!)
                  FilterChip(
                    label: Text(opt.label),
                    selected: value.contains(opt.value),
                    onSelected: (sel) {
                      final next = [...value];
                      if (sel) {
                        next.add(opt.value);
                      } else {
                        next.remove(opt.value);
                      }
                      state.didChange(next);
                      onChanged(next.isEmpty ? null : next);
                    },
                  ),
              ],
            ),
            if (state.hasError) ...[
              const SizedBox(height: 4),
              Text(
                state.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BooleanField extends StatelessWidget {
  const _BooleanField({
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final FieldSpec spec;
  final bool value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(_label(spec)),
      subtitle: spec.hint != null ? Text(spec.hint!) : null,
      value: value,
      onChanged: (v) => onChanged(v),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.spec,
    required this.value,
    required this.onChanged,
  });

  final FieldSpec spec;
  final String? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final parsed = value != null ? DateTime.tryParse(value!) : null;
    final display = parsed != null
        ? '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}'
        : '—';
    return FormField<String>(
      initialValue: value,
      validator: (v) => _requiredValidator(spec, v),
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: parsed ?? now,
              firstDate: DateTime(1950),
              lastDate: DateTime(now.year + 30),
            );
            if (picked != null) {
              final iso = picked.toIso8601String().split('T').first;
              state.didChange(iso);
              onChanged(iso);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: _label(spec),
              hintText: spec.hint,
              errorText: state.errorText,
            ),
            child: Text(display),
          ),
        );
      },
    );
  }
}
