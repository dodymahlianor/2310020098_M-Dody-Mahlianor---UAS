class QariOption {
  final String key; // "01".."06"
  final String name;

  const QariOption(this.key, this.name);
}

/// 6 Qari sesuai API v2 EQuran.id :contentReference[oaicite:2]{index=2}
const qariOptions = <QariOption>[
  QariOption("01", "Abdullah Al-Juhany"),
  QariOption("02", "Abdul Muhsin Al-Qasim"),
  QariOption("03", "Abdurrahman As-Sudais"),
  QariOption("04", "Ibrahim Al-Dossari"),
  QariOption("05", "Misyari Rasyid Al-Afasy"),
  QariOption("06", "Yasser Al-Dosari"),
];
