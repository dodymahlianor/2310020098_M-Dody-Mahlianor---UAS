class SurahSummary {
  final int nomor;
  final String nama; // arab
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull; // "01".."06"

  SurahSummary({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
  });

  factory SurahSummary.fromJson(Map<String, dynamic> j) => SurahSummary(
        nomor: j["nomor"],
        nama: j["nama"] ?? "",
        namaLatin: j["namaLatin"] ?? "",
        jumlahAyat: j["jumlahAyat"] ?? 0,
        tempatTurun: j["tempatTurun"] ?? "",
        arti: j["arti"] ?? "",
        deskripsi: j["deskripsi"] ?? "",
        audioFull: Map<String, String>.from(j["audioFull"] ?? const {}),
      );
}

class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final Map<String, String> audio; // "01".."06"

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> j) => Ayat(
        nomorAyat: j["nomorAyat"] ?? 0,
        teksArab: j["teksArab"] ?? "",
        teksLatin: j["teksLatin"] ?? "",
        teksIndonesia: j["teksIndonesia"] ?? "",
        audio: Map<String, String>.from(j["audio"] ?? const {}),
      );
}

class SurahDetail {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final Map<String, String> audioFull;
  final List<Ayat> ayat;

  SurahDetail({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audioFull,
    required this.ayat,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> j) => SurahDetail(
        nomor: j["nomor"],
        nama: j["nama"] ?? "",
        namaLatin: j["namaLatin"] ?? "",
        jumlahAyat: j["jumlahAyat"] ?? 0,
        tempatTurun: j["tempatTurun"] ?? "",
        arti: j["arti"] ?? "",
        deskripsi: j["deskripsi"] ?? "",
        audioFull: Map<String, String>.from(j["audioFull"] ?? const {}),
        ayat: (j["ayat"] as List? ?? const []).map((e) => Ayat.fromJson(e)).toList(),
      );
}

class TafsirAyat {
  final int ayat;
  final String teks;

  TafsirAyat({required this.ayat, required this.teks});

  factory TafsirAyat.fromJson(Map<String, dynamic> j) =>
      TafsirAyat(ayat: j["ayat"] ?? 0, teks: j["teks"] ?? "");
}

class TafsirSurah {
  final int nomor;
  final String namaLatin;
  final List<TafsirAyat> tafsir;

  TafsirSurah({required this.nomor, required this.namaLatin, required this.tafsir});

  factory TafsirSurah.fromJson(Map<String, dynamic> j) => TafsirSurah(
        nomor: j["nomor"],
        namaLatin: j["namaLatin"] ?? "",
        tafsir: (j["tafsir"] as List? ?? const []).map((e) => TafsirAyat.fromJson(e)).toList(),
      );
}
