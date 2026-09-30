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
  static const List<String> _azMonths = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'İyun',
    'İyul', 'Avqust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr',
  ];

  static const List<String> _hijriMonths = [
    'Məhərrəm', 'Səfər', 'Rəbiül-əvvəl', 'Rəbiüs-sani',
    'Cəmadiyəl-əvvəl', 'Cəmadiyəs-sani', 'Rəcəb', 'Şaban',
    'Ramazan', 'Şəvval', 'Zilqədə', 'Zilhiccə',
  ];

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
      final hijri = data['data']['date']['hijri'];

      // Azərbaycan dilində tarix
      final gregorianAz =
          '${today.day} ${_azMonths[today.month - 1]} ${today.year}';

      // Hicri tarix (rəqəmlərlə)
      final hijriMonthIndex =
          int.tryParse(hijri['month']['number'].toString()) ?? 1;
      final hijriAz =
          '${hijri['day']} ${_hijriMonths[hijriMonthIndex - 1]} ${hijri['year']}';

      return PrayerTimes(
        fajr: _clean(timings['Fajr']),
        sunrise: _clean(timings['Sunrise']),
        dhuhr: _clean(timings['Dhuhr']),
        asr: _clean(timings['Asr']),
        maghrib: _clean(timings['Maghrib']),
        isha: _clean(timings['Isha']),
        hijriDate: hijriAz,
        gregorianDate: gregorianAz,
      );
    }
    throw Exception('Namaz vaxtları alına bilmədi');
  }

  static String _clean(String time) {
    return time.split(' ')[0];
  }
}
