import 'package:flutter/material.dart';
import 'package:shadesmaster/app/app_scope.dart';
import 'package:shadesmaster/app/app_settings.dart';
import 'package:shadesmaster/l10n/app_localizations.dart';
import 'package:shadesmaster/main.dart';
import 'package:shadesmaster/orders/shade_guide.dart';
import 'package:shadesmaster/orders/shade_guide_labels.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AppSettings _settings = AppScope.of(context).settings;
  late final _dentist = TextEditingController(text: _settings.defaults.dentistName);
  late final _clinic = TextEditingController(text: _settings.defaults.clinicName);
  late final _phone = TextEditingController(text: _settings.defaults.clinicPhone);
  late final _lab = TextEditingController(text: _settings.defaults.labName);

  @override
  void dispose() {
    for (final controller in [_dentist, _clinic, _phone, _lab]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveDefaults() {
    _settings.defaults = _settings.defaults.copyWith(
      dentistName: _dentist.text.trim(),
      clinicName: _clinic.text.trim(),
      clinicPhone: _phone.text.trim(),
      labName: _lab.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = AppScope.of(context).settings;

    Widget field(TextEditingController controller, String label, {TextInputType? keyboardType}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          // Phone numbers read left to right in Arabic too.
          textDirection: keyboardType == TextInputType.phone ? TextDirection.ltr : null,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          onChanged: (_) => _saveDefaults(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
              ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
            ],
            selected: {settings.locale.languageCode},
            onSelectionChanged: (selection) => settings.locale = Locale(selection.first),
          ),
          const SizedBox(height: 24),
          Text(l10n.defaultsSection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          field(_dentist, l10n.dentistName),
          field(_clinic, l10n.clinicName),
          field(_phone, l10n.clinicPhone, keyboardType: TextInputType.phone),
          field(_lab, l10n.labName),
          const SizedBox(height: 8),
          Text(l10n.shadeGuide),
          const SizedBox(height: 8),
          SegmentedButton<ShadeGuide>(
            segments: [
              for (final guide in ShadeGuide.values) ButtonSegment(value: guide, label: Text(guide.label(l10n))),
            ],
            selected: {settings.defaults.shadeGuide},
            onSelectionChanged: (selection) => setState(() {
              settings.defaults = settings.defaults.copyWith(shadeGuide: selection.first);
            }),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.licenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: appVersion,
              applicationLegalese: l10n.basedOn,
            ),
          ),
        ],
      ),
    );
  }
}
