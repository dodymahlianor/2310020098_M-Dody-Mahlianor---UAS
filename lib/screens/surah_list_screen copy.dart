import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/equran_api.dart';
import '../models/surah_models.dart';
import '../state/app_settings.dart';
import '../widgets/qari_picker_sheet.dart';
import '../widgets/surah_card.dart';
import 'about_screen.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  static const route = "/surah";

  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final _api = EquranApi();
  late Future<List<SurahSummary>> _future;
  final _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _api.fetchSurahList();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _api.fetchSurahList();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Surah"),
        actions: [
          IconButton(
            tooltip: "Pilih Qari",
            onPressed: () => showModalBottomSheet(
              context: context,
              showDragHandle: false,
              isScrollControlled: true,
              builder: (_) => const QariPickerSheet(),
            ),
            icon: const Icon(Icons.headphones_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: "Tema",
            onSelected: (v) {
              if (v == "system") settings.setThemeMode(ThemeMode.system);
              if (v == "light") settings.setThemeMode(ThemeMode.light);
              if (v == "dark") settings.setThemeMode(ThemeMode.dark);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "system", child: Text("Tema: Sistem")),
              PopupMenuItem(value: "light", child: Text("Tema: Terang")),
              PopupMenuItem(value: "dark", child: Text("Tema: Gelap")),
            ],
            icon: const Icon(Icons.color_lens_rounded),
          ),
          IconButton(
            tooltip: "About",
            onPressed: () => Navigator.pushNamed(context, AboutScreen.route),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.primaryContainer.withOpacity(0.25), cs.surface],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: TextField(
                controller: _searchC,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Cari surah (nomor / latin / arab)...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SurahSummary>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return _ErrorState(
                      message: "Gagal memuat data.\n${snap.error}",
                      onRetry: _reload,
                    );
                  }

                  final list = snap.data ?? [];
                  final q = _searchC.text.trim().toLowerCase();

                  final filtered = q.isEmpty
                      ? list
                      : list.where((s) {
                          return s.nomor.toString() == q ||
                              s.namaLatin.toLowerCase().contains(q) ||
                              s.nama.toLowerCase().contains(q) ||
                              s.arti.toLowerCase().contains(q) ||
                              s.tempatTurun.toLowerCase().contains(q);
                        }).toList();

                  return RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      itemCount: filtered.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return _HeaderTip(qariKey: settings.selectedQariKey);
                        }
                        final s = filtered[i - 1];
                        return SurahCard(
                          s: s,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SurahDetailScreen.route,
                              arguments: SurahDetailArgs(nomor: s.nomor, heroTag: "surah-${s.nomor}"),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTip extends StatelessWidget {
  final String qariKey;
  const _HeaderTip({required this.qariKey});

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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tips: klik salah satu surah untuk detail ayat.\nDefault Qari aktif: $qariKey (bisa diganti lewat ikon headphone).",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Coba lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
