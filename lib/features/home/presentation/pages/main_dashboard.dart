import 'dart:ui';
import 'package:flutter/material.dart';

import '../widgets/activity_card.dart';
import '../widgets/owed_card.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  double amount = 1250.00;

  List<AcitivityCard> activities = [
    AcitivityCard(
      icon: Icons.home,
      amount: 1135.99,
      description: 'eat dinner ',
      status: 'pending',
      time: 'Today',
      title: 'eating dinner',
      iconColor: Colors.green,
    ),
    AcitivityCard(
      icon: Icons.home,
      amount: 1135.99,
      description: 'eat dinner ',
      status: 'pending',
      time: 'Today',
      title: 'eating dinner',
      iconColor: Colors.green,
    ),
    AcitivityCard(
      icon: Icons.home,
      amount: 1135.99,
      description: 'eat dinner ',
      status: 'pending',
      time: 'Today',
      title: 'eating dinner',
      iconColor: Colors.green,
    ),
    AcitivityCard(
      icon: Icons.home,
      amount: 1135.99,
      description: 'eat dinner ',
      status: 'pending',
      time: 'Today',
      title: 'eating dinner',
      iconColor: Colors.green,
    ),
    AcitivityCard(
      icon: Icons.home,
      amount: 1135.99,
      description: 'eat dinner ',
      status: 'pending',
      time: 'Today',
      title: 'eating dinner',
      iconColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.person),

                const Expanded(
                  child: Center(
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          //card section
          Container(
            width: 600,
            margin: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),

            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTALNET STANDING',
                        style: TextStyle(color: Colors.grey[200]),
                      ),
                      Text(
                        '${amount >= 0 ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: amount >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 200,
                        padding: EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.trending_up, color: Colors.white),
                            const SizedBox(width: 6),
                            const Text(
                              '% increase this month',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: [
              //you are owed , card
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 3),
                child: OwedCard(
                  icon: Icons.north_east_outlined,
                  iconColor: Colors.green,
                  owedText: 'you are owed ',
                  amount: '4500',
                ),
              ),
              //   you owed card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 18, left: 5),
                  child: OwedCard(
                    icon: Icons.south_west_rounded,
                    iconColor: Colors.red,
                    owedText: 'you owe ',
                    amount: '4500',
                  ),
                ),
              ),
            ],
          ),

          //   Recent activity and veiw all
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Veiw all ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                itemCount: activities.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(bottom: 10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(

                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: activities[index],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
