import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shadesmaster/app/app_scope.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/orders/lab_order.dart';
import 'package:shadesmaster/orders/shade_guide.dart';
import 'package:shadesmaster/orders/shade_guide_labels.dart';
import 'package:shadesmaster/orders/tooth_chart.dart';
import 'package:shadesmaster/utils/format.dart';
import 'package:shadesmaster/widget_results_dialog.dart';

/// Creates or edits a lab order. Pops with the saved [LabOrder].
class OrderFormPage extends StatefulWidget {
  final LabOrder order;

  /// The annotated photo of a new order, saved with it.
  final Uint8List? photoJpeg;
  final bool isNew;

  const OrderFormPage({super.key, required this.order, this.photoJpeg, this.isNew = true});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final LabOrder _order = widget.order;

  late final _caseCode = TextEditingController(text: _order.caseCode);
  late final _patientName = TextEditingController(text: _order.patientName);
  late final _dentist = TextEditingController(text: _order.dentistName);
  late final _clinic = TextEditingController(text: _order.clinicName);
  late final _phone = TextEditingController(text: _order.clinicPhone);
  late final _lab = TextEditingController(text: _order.labName);
  late final _stump = TextEditingController(text: _order.stumpShade);
  late final _notes = TextEditingController(text: _order.notes);

  late final Set<int> _teeth = {..._order.teeth};
  late RestorationType _type = _order.restorationType;
  late RestorationMaterial _material = _order.material;
  late ShadeGuide _guide = _order.shadeGuide;
  late String _body = _order.bodyShade;
  late String _cervical = _order.cervicalShade;
  late String _incisal = _order.incisalShade;
  late DateTime? _dueDate = _order.dueDate;
  bool _saving = false;

  Uint8List? _photo;

