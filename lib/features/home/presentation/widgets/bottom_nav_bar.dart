// import 'package:flutter/material.dart';
//
// /// Canonical Bottom Navigation Bar for the app.
// ///
// /// UI/Visuals MUST remain unchanged per product constraints.
// /// This widget exposes a simple, stable API for HomeScreen to control tab navigation.
// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//
//   const CustomBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.8),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 10),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: currentIndex,
//         onTap: onTap,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
//         ],
//       ),
//     );
//   }
// }
