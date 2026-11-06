import 'dart:async';

import 'package:flutter/material.dart';

import '../../../models/weather_snapshot.dart';
import '../../../services/weather/weather_service.dart';

class DashboardWeatherCard extends StatefulWidget {
  const DashboardWeatherCard({super.key});

  @override
  State<DashboardWeatherCard> createState() => _DashboardWeatherCardState();
}

class _DashboardWeatherCardState extends State<DashboardWeatherCard> {
  final _weatherService = const WeatherService();
  WeatherSnapshot? _weather;
  String? _error;
  bool _loading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _loadWeather(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadWeather({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final weather = await _weatherService.fetchCurrentWeather();
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weather = _weather;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: weather == null ? null : () => _showWeatherDetails(context, weather),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: _loading && weather == null
              ? const Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading local weather...'),
                  ],
                )
              : weather == null
                  ? _WeatherError(message: _error, onRetry: _loadWeather)
                  : _WeatherContent(
                      weather: weather,
                      refreshing: _loading,
                      onRefresh: _loadWeather,
                    ),
        ),
      ),
    );
  }

  void _showWeatherDetails(BuildContext context, WeatherSnapshot weather) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Real-time weather', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Current conditions at your device location', style: textTheme.bodyMedium),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: colors.primaryContainer.withValues(alpha: 0.55),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_weatherIconFor(weather.condition), size: 44, color: colors.primary),
                          const SizedBox(width: 14),
                          Text(weather.temperatureLabel, style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(weather.condition, style: textTheme.titleMedium)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _DetailRow(label: 'Humidity', value: '${weather.humidity}%'),
                      _DetailRow(label: 'Wind speed', value: '${weather.windSpeed.round()} km/h'),
                      _DetailRow(label: 'Updated', value: weather.observedLabel),
                      _DetailRow(
                        label: 'Location',
                        value: '${weather.latitude.toStringAsFixed(4)}, ${weather.longitude.toStringAsFixed(4)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('Data source: Open-Meteo using your current GPS location.', style: textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({
    required this.weather,
    required this.refreshing,
    required this.onRefresh,
  });

  final WeatherSnapshot weather;
  final bool refreshing;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(_weatherIconFor(weather.condition), size: 48, color: theme.colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live weather', style: theme.textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(
                '${weather.temperatureLabel}  |  ${weather.condition}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Humidity ${weather.humidity}%  |  Wind ${weather.windSpeed.round()} km/h\n${weather.observedLabel}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh weather',
          onPressed: refreshing ? null : onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

}

IconData _weatherIconFor(String condition) {
  if (condition == 'Clear sky') return Icons.wb_sunny_rounded;
  if (condition == 'Rainy' || condition == 'Thunderstorm') {
    return Icons.cloudy_snowing;
  }
  if (condition == 'Foggy' || condition == 'Cloudy') {
    return Icons.cloud_rounded;
  }
  return Icons.wb_cloudy_rounded;
}

class _WeatherError extends StatelessWidget {
  const _WeatherError({required this.message, required this.onRetry});

  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 36),
          const SizedBox(width: 12),
          Expanded(child: Text(message ?? 'Weather is unavailable right now.')),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
}
