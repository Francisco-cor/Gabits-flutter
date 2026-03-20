import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabits/generated/l10n/app_localizations.dart';
import 'package:gabits/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsScreenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _SectionHeader(title: l.settingsAppearanceSection),
          _SettingsTile(
            leading: Icon(Icons.palette_outlined,
                color: theme.colorScheme.primary),
            title: l.settingsThemeMode,
            subtitle: _themeModeLabel(settings.themeMode, l),
            onTap: () => _showThemePicker(context, ref, settings.themeMode, l),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          _SectionHeader(title: l.settingsLanguageSection),
          _SettingsTile(
            leading: Icon(Icons.language_outlined,
                color: theme.colorScheme.primary),
            title: l.settingsLanguageLabel,
            subtitle: _localeLabel(settings.locale),
            onTap: () => _showLanguagePicker(context, ref, settings.locale, l),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          _SectionHeader(title: l.settingsAboutSection),
          _SettingsTile(
            leading: Icon(Icons.info_outline_rounded,
                color: theme.colorScheme.primary),
            title: l.settingsAppName,
            subtitle: l.settingsAppDescription,
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode, AppLocalizations l) {
    switch (mode) {
      case ThemeMode.light:
        return l.settingsThemeLight;
      case ThemeMode.dark:
        return l.settingsThemeDark;
      case ThemeMode.system:
        return l.settingsThemeSystem;
    }
  }

  String _localeLabel(Locale? locale) {
    if (locale == null) return 'System';
    if (locale.languageCode == 'es') return 'Español';
    return 'English';
  }

  void _showThemePicker(BuildContext context, WidgetRef ref,
      ThemeMode current, AppLocalizations l) {
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.settingsThemeMode,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _ThemeOption(
                icon: Icons.light_mode_outlined,
                label: l.settingsThemeLight,
                selected: current == ThemeMode.light,
                onTap: () {
                  notifier.setThemeMode(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                label: l.settingsThemeDark,
                selected: current == ThemeMode.dark,
                onTap: () {
                  notifier.setThemeMode(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
              _ThemeOption(
                icon: Icons.brightness_auto_outlined,
                label: l.settingsThemeSystem,
                selected: current == ThemeMode.system,
                onTap: () {
                  notifier.setThemeMode(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref,
      Locale? current, AppLocalizations l) {
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.settingsLanguageLabel,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _LanguageOption(
                flag: '🇬🇧',
                label: 'English',
                selected: current?.languageCode == 'en',
                onTap: () {
                  notifier.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              _LanguageOption(
                flag: '🇪🇸',
                label: 'Español',
                selected: current?.languageCode == 'es',
                onTap: () {
                  notifier.setLocale(const Locale('es'));
                  Navigator.pop(ctx);
                },
              ),
              _LanguageOption(
                flag: '🌐',
                label: l.settingsThemeSystem,
                selected: current == null,
                onTap: () {
                  notifier.setLocale(null);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: leading,
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant))
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon,
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant),
      title: Text(label,
          style: TextStyle(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal)),
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label,
          style: TextStyle(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.normal)),
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
