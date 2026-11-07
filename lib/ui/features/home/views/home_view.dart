import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/ui/core/l10n.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/widgets/tangible_button.dart';
import 'package:pipes/ui/core/widgets/theme_picker_sheet.dart';
import 'package:pipes/ui/features/about/views/about_view.dart';
import 'package:pipes/ui/features/game/views/game_view.dart';
import 'package:pipes/ui/features/leaderboard/views/leaderboard_view.dart';
import 'package:pipes/ui/features/music/views/music_view.dart';
import 'package:pipes/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:pipes/ui/features/level_select/views/level_select_view.dart';
import 'package:pipes/ui/features/settings/views/settings_view.dart';
import 'package:pipes/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final state = ref.watch(homeViewModelProvider);
    AppColors.currentTheme = settings.theme;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Round3DButton(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFFF9800),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardView(),
                      ),
                    ),
                  ),
                  if (state.progress != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        L10n.t('Level ${state.progress!.currentLevel}', 'මට්ටම ${state.progress!.currentLevel}'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingDark,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Round3DButton(
                    icon: Icons.library_music_rounded,
                    iconColor: const Color(0xFFE91E63),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MusicView(),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2979FF).withValues(alpha: 0.45),
                              blurRadius: 26,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.asset(
                            'assets/icon.png',
                            width: 190,
                            height: 190,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      TangibleButton(
                        text: L10n.t('Play', 'ක්‍රීඩා කරන්න'),
                        icon: Icons.play_arrow_rounded,
                        backgroundColor: AppColors.accent,
                        textColor: Colors.white,
                        onPressed: state.isLoading
                            ? null
                            : () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GameView(
                                      levelNumber: state.progress?.currentLevel ?? 1,
                                    ),
                                  ),
                                );
                                ref.read(homeViewModelProvider.notifier).loadProgress();
                              },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TangibleButton(
                              text: L10n.t('Levels', 'මට්ටම්'),
                              isSecondary: true,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LevelSelectView(),
                                  ),
                                );
                                ref.read(homeViewModelProvider.notifier).loadProgress();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TangibleButton(
                              text: L10n.t('Random', 'අහඹු'),
                              isSecondary: true,
                              onPressed: () => _showDifficultyDialog(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TangibleButton(
                              text: L10n.t('Playlist', 'සිංදු ලැයිස්තුව'),
                              icon: Icons.music_note_rounded,
                              isSecondary: true,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MusicView(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TangibleButton(
                              text: L10n.t('Leaderboard', 'ප්‍රමුඛ පුවරුව'),
                              icon: Icons.emoji_events_rounded,
                              isSecondary: true,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LeaderboardView(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TangibleButton(
                        text: L10n.t('How to Play', 'ක්‍රීඩා කරන ආකාරය'),
                        isSecondary: true,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HowToPlayView(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TangibleButton(
                        text: L10n.t('Themes', 'තේමා'),
                        icon: Icons.palette_rounded,
                        isSecondary: true,
                        onPressed: () => showThemePickerSheet(context),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TangibleButton(
                              text: L10n.t('Settings', 'සැකසුම්'),
                              icon: Icons.settings_rounded,
                              isSecondary: true,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsView(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TangibleButton(
                              text: L10n.t('About', 'ගැන'),
                              icon: Icons.info_rounded,
                              isSecondary: true,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutView(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _stageLabel(String stage) {
    const si = {
      'Easy': 'පහසු',
      'Medium': 'මධ්‍යම',
      'Hard': 'අමාරු',
      'Expert': 'විශේෂඥ',
      'Master': 'ශූරයා',
    };
    return L10n.t(stage, si[stage] ?? stage);
  }

  void _showDifficultyDialog(BuildContext context) {
    final stages = [
      'Easy',
      'Medium',
      'Hard',
      'Expert',
      'Master',
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  L10n.t('Choose Difficulty', 'දුෂ්කරතාව තෝරන්න'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  L10n.d('Play a dynamically generated Pipes puzzle.', 'අහඹු ලෙස හදන Pipes ප්‍රහේලිකාවක් ක්‍රීඩා කරන්න.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.subtext,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (final stage in stages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TangibleButton(
                    text: _stageLabel(stage),
                    height: 44,
                    isSecondary: true,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameView(
                            levelNumber: 0,
                            isRandom: true,
                            randomDifficulty: stage,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  L10n.t('Cancel', 'අවලංගු කරන්න'),
                  style: TextStyle(
                    color: AppColors.subtext,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
