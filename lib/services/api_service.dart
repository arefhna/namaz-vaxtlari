import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/azerbaijan_cities.dart';

class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriDate;
  final String gregorianDate;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.gregorianDate,
  });
}

class ApiService {
  static Future<PrayerTimes> getPrayerTimes(City city) async {
    final today = DateTime.now();
    final dateStr =
        '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';

    final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateStr?latitude=${city.lat}&longitude=${city.lng}&method=2');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final timings = data['data']['timings'];
      final date = data['data']['date'];

      return PrayerTimes(
        fajr: _clean(timings['Fajr']),
        sunrise: _clean(timings['Sunrise']),
        dhuhr: _clean(timings['Dhuhr']),
        asr: _clean(timings['Asr']),
        maghrib: _clean(timings['Maghrib']),
        isha: _clean(timings['Isha']),
        hijriDate:
            '${date['hijri']['day']} ${date['hijri']['month']['az'] ?? date['hijri']['month']['en']} ${date['hijri']['year']}',
        gregorianDate:
            '${date['gregorian']['day']} ${date['gregorian']['month']['en']} ${date['gregorian']['year']}',
      );
    }
    throw Exception('Namaz vaxtları alına bilmədi');
  }

  static String _clean(String time) {
    return time.split(' ')[0];
  }
}
