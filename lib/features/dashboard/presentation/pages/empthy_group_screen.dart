import 'package:flutter/material.dart';
import 'package:roomly/features/groups/domain/repositories/group_repository.dart';
import 'package:roomly/features/groups/presentation/pages/create_group.dart';


class EmptyGroupsScreen extends StatelessWidget {
  const EmptyGroupsScreen({super.key});



  @override
  Widget build(BuildContext context) {

    return  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=400',
                    height: 250)),
            const SizedBox(height: 30),
            const Text('Better with Friends',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Create a group to split house bills, travel costs, or dinner checks.',
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=>CreateGroupScreen()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text('Create My First Group',
                  style: TextStyle(color: Colors.white)),
            ),
          ],

        ),
    );
  }
}
