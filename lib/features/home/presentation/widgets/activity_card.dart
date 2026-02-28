import 'package:flutter/material.dart';
import 'package:roomly/features/home/presentation/widgets/payment_status.dart';

class AcitivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final double amount;
  final String status;
  final Color iconColor;

  const AcitivityCard({
    super.key,
    required this.icon,
    required this.amount,
    required this.description,
    required this.status,
    required this.time,
    required this.title,
    required this.iconColor,
  });

  Color amountColor(double amount) {
    if (amount < 0) {
      return Colors.red;
    } else if (amount > 0) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String formatAmount(double amount) {
    final sign = amount > 0 ? '+' : '';
    return '$sign\$${amount.abs().toStringAsFixed(2)}';
  }

  //   PaymentStatus
  PaymentStatus paymentStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'settled':
        return PaymentStatus.settled;
      case 'confirmed':
        return PaymentStatus.confirmed;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PaymentStatus currentStatus = paymentStatusFromString(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        //   icon
        Row(
            children: [
            Padding(
              padding: const EdgeInsets.only(top: 8,right: 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: iconColor.withValues(alpha: 0.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(icon,color: iconColor,),
                ),
              ),
            ),
            // const SizedBox(width: 10,),
            //   title and description and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),
                Text('$description .●$time', style: TextStyle(color: Colors.grey)),
                // Text('●$time', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),


        // amount and payment status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 10,),
            Text(
              formatAmount(amount),
              style: TextStyle(
                color: amountColor(amount),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: currentStatus.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentStatus.label,
                style: TextStyle(
                  color: currentStatus.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
