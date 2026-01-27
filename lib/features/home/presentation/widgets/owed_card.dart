import 'package:flutter/material.dart';

class OwedCard extends StatelessWidget {
  final IconData icon;
  final String owedText;
  final String amount;
  final Color iconColor;

  OwedCard({
    super.key,
    required this.icon,
    required this.owedText,
    required this.amount,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
       shape: RoundedRectangleBorder(
         side: BorderSide(
           color: Colors.grey.shade400,
           
         ),
         borderRadius: BorderRadius.circular(12)
       ),
         child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 5),
            Text(
              owedText.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 3),
            Text('\$ $amount', style: TextStyle(color: iconColor,fontWeight: FontWeight.bold  ,fontSize: 20)),
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}
