class BankAccount {
  final String id;
  final String accountHolder;
  final String bankName;
  final String accountNumber;
  final String accountType; // Checking, Savings, Business
  final String? swiftCode;
  final String? iban;
  final bool isDefault;
  final DateTime createdAt;
  final String? documentUrl;

  BankAccount({
    required this.id,
    required this.accountHolder,
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    this.swiftCode,
    this.iban,
    required this.isDefault,
    required this.createdAt,
    this.documentUrl,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      accountHolder: json['accountHolder'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountType: json['accountType'],
      swiftCode: json['swiftCode'],
      iban: json['iban'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      documentUrl: json['documentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountHolder': accountHolder,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'swiftCode': swiftCode,
      'iban': iban,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'documentUrl': documentUrl,
    };
  }

  String get maskedAccountNumber {
    if (accountNumber.length > 4) {
      return '**** ${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }
}
