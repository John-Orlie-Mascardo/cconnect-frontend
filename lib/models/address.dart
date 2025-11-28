class Address {
  final String? id;
  final String province;
  final String city;
  final String barangay;
  final String postalCode;
  final String streetDetails;
  final bool isDefault;

  Address({
    this.id,
    required this.province,
    required this.city,
    required this.barangay,
    required this.postalCode,
    required this.streetDetails,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'province': province,
      'city': city,
      'barangay': barangay,
      'postalCode': postalCode,
      'streetDetails': streetDetails,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      barangay: json['barangay'] ?? '',
      postalCode: json['postalCode'] ?? '',
      streetDetails: json['streetDetails'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  String get fullAddress {
    return '$streetDetails, $barangay, $city, $province $postalCode';
  }
}
