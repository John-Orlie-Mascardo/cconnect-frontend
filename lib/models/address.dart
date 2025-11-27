class Address {
  final String?
  id; // null for new addresses, backend assigns this after creation
  final String region;
  final String province;
  final String city;
  final String barangay;
  final String postalCode;
  final String
  streetDetails; // Combined field: street name, building, house no.
  final bool isDefault;

  Address({
    this.id,
    required this.region,
    required this.province,
    required this.city,
    required this.barangay,
    required this.postalCode,
    required this.streetDetails,
    this.isDefault = false,
  });

  // Allows creating a modified copy of an address (useful for editing)
  Address copyWith({
    String? id,
    String? region,
    String? province,
    String? city,
    String? barangay,
    String? postalCode,
    String? streetDetails,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      region: region ?? this.region,
      province: province ?? this.province,
      city: city ?? this.city,
      barangay: barangay ?? this.barangay,
      postalCode: postalCode ?? this.postalCode,
      streetDetails: streetDetails ?? this.streetDetails,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Convert to JSON for API requests (backend will need this format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'province': province,
      'city': city,
      'barangay': barangay,
      'postalCode': postalCode,
      'streetDetails': streetDetails,
      'isDefault': isDefault,
    };
  }

  // Create Address from API response
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      region: json['region'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      barangay: json['barangay'] ?? '',
      postalCode: json['postalCode'] ?? '',
      streetDetails: json['streetDetails'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
