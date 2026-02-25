import 'package:flutter/material.dart';

enum PaymentStatus { pending, settled, confirmed }

extension PaymentStatusUI on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.settled:
        return 'SETTLED';
      case PaymentStatus.confirmed:
        return 'CONFIRMED';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.settled:
        return Colors.green;
      case PaymentStatus.confirmed:
        return Colors.blue;
    }
  }
}
