import 'package:flutter/material.dart';
import '../models/surah_models.dart';

class AyatTile extends StatelessWidget {
  final Ayat ayat;
  final TextStyle arabStyle;
  final VoidCallback? onPlay;

  const AyatTile({
    super.key,
    required this.ayat,
    required this.arabStyle,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text("${ayat.nomorAyat}", style: TextStyle(fontWeight: FontWeight.w900, color: cs.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Ayat ${ayat.nomorAyat}",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: onPlay == null ? "Audio tidak tersedia" : "Putar audio ayat",
                onPressed: onPlay,
                icon: Icon(onPlay == null ? Icons.volume_off_rounded : Icons.play_circle_fill_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ayat.teksArab,
            textAlign: TextAlign.right,
            style: arabStyle,
          ),
          const SizedBox(height: 8),
          Text(
            ayat.teksLatin.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Text(
            ayat.teksIndonesia,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
