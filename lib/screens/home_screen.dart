import 'package:flutter/material.dart';
import '../data/azerbaijan_cities.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'city_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  City _selectedCity = azerbaijanCities[0];
  PrayerTimes? _times;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final t = await ApiService.getPrayerTimes(_selectedCity);
      setState(() {
        _times = t;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Vaxtlar alına bilmədi. İnterneti yoxlayın.';
        _loading = false;
      });
    }
  }

  Future<void> _pickCity() async {
    final result = await Navigator.push<City>(
      context,
      MaterialPageRoute(builder: (_) => const CitySelectionScreen()),
    );
    if (result != null) {
      setState(() => _selectedCity = result);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Vaxtları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _load,
                          child: const Text('Yenidən cəhd et')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCityCard(),
                      const SizedBox(height: 16),
                      if (_times != null) ...[
                        _buildDateCard(_times!),
                        const SizedBox(height: 16),
                        _prayerTile('İmsaq', _times!.fajr,
                            Icons.nights_stay, const Color(0xFF1A237E)),
                        _prayerTile('Günəş', _times!.sunrise,
                            Icons.wb_sunny, const Color(0xFFFF8F00)),
                        _prayerTile('Zöhr', _times!.dhuhr,
                            Icons.wb_sunny_outlined, const Color(0xFFFFA000)),
                        _prayerTile('Əsr', _times!.asr,
                            Icons.wb_cloudy, const Color(0xFFEF6C00)),
                        _prayerTile('Məğrib', _times!.maghrib,
                            Icons.wb_twilight, const Color(0xFFD84315)),
                        _prayerTile('İşa', _times!.isha,
                            Icons.nightlight_round, const Color(0xFF283593)),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          '© 2026 Arif Qocayev',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCityCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_city,
            color: AppTheme.primaryGreen, size: 32),
        title: Text(
          _selectedCity.name,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Bölgəni dəyişmək üçün toxunun'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _pickCity,
      ),
    );
  }

  Widget _buildDateCard(PrayerTimes t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppTheme.accentGold),
                const SizedBox(width: 10),
                Expanded(child: Text(t.gregorianDate)),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.mosque, color: AppTheme.accentGold),
                const SizedBox(width: 10),
                Expanded(child: Text(t.hijriDate)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _prayerTile(
      String name, String time, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
