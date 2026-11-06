class DeliveryAddress {
  const DeliveryAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pinCode,
  });

  final String fullName;
  final String phoneNumber;
  final String addressLine;
  final String city;
  final String state;
  final String pinCode;

  String get shortLabel => '$city, $state - $pinCode';

  String get formattedAddress =>
      '$fullName, $phoneNumber\n$addressLine\n$city, $state - $pinCode';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pinCode': pinCode,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      fullName: (map['fullName'] as String?) ?? '',
      phoneNumber: (map['phoneNumber'] as String?) ?? '',
      addressLine: (map['addressLine'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      state: (map['state'] as String?) ?? '',
      pinCode: (map['pinCode'] as String?) ?? '',
    );
  }
}
