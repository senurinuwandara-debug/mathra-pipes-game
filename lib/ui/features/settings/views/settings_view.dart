import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/domain/models/app_settings.dart';
import 'package:pipes/ui/core/l10n.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/widgets/emoji_rain.dart';
import 'package:pipes/ui/core/widgets/tangible_button.dart';
import 'package:pipes/ui/core/widgets/theme_picker_sheet.dart';
import 'package:pipes/ui/features/about/views/about_view.dart';
import 'package:pipes/ui/features/leaderboard/views/leaderboard_view.dart';
import 'package:pipes/ui/features/music/views/music_view.dart';
import 'package:pipes/ui/providers.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Round3DButton(
                    icon: Icons.close_rounded,
                    iconSize: 20,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        L10n.t('Settings', 'සැකසුම්'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 46),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                children: [
                  _sectionTitle(L10n.t('Language', 'භාෂාව')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final lang in AppLanguage.values) ...[
                        Expanded(
                          child: TangibleButton(
                            text: lang.label,
                            height: 44,
                            isSecondary: settings.language != lang,
                            backgroundColor: settings.language == lang
                                ? AppColors.accent
                                : AppColors.surface,
                            textColor: settings.language == lang
                                ? Colors.white
                                : AppColors.headingDark,
                            onPressed: () => ref
                                .read(settingsProvider.notifier)
                                .setLanguage(lang),
                          ),
                        ),
                        if (lang != AppLanguage.values.last)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),

                  _divider(),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${L10n.t('Theme', 'තේමාව')}  •  ${settings.theme.displayName}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingDark,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => showThemePickerSheet(context),
                        icon: Icon(Icons.palette_rounded,
                            size: 18, color: AppColors.accent),
                        label: Text(
                          L10n.t('All themes', 'සියලු තේමා'),
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 46,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppThemePreset.values.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final preset = AppThemePreset.values[index];
                        final isSelected = settings.theme == preset;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(settingsProvider.notifier)
                                .setTheme(preset);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: preset.bg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? preset.accent
                                    : preset.border,
                                width: isSelected ? 2.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: preset.accent.withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: preset.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  _divider(),

                  _gameToggle(
                    label: L10n.t('Hints', 'ඉඟි'),
                    value: settings.isHintEnabled,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleHintEnabled(val);
                    },
                  ),

                  _divider(),

                  _sectionTitle(L10n.t('Music', 'සිංදු')),
                  const SizedBox(height: 10),
                  _gameToggle(
                    label: L10n.t('Auto-play playlist in game', 'ක්‍රීඩාවේදී සිංදු ස්වයංක්‍රීයව ධාවනය'),
                    value: settings.autoPlayMusic,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setAutoPlayMusic(val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: L10n.t('Open Playlist', 'සිංදු ලැයිස්තුව'),
                    icon: Icons.library_music_rounded,
                    isSecondary: true,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MusicView()),
                    ),
                  ),

                  _divider(),

                  _sectionTitle(L10n.t('Emoji Effect', 'Emoji වැස්ස')),
                  const SizedBox(height: 4),
                  Text(
                    L10n.d('You can turn it on/off with the 🎉 button inside the game.', 'Game එක ඇතුලේ 🎉 බටන් එකෙන් on/off කරන්න පුළුවන්.'),
                    style: TextStyle(fontSize: 11.5, color: AppColors.subtext),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final speed in EmojiSpeed.values) ...[
                        Expanded(
                          child: TangibleButton(
                            text: L10n.t(speed.label, speed.sinhala),
                            height: 44,
                            isSecondary: settings.emojiSpeed != speed,
                            backgroundColor: settings.emojiSpeed == speed
                                ? AppColors.accent
                                : AppColors.surface,
                            textColor: settings.emojiSpeed == speed
                                ? Colors.white
                                : AppColors.headingDark,
                            onPressed: () => ref
                                .read(settingsProvider.notifier)
                                .setEmojiSpeed(speed),
                          ),
                        ),
                        if (speed != EmojiSpeed.values.last)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: [
                      for (final pack in EmojiPack.all)
                        SizedBox(
                          width: 104,
                          child: TangibleButton(
                            text: pack.name,
                            height: 40,
                            isSecondary: settings.emojiPackId != pack.id,
                            backgroundColor: settings.emojiPackId == pack.id
                                ? AppColors.accent
                                : AppColors.surface,
                            textColor: settings.emojiPackId == pack.id
                                ? Colors.white
                                : AppColors.headingDark,
                            onPressed: () => ref
                                .read(settingsProvider.notifier)
                                .setEmojiPack(pack.id),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  EmojiRainPreview(
                    emojis: settings.emojiPack.emojis,
                    speed: settings.emojiSpeed,
                    button: (running, toggle) => TangibleButton(
                      text: running
                          ? L10n.t('Stop preview', 'නවත්වන්න')
                          : L10n.t('Preview effect', 'බලන්න'),
                      icon: running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      height: 44,
                      backgroundColor:
                          running ? const Color(0xFFE53935) : AppColors.primary,
                      textColor: running ? Colors.white : AppColors.headingDark,
                      onPressed: toggle,
                    ),
                  ),

                  _divider(),

                  _sectionTitle(L10n.t('Player', 'ක්‍රීඩකයා')),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: L10n.t('Leaderboard', 'ප්‍රමුඛ පුවරුව'),
                    icon: Icons.emoji_events_rounded,
                    isSecondary: true,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaderboardView()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: L10n.t('Change player name', 'නම වෙනස් කරන්න'),
                    icon: Icons.person_rounded,
                    isSecondary: true,
                    onPressed: () => showPlayerNameDialog(
                      context,
                      ref.read(leaderboardProvider),
                      title: 'Player නම',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: L10n.t('About', 'ගැන'),
                    icon: Icons.info_rounded,
                    backgroundColor: AppColors.primary,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutView()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TangibleButton(
                    text: L10n.t('Reset Progress', 'ප්‍රගතිය මකන්න'),
                    isSecondary: true,
                    height: 48,
                    backgroundColor: AppColors.surface,
                    textColor: const Color(0xFFFF5252),
                    borderColor: const Color(0x55FF5252),
                    onPressed: () => _confirmReset(context, ref),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.headingDark,
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(vertical: 18),
    );
  }

  Widget _gameToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.headingDark,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value
                    ? AppColors.accent
                    : AppColors.headingDark.withValues(alpha: 0.12),
                border: Border.all(
                  color: value ? AppColors.accent : AppColors.border,
                  width: 1.0,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        offset: const Offset(0, 1.5),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF5252).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10n.t('Reset progress?', 'ප්‍රගතිය මකන්නද?'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                L10n.d('All solved puzzles, best times, and saved games will be permanently erased.', 'විසඳූ සියලු ප්‍රහේලිකා, හොඳම වේලාවන් සහ සුරකින ලද ක්‍රීඩා ස්ථිරවම මැකී යනු ඇත.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColors.subtext,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TangibleButton(
                      text: L10n.t('Cancel', 'අවලංගු කරන්න'),
                      isSecondary: true,
                      height: 44,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TangibleButton(
                      text: L10n.t('Reset', 'මකන්න'),
                      backgroundColor: const Color(0xFFD32F2F),
                      textColor: Colors.white,
                      borderColor: const Color(0xFFFF5252),
                      height: 44,
                      onPressed: () async {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .resetProgress();
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
