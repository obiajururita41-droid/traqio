/// Shared across Invoices and Payments — a single definition avoids
/// two slightly different enums drifting apart over time.
enum PaymentMethod { cash, bankTransfer, card, pos, mobileMoney, cheque, other }

extension PaymentMethodX on PaymentMethod {
  String get dbValue {
    switch (this) {
      case PaymentMethod.cash: return 'cash';
      case PaymentMethod.bankTransfer: return 'bank_transfer';
      case PaymentMethod.card: return 'card';
      case PaymentMethod.pos: return 'pos';
      case PaymentMethod.mobileMoney: return 'mobile_money';
      case PaymentMethod.cheque: return 'cheque';
      case PaymentMethod.other: return 'other';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.bankTransfer: return 'Bank Transfer';
      case PaymentMethod.card: return 'Card';
      case PaymentMethod.pos: return 'POS';
      case PaymentMethod.mobileMoney: return 'Mobile Money';
      case PaymentMethod.cheque: return 'Cheque';
      case PaymentMethod.other: return 'Other';
    }
  }

  static PaymentMethod? fromDb(String? value) {
    switch (value) {
      case 'cash': return PaymentMethod.cash;
      case 'bank_transfer': return PaymentMethod.bankTransfer;
      case 'card': return PaymentMethod.card;
      case 'pos': return PaymentMethod.pos;
      case 'mobile_money': return PaymentMethod.mobileMoney;
      case 'cheque': return PaymentMethod.cheque;
      case 'other': return PaymentMethod.other;
      default: return null;
    }
  }
}
