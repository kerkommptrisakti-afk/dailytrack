class ParsedActivity {
  final String title;
  final DateTime? date;
  final DateTime? time;

  ParsedActivity({
    required this.title,
    this.date,
    this.time,
  });
}

class NlpParser {
  static final _days = {
    'senin': 1, 'selasa': 2, 'rabu': 3, 'kamis': 4,
    'jumat': 5, 'sabtu': 6, 'minggu': 7,
  };

  static ParsedActivity parse(String input) {
    final lower = input.toLowerCase().trim();
    DateTime? date = _parseDate(lower);
    DateTime? time = _parseTime(lower);
    String title = _cleanTitle(input, lower);

    return ParsedActivity(title: title, date: date, time: time);
  }

  // ── DATE PARSING ───────────────────────────────────────────────
  static DateTime? _parseDate(String text) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Hari ini
    if (text.contains('hari ini')) return today;

    // Besok
    if (text.contains('besok')) return today.add(const Duration(days: 1));

    // Lusa
    if (text.contains('lusa')) return today.add(const Duration(days: 2));

    // Nama hari (Senin, Selasa, dst)
    for (final entry in _days.entries) {
      if (text.contains(entry.key)) {
        return _nextWeekday(today, entry.value);
      }
    }

    // Tanggal spesifik: "tanggal 25", "tgl 25"
    final tglRegex = RegExp(r'tanggal\s+(\d{1,2})|tgl\s+(\d{1,2})');
    final tglMatch = tglRegex.firstMatch(text);
    if (tglMatch != null) {
      final day = int.tryParse(tglMatch.group(1) ?? tglMatch.group(2) ?? '');
      if (day != null && day >= 1 && day <= 31) {
        DateTime candidate = DateTime(now.year, now.month, day);
        if (candidate.isBefore(today)) {
          candidate = DateTime(now.year, now.month + 1, day);
        }
        return candidate;
      }
    }

    return null;
  }

  // ── TIME PARSING ───────────────────────────────────────────────
  static DateTime? _parseTime(String text) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);

    // "jam setengah 8", "setengah delapan"
    final halfRegex = RegExp(
      r'(?:jam\s+)?setengah\s+(\w+)',
    );
    final halfMatch = halfRegex.firstMatch(text);
    if (halfMatch != null) {
      final hourWord = halfMatch.group(1) ?? '';
      final hour = _wordToNumber(hourWord);
      if (hour != null) {
        return base.add(Duration(hours: hour - 1, minutes: 30));
      }
    }

    // "jam 5 pagi", "jam 5 sore", "jam 05:30", "pukul 5"
    final jamRegex = RegExp(
      r'(?:jam|pukul)\s+(\d{1,2})(?:[:\.](\d{2}))?(?:\s+(pagi|siang|sore|malam))?',
    );
    final jamMatch = jamRegex.firstMatch(text);
    if (jamMatch != null) {
      int hour = int.tryParse(jamMatch.group(1) ?? '0') ?? 0;
      final minute = int.tryParse(jamMatch.group(2) ?? '0') ?? 0;
      final period = jamMatch.group(3);

      if (period == 'sore' || period == 'malam') {
        if (hour < 12) hour += 12;
      } else if (period == 'siang') {
        if (hour < 12) hour = 12;
      } else if (period == 'pagi') {
        if (hour == 12) hour = 0;
      } else {
        // Tanpa keterangan: jam 1-6 → asumsi pagi, 7-11 → pagi, 12+ → tetap
        if (hour >= 1 && hour <= 6) hour = hour; // biarkan
      }

      return base.add(Duration(hours: hour, minutes: minute));
    }

    // "5 pagi", "8 malam" tanpa kata "jam"
    final simpleRegex = RegExp(
      r'\b(\d{1,2})\s+(pagi|siang|sore|malam)\b',
    );
    final simpleMatch = simpleRegex.firstMatch(text);
    if (simpleMatch != null) {
      int hour = int.tryParse(simpleMatch.group(1) ?? '0') ?? 0;
      final period = simpleMatch.group(2);
      if (period == 'sore' || period == 'malam') {
        if (hour < 12) hour += 12;
      } else if (period == 'siang') {
        if (hour < 12) hour = 12;
      }
      return base.add(Duration(hours: hour));
    }

    return null;
  }

  // ── TITLE CLEANING ─────────────────────────────────────────────
  static String _cleanTitle(String original, String lower) {
    String title = original;

    // Hapus kata-kata waktu dan tanggal
    final removePatterns = [
      RegExp(r'\b(hari ini|besok|lusa)\b', caseSensitive: false),
      RegExp(r'\b(senin|selasa|rabu|kamis|jumat|sabtu|minggu)\b', caseSensitive: false),
      RegExp(r'\btanggal\s+\d{1,2}\b', caseSensitive: false),
      RegExp(r'\btgl\s+\d{1,2}\b', caseSensitive: false),
      RegExp(r'\b(?:jam|pukul)\s+\d{1,2}(?:[:.]\d{2})?(?:\s+(?:pagi|siang|sore|malam))?\b', caseSensitive: false),
      RegExp(r'\bsetengah\s+\w+\b', caseSensitive: false),
      RegExp(r'\b\d{1,2}\s+(?:pagi|siang|sore|malam)\b', caseSensitive: false),
      RegExp(r'\b(saya ada|ada jadwal|jadwal|kegiatan|acara)\b', caseSensitive: false),
    ];

    for (final pattern in removePatterns) {
      title = title.replaceAll(pattern, '');
    }

    // Bersihkan spasi berlebih dan capitalize
    title = title.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (title.isNotEmpty) {
      title = title[0].toUpperCase() + title.substring(1);
    }

    // Kalau title kosong setelah dibersihkan, pakai original
    if (title.trim().isEmpty) title = original;

    return title.trim();
  }

  // ── HELPERS ────────────────────────────────────────────────────
  static DateTime _nextWeekday(DateTime from, int weekday) {
    int daysUntil = weekday - from.weekday;
    if (daysUntil <= 0) daysUntil += 7;
    return from.add(Duration(days: daysUntil));
  }

  static int? _wordToNumber(String word) {
    const map = {
      'satu': 1, 'dua': 2, 'tiga': 3, 'empat': 4,
      'lima': 5, 'enam': 6, 'tujuh': 7, 'delapan': 8,
      'sembilan': 9, 'sepuluh': 10, 'sebelas': 11, 'dua belas': 12,
    };
    return map[word.toLowerCase()] ?? int.tryParse(word);
  }
}
