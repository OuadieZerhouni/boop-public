import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_services.dart';
import '../core/settings.dart';
import '../core/test_env.dart';
import '../l10n/l10n.dart';
import 'names.dart';
import 'theme.dart';
import 'widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BoopColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_rounded, color: BoopColors.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l.settingsTitle, style: display(context, 24)),
      ),
      body: ValueListenableBuilder<AppSettings>(
        valueListenable: s.settings,
        builder: (context, set, _) {
          // Always copy from the LIVE value: two quick toggles between rebuilds
          // must not overwrite each other with a stale snapshot.
          void update(AppSettings v) => s.settings.update(v);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              StickerCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _SwitchRow(
                      key: const ValueKey('set-sound'),
                      icon: Icons.volume_up_rounded,
                      label: l.settingsSound,
                      value: set.sound,
                      onChanged: (v) => update(s.settings.value.copyWith(sound: v)),
                    ),
                    const _Divider(),
                    _SwitchRow(
                      key: const ValueKey('set-haptics'),
                      icon: Icons.vibration_rounded,
                      label: l.settingsHaptics,
                      value: set.haptics,
                      onChanged: (v) => update(s.settings.value.copyWith(haptics: v)),
                    ),
                    const _Divider(),
                    _SwitchRow(
                      key: const ValueKey('set-motion'),
                      icon: Icons.motion_photos_off_rounded,
                      label: l.settingsReduceMotion,
                      subtitle: l.settingsReduceMotionHint,
                      value: set.reduceMotion,
                      onChanged: (v) => update(s.settings.value.copyWith(reduceMotion: v)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              StickerCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _TapRow(
                  key: const ValueKey('set-language'),
                  icon: Icons.translate_rounded,
                  label: l.settingsLanguage,
                  trailing: set.languageCode == null ? l.languageSystem : kLanguageNames[set.languageCode]!,
                  onTap: () => _pickLanguage(context, s),
                ),
              ),
              const SizedBox(height: 16),
              StickerCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _TapRow(icon: Icons.star_rounded, label: l.settingsRate, onTap: _rate),
                    const _Divider(),
                    _TapRow(icon: Icons.privacy_tip_rounded, label: l.settingsPrivacy, onTap: () => _open(s.remote.value.privacyUrl)),
                    const _Divider(),
                    _TapRow(icon: Icons.help_rounded, label: l.settingsSupport, onTap: () => _open(s.remote.value.supportUrl)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              StickerCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _TapRow(
                  key: const ValueKey('set-reset'),
                  icon: Icons.restart_alt_rounded,
                  label: l.settingsReset,
                  danger: true,
                  onTap: () => _confirmReset(context, s),
                ),
              ),
              const SizedBox(height: 24),
              Center(child: Text(l.madeWithLove, style: body(context, 14, color: BoopColors.inkSoft), textAlign: TextAlign.center)),
              const SizedBox(height: 4),
              Center(child: Text(l.settingsVersion(s.remote.appVersion), style: body(context, 13, color: BoopColors.inkSoft))),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _open(String url) async {
    if (skipDeviceOnlyWork) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  static Future<void> _rate() async {
    if (skipDeviceOnlyWork) return;
    try {
      await InAppReview.instance.openStoreListing(appStoreId: kAppStoreId.isEmpty ? null : kAppStoreId);
    } catch (_) {}
  }

  Future<void> _pickLanguage(BuildContext context, AppServices s) async {
    final l = context.l10n;
    final current = s.settings.value.languageCode;
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: BoopColors.cream,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              key: const ValueKey('lang-system'),
              title: Text(l.languageSystem, style: body(context, 17)),
              trailing: current == null ? const Icon(Icons.check_rounded, color: BoopColors.heart) : null,
              onTap: () => Navigator.pop(context, ''),
            ),
            for (final code in kSupportedLanguages)
              ListTile(
                key: ValueKey('lang-$code'),
                title: Text(kLanguageNames[code]!, style: body(context, 17)),
                trailing: current == code ? const Icon(Icons.check_rounded, color: BoopColors.heart) : null,
                onTap: () => Navigator.pop(context, code),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    final v = s.settings.value;
    await s.settings.update(picked.isEmpty ? v.copyWith(clearLanguage: true) : v.copyWith(languageCode: picked));
  }

  Future<void> _confirmReset(BuildContext context, AppServices s) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius), side: const BorderSide(color: BoopColors.ink, width: kOutline)),
        title: Text(l.resetTitle, style: display(context, 22)),
        content: Text(l.resetBody, style: body(context, 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel, style: body(context, 16, weight: FontWeight.w800))),
          TextButton(
            key: const ValueKey('reset-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.resetConfirm, style: body(context, 16, weight: FontWeight.w800, color: const Color(0xFFD9364F))),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await s.resetProgress();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.resetDone, style: body(context, 15, color: Colors.white))));
  }
}

/// The numeric App Store id, once GATE-ASC-RECORD is cleared. Empty until then
/// ("Rate" falls back to the in-app review sheet's own lookup).
const kAppStoreId = '6820154498';

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, thickness: 1.5, indent: 56, color: BoopColors.creamDeep);
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({super.key, required this.icon, required this.label, required this.value, required this.onChanged, this.subtitle});
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: BoopColors.ink),
      title: Text(label, style: body(context, 17, weight: FontWeight.w700)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: body(context, 13, color: BoopColors.inkSoft)),
    );
  }
}

class _TapRow extends StatelessWidget {
  const _TapRow({super.key, required this.icon, required this.label, required this.onTap, this.trailing, this.danger = false});
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFD9364F) : BoopColors.ink;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(label, style: body(context, 17, weight: FontWeight.w700, color: color)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing!, style: body(context, 15, color: BoopColors.inkSoft)),
          Icon(Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: BoopColors.inkSoft),
        ],
      ),
    );
  }
}
