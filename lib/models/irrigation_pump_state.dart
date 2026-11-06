import 'package:cloud_firestore/cloud_firestore.dart';

class IrrigationPumpState {
  const IrrigationPumpState({
    required this.pumpStatus,
    required this.mode,
    this.updatedAt,
  });

  static const IrrigationPumpState defaultState = IrrigationPumpState(
    pumpStatus: 'OFF',
    mode: 'manual',
  );

  final String pumpStatus;
  final String mode;
  final DateTime? updatedAt;

  bool get isPumpOn => pumpStatus.toUpperCase() == 'ON';

  bool get isAutomatic => mode.toLowerCase() == 'automatic';

  factory IrrigationPumpState.fromMap(Map<String, dynamic> map) {
    return IrrigationPumpState(
      pumpStatus: _normalizePumpStatus(map['pumpStatus']),
      mode: _normalizeMode(map['mode']),
      updatedAt: _readDateTime(map['updatedAt'] ?? map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pumpStatus': pumpStatus,
      'mode': mode,
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  static String _normalizePumpStatus(dynamic value) {
    final text = value?.toString().trim().toUpperCase() ?? '';
    if (text == 'ON') {
      return 'ON';
    }
    return 'OFF';
  }

  static String _normalizeMode(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';
    if (text == 'automatic') {
      return 'automatic';
    }
    return 'manual';
  }

  static DateTime? _readDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is num) {
      final millis = value > 1000000000000
          ? value.toInt()
          : value.toInt() * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
    }
    return null;
  }
}
