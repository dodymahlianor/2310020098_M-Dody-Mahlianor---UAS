import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMiniPlayer extends StatelessWidget {
  final AudioPlayer player;
  final String title;

  const AudioMiniPlayer({super.key, required this.player, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snap) {
        final state = snap.data;
        final playing = state?.playing ?? false;
        final processing = state?.processingState ?? ProcessingState.idle;

        final visible = processing != ProcessingState.idle;

        if (!visible) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.graphic_eq_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => playing ? player.pause() : player.play(),
                    icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  ),
                  IconButton(
                    onPressed: player.stop,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, posSnap) {
                  final pos = posSnap.data ?? Duration.zero;
                  final dur = player.duration ?? Duration.zero;

                  double value = 0;
                  if (dur.inMilliseconds > 0) {
                    value = pos.inMilliseconds / dur.inMilliseconds;
                    value = value.clamp(0.0, 1.0);
                  }

                  return Row(
                    children: [
                      Text(_fmt(pos), style: Theme.of(context).textTheme.labelMedium),
                      Expanded(
                        child: Slider(
                          value: value,
                          onChanged: (v) {
                            if (dur == Duration.zero) return;
                            final target = dur * v;
                            player.seek(target);
                          },
                        ),
                      ),
                      Text(_fmt(dur), style: Theme.of(context).textTheme.labelMedium),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    final h = d.inHours;
    return h > 0 ? "$h:$m:$s" : "$m:$s";
  }
}
