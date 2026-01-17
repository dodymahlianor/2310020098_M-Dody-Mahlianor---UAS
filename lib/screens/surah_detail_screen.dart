import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/qari.dart';
import '../core/utils.dart';
import '../data/equran_api.dart';
import '../models/surah_models.dart';
import '../state/app_settings.dart';
import '../widgets/audio_mini_player.dart';
import '../widgets/ayat_tile.dart';
import '../widgets/qari_picker_sheet.dart';

class SurahDetailArgs {
  final int nomor;
  final String heroTag;
  const SurahDetailArgs({required this.nomor, required this.heroTag});
}

class SurahDetailScreen extends StatefulWidget {
  static const route = "/detail";

  final SurahDetailArgs args;
  const SurahDetailScreen({super.key, required this.args});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final _api = EquranApi();
  late Future<SurahDetail> _future;
  Future<TafsirSurah>? _tafsirFuture;

  final _player = AudioPlayer();
  String? _nowTitle;
  String? _nowUrl;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchSurahDetail(widget.args.nomor);
    // tafsir sebagai nilai tambah (optional)
    _tafsirFuture = _api.fetchTafsir(widget.args.nomor);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playUrl(String url, String title) async {
    if (_nowUrl == url && _player.playing) {
      await _player.pause();
      return;
    }
    _nowUrl = url;
    _nowTitle = title;
    setState(() {});
    await _player.setUrl(url);
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final selectedQari = qariOptions.firstWhere((e) => e.key == settings.selectedQariKey);

    return Scaffold(
      body: FutureBuilder<SurahDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48),
                    const SizedBox(height: 10),
                    Text("Gagal memuat detail.\n${snap.error}", textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(() => _future = _api.fetchSurahDetail(widget.args.nomor)),
                      child: const Text("Coba lagi"),
                    )
                  ],
                ),
              ),
            );
          }

          final d = snap.data!;
          final fullUrl = d.audioFull[settings.selectedQariKey];

          return DefaultTabController(
            length: 2,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 200,
                      title: Text(d.namaLatin),
                      actions: [
                        IconButton(
                          tooltip: "Pilih Qari",
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const QariPickerSheet(),
                          ),
                          icon: const Icon(Icons.headphones_rounded),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: _HeaderHero(
                          heroTag: widget.args.heroTag,
                          nomor: d.nomor,
                          namaArab: d.nama,
                          arti: d.arti,
                          tempatTurun: d.tempatTurun,
                          jumlahAyat: d.jumlahAyat,
                        ),
                      ),
                      bottom: const TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.format_list_numbered_rounded), text: "Ayat"),
                          Tab(icon: Icon(Icons.info_outline_rounded), text: "Info"),
                        ],
                      ),
                    ),

                    // Controls: audio surah full + info qari
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6)),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.record_voice_over_rounded),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Qari aktif: ${selectedQari.name}",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (fullUrl != null)
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => _playUrl(
                                          fullUrl,
                                          "Surah ${d.namaLatin} (Full) • ${selectedQari.name}",
                                        ),
                                        icon: StreamBuilder<PlayerState>(
                                          stream: _player.playerStateStream,
                                          builder: (_, s) {
                                            final playing = s.data?.playing ?? false;
                                            final same = _nowUrl == fullUrl;
                                            final icon = (same && playing)
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded;
                                            return Icon(icon);
                                          },
                                        ),
                                        label: const Text("Putar Audio Surah (Full)"),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                const Text("Audio full tidak tersedia."),
                              const SizedBox(height: 10),
                              Text(
                                "Kamu juga bisa putar audio per-ayat lewat tombol ▶️ di setiap ayat.",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SliverFillRemaining(
                      child: TabBarView(
                        children: [
                          // TAB AYAT
                          ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                            itemCount: d.ayat.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final a = d.ayat[i];
                              final url = a.audio[settings.selectedQariKey];
                              final title = "${d.namaLatin} • Ayat ${a.nomorAyat} • ${selectedQari.name}";
                              return AyatTile(
                                ayat: a,
                                arabStyle: GoogleFonts.amiri(fontSize: 22, height: 1.7),
                                onPlay: url == null ? null : () => _playUrl(url, title),
                              );
                            },
                          ),

                          // TAB INFO (deskripsi + tafsir optional)
                          _InfoTab(
                            deskripsi: stripHtml(d.deskripsi),
                            tafsirFuture: _tafsirFuture,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Mini Player di bawah
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AudioMiniPlayer(
                    player: _player,
                    title: _nowTitle ?? "Tidak ada audio diputar",
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderHero extends StatelessWidget {
  final String heroTag;
  final int nomor;
  final String namaArab;
  final String arti;
  final String tempatTurun;
  final int jumlahAyat;

  const _HeaderHero({
    required this.heroTag,
    required this.nomor,
    required this.namaArab,
    required this.arti,
    required this.tempatTurun,
    required this.jumlahAyat,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.tertiary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: heroTag,
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: Text(
                "$nomor",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            namaArab,
            style: GoogleFonts.amiri(fontSize: 30, height: 1.1, color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            "Arti: $arti • $tempatTurun • $jumlahAyat ayat",
            style: TextStyle(color: Colors.white.withOpacity(0.92)),
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final String deskripsi;
  final Future<TafsirSurah>? tafsirFuture;

  const _InfoTab({required this.deskripsi, required this.tafsirFuture});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Text("Deskripsi Surah", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(deskripsi),
        const SizedBox(height: 18),
        Text("Tafsir (Nilai Plus)", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        if (tafsirFuture == null)
          const Text("Tafsir tidak dimuat.")
        else
          FutureBuilder<TafsirSurah>(
            future: tafsirFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Text("Gagal memuat tafsir: ${snap.error}");
              }
              final t = snap.data!;
              return Column(
                children: t.tafsir.take(8).map((x) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.6)),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ayat ${x.ayat}", style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text(x.teks),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        const SizedBox(height: 8),
        Text(
          "Catatan: Tafsir ditampilkan sebagian (agar ringan). Kalau mau full, tinggal hilangkan .take(8).",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
