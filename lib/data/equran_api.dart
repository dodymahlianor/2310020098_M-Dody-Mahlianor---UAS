import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/surah_models.dart';

class EquranApi {
  static const _base = "https://equran.id/api/v2"; // :contentReference[oaicite:4]{index=4}
  final http.Client _client;

  EquranApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<SurahSummary>> fetchSurahList() async {
    final uri = Uri.parse("$_base/surat");
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil daftar surah (${res.statusCode})");
    }
    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final data = (jsonMap["data"] as List).cast<Map<String, dynamic>>();
    return data.map(SurahSummary.fromJson).toList();
  }

  Future<SurahDetail> fetchSurahDetail(int nomor) async {
    final uri = Uri.parse("$_base/surat/$nomor");
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil detail surah (${res.statusCode})");
    }
    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final data = (jsonMap["data"] as Map<String, dynamic>);
    return SurahDetail.fromJson(data);
  }

  Future<TafsirSurah> fetchTafsir(int nomor) async {
    final uri = Uri.parse("$_base/tafsir/$nomor");
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil tafsir (${res.statusCode})");
    }
    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final data = (jsonMap["data"] as Map<String, dynamic>);
    return TafsirSurah.fromJson(data);
  }
}
