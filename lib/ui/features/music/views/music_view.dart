import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pipes/data/services/music_service.dart';
import 'package:pipes/ui/core/theme/app_colors.dart';
import 'package:pipes/ui/core/widgets/tangible_button.dart';
import 'package:pipes/ui/providers.dart';

/// Full-screen Playlist page (opened from Home).
class MusicView extends ConsumerWidget {
  const MusicView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    AppColors.currentTheme = settings.theme;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Round3DButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    iconSize: 18,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Playlist  •  සිංදු',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 46),
                ],
              ),
            ),
            const Expanded(child: PlaylistPanel()),
          ],
        ),
      ),
    );
  }
}

/// Opens the playlist as a bottom sheet (used inside the game).
Future<void> showPlaylistSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Playlist  •  සිංදු',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.headingDark,
                  ),
                ),
                const Expanded(child: PlaylistPanel()),
              ],
            ),
          );
        },
      );
    },
  );
}

class PlaylistPanel extends ConsumerStatefulWidget {
  const PlaylistPanel({super.key});

  @override
  ConsumerState<PlaylistPanel> createState() => _PlaylistPanelState();
}

class _PlaylistPanelState extends ConsumerState<PlaylistPanel> {
  final TextEditingController _linkController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _linkController.text = data!.text!.trim());
    }
  }

  Future<void> _add() async {
    final music = ref.read(musicProvider);
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final err = await music.addFromYoutube(_linkController.text);
    if (!mounted) return;
    if (err == null) {
      _linkController.clear();
    } else {
      setState(() => _error = err);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final music = ref.watch(musicProvider);
    return ListenableBuilder(
      listenable: music,
      builder: (context, _) {
        final current = music.current;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _nowPlayingCard(music, current),
            const SizedBox(height: 18),
            _addLinkCard(music),
            const SizedBox(height: 18),
            Text(
              'Songs (${music.tracks.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.headingDark,
              ),
            ),
            const SizedBox(height: 10),
            if (music.tracks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'තාම සිංදු නෑ. උඩින් YouTube link එකක් දාලා Add කරන්න 🎵',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.subtext, fontSize: 13),
                ),
              ),
            for (var i = 0; i < music.tracks.length; i++)
              _trackTile(music, i),
          ],
        );
      },
    );
  }

  Widget _nowPlayingCard(MusicController music, MusicTrack? current) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.accent.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            current?.title ?? 'Nothing playing',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
            ),
          ),
          if (current != null && current.author.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                current.author,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          const SizedBox(height: 10),
          StreamBuilder<Duration>(
            stream: music.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final dur = music.duration ?? Duration.zero;
              final max = dur.inMilliseconds.toDouble();
              final double value =
                  pos.inMilliseconds.toDouble().clamp(0.0, max > 0 ? max : 1.0).toDouble();
              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: value,
                      max: max > 0 ? max : 1.0,
                      onChanged: current == null || max <= 0
                          ? null
                          : (v) => music.seek(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos),
                          style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(_fmt(dur),
                          style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Round3DButton(
                icon: Icons.shuffle_rounded,
                size: 40,
                iconSize: 18,
                active: music.shuffle,
                onTap: music.toggleShuffle,
              ),
              Round3DButton(
                icon: Icons.skip_previous_rounded,
                size: 46,
                iconSize: 26,
                onTap: music.tracks.isEmpty ? null : music.previous,
              ),
              Round3DButton(
                icon: music.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 60,
                iconSize: 34,
                color: const Color(0xFF43A047),
                iconColor: Colors.white,
                onTap: music.tracks.isEmpty ? null : music.togglePlayPause,
              ),
              Round3DButton(
                icon: Icons.skip_next_rounded,
                size: 46,
                iconSize: 26,
                onTap: music.tracks.isEmpty ? null : music.next,
              ),
              Round3DButton(
                icon: Icons.repeat_one_rounded,
                size: 40,
                iconSize: 18,
                active: music.repeatOne,
                onTap: music.toggleRepeatOne,
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _addLinkCard(MusicController music) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.headingDark.withValues(alpha: 0.10),
            offset: const Offset(0, 5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YouTube link එකක් දාන්න',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.headingDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Auto download වෙලා playlist එකට add වෙනවා (internet ඕනේ).',
            style: TextStyle(fontSize: 11.5, color: AppColors.subtext),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _linkController,
                  enabled: !music.isDownloading,
                  keyboardType: TextInputType.url,
                  style: TextStyle(color: AppColors.headingDark, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'https://youtube.com/watch?v=…',
                    hintStyle: TextStyle(color: AppColors.subtext, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.accent, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Round3DButton(
                icon: Icons.content_paste_rounded,
                size: 44,
                iconSize: 18,
                onTap: music.isDownloading ? null : _paste,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TangibleButton(
            text: music.isDownloading ? 'Downloading…' : 'Add to Playlist',
            icon: Icons.download_rounded,
            height: 44,
            backgroundColor: AppColors.accent,
            textColor: Colors.white,
            onPressed: music.isDownloading ? null : _add,
          ),
          if (music.isDownloading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: music.downloadProgress > 0 ? music.downloadProgress : null,
                minHeight: 8,
                color: AppColors.accent,
                backgroundColor: AppColors.gridLines,
              ),
            ),
          ],
          if (music.status != null) ...[
            const SizedBox(height: 8),
            Text(
              music.status!,
              style: TextStyle(fontSize: 12, color: AppColors.subtext),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFE53935)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trackTile(MusicController music, int i) {
    final t = music.tracks[i];
    final isCurrent = i == music.currentIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => music.playIndex(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.accent.withValues(alpha: 0.16)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? AppColors.accent : AppColors.border,
              width: isCurrent ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.headingDark.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isCurrent && music.isPlaying
                    ? Icons.equalizer_rounded
                    : Icons.music_note_rounded,
                color: isCurrent ? AppColors.accent : AppColors.subtext,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.headingDark,
                      ),
                    ),
                    if (t.author.isNotEmpty)
                      Text(
                        t.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: AppColors.subtext),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFE53935),
                onPressed: () => music.removeAt(i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