  @override
  void initState() {
    super.initState();
    _photo = widget.photoJpeg;
    if (_photo == null && _order.hasPhoto) {
      // Read after the first frame, when the inherited scope is available.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final photo = await AppScope.of(context).orders.loadPhoto(_order);
        if (mounted) setState(() => _photo = photo);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in [_caseCode, _patientName, _dentist, _clinic, _phone, _lab, _stump, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  LabOrder _collect() {
    return _order.copyWith(
      caseCode: _caseCode.text.trim(),
      patientName: _patientName.text.trim(),
      dentistName: _dentist.text.trim(),
      clinicName: _clinic.text.trim(),
      clinicPhone: _phone.text.trim(),
      labName: _lab.text.trim(),
      teeth: _teeth.toList()..sort(),
      restorationType: _type,
      material: _material,
      shadeGuide: _guide,
      bodyShade: _body,
      cervicalShade: _cervical,
      incisalShade: _incisal,
      stumpShade: _stump.text.trim(),
      notes: _notes.text.trim(),
      dueDate: _dueDate,
      clearDueDate: _dueDate == null,
    );
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final order = _collect();
    final orders = AppScope.of(context).orders;
    try {
      final saved = await orders.save(order, photoJpeg: widget.photoJpeg);
      if (mounted) Navigator.of(context).pop(saved);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        );

    Widget field(
      TextEditingController controller,
      String label, {
      String? helper,
      bool required = false,
      TextInputType? keyboardType,
      int maxLines = 1,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          // Phone numbers read left to right in Arabic too.
          textDirection: keyboardType == TextInputType.phone ? TextDirection.ltr : null,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label, helperText: helper, border: const OutlineInputBorder()),
          validator: required ? (value) => (value ?? '').trim().isEmpty ? l10n.required : null : null,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? l10n.newOrder : l10n.editOrder),
        actions: [
          IconButton(
            tooltip: l10n.save,
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        // Not a ListView: a lazy list would skip validating the fields scrolled out of view.
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_photo != null || _order.analysis.isNotEmpty) ...[
                section(l10n.photoAnalysis),
                if (_photo != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_photo!, height: 220, fit: BoxFit.contain),
                  ),
                for (final match in _order.analysis.take(3)) _AnalysisRow(match: match),
              ],
              section(l10n.sectionCase),
              field(_caseCode, l10n.caseCode, helper: l10n.caseCodeHelp, required: true),
              field(_patientName, l10n.patientName),
              section(l10n.sectionClinic),
              field(_dentist, l10n.dentistName),
              field(_clinic, l10n.clinicName),
              field(_phone, l10n.clinicPhone, keyboardType: TextInputType.phone),
              field(_lab, l10n.labName),
              section(l10n.sectionTeeth),
              FormField<Set<int>>(
                // Clears the error as soon as a tooth is picked.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => _teeth.isEmpty ? l10n.teethRequired : null,
                builder: (state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToothChart(
                      selected: _teeth,
                      onToggle: (tooth) {
                        setState(() => _teeth.contains(tooth) ? _teeth.remove(tooth) : _teeth.add(tooth));
                        state.didChange(_teeth);
                      },
                    ),
                    if (state.hasError)
                      Text(state.errorText!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                  ],
                ),
              ),
              section(l10n.sectionRestoration),
              _dropdown<RestorationType>(
                label: l10n.restorationType,
                value: _type,
                values: RestorationType.values,
                text: (type) => type.label(l10n),
                onChanged: (type) => setState(() => _type = type!),
              ),
              _dropdown<RestorationMaterial>(
                label: l10n.material,
                value: _material,
                values: RestorationMaterial.values,
                text: (material) => material.label(l10n),
                onChanged: (material) => setState(() => _material = material!),
              ),
              section(l10n.sectionShade),
              SegmentedButton<ShadeGuide>(
                segments: [
                  for (final guide in ShadeGuide.values) ButtonSegment(value: guide, label: Text(guide.label(l10n))),
                ],
                selected: {_guide},
                onSelectionChanged: (selection) => setState(() => _guide = selection.first),
              ),
              if (_order.suggestedShade case final suggestion?)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l10n.analysisSuggestion(suggestion.name), style: theme.textTheme.bodySmall),
                ),
              _shadeDropdown(
                label: l10n.shadeBody,
                value: _body,
                requiredMessage: l10n.shadeBodyRequired,
                onChanged: (shade) => setState(() => _body = shade),
              ),
              _shadeDropdown(
                label: l10n.shadeCervical,
                value: _cervical,
                onChanged: (shade) => setState(() => _cervical = shade),
              ),
              _shadeDropdown(
                label: l10n.shadeIncisal,
                value: _incisal,
                onChanged: (shade) => setState(() => _incisal = shade),
              ),
              field(_stump, l10n.shadeStump),
              field(_notes, l10n.notes, keyboardType: TextInputType.multiline, maxLines: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(l10n.dueDate),
                subtitle: Text(_dueDate == null ? l10n.notSet : formatDate(_dueDate!)),
                onTap: _pickDueDate,
                trailing: _dueDate == null
                    ? null
                    : IconButton(
                        tooltip: l10n.clear,
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _dueDate = null),
                      ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) text,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: [for (final item in values) DropdownMenuItem(value: item, child: Text(text(item)))],
        onChanged: onChanged,
      ),
    );
  }

  /// A shade picker for the current guide. An empty string means not set.
  Widget _shadeDropdown({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    String? requiredMessage,
  }) {
    final l10n = AppLocalizations.of(context);
    // Keep a value from another guide selectable instead of dropping it.
    final shades = [..._guide.shades, if (value.isNotEmpty && !_guide.shades.contains(value)) value];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label-${_guide.name}'),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        items: [
          DropdownMenuItem(value: '', child: Text(l10n.notSet)),
          for (final shade in shades)
            DropdownMenuItem(value: shade, child: Text(shade, textDirection: TextDirection.ltr)),
        ],
        validator: requiredMessage == null ? null : (shade) => (shade ?? '').isEmpty ? requiredMessage : null,
        onChanged: (shade) => onChanged(shade ?? ''),
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  final ShadeMatch match;
  const _AnalysisRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPixels = match.delta.isFinite;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: ColorSwatchBox(color: Color(match.colorArgb), size: 24),
      title: Text(l10n.shadeLabel(match.name)),
      subtitle: Text(
        hasPixels ? l10n.deltaWithCategory(match.delta.toStringAsFixed(2), match.category.label(l10n)) : l10n.noPixels,
        style: TextStyle(color: hasPixels ? matchCategoryColor(match.category) : null),
      ),
    );
  }
}
