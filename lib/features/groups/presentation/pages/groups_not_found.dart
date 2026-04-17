import 'package:flutter/material.dart';

import 'create_group.dart';


class GroupsNotFound extends StatelessWidget {
  const GroupsNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // image
              ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(13),
                  child: Image.asset('assets/group_spilit.webp')),
              const SizedBox(height: 10),
              //   No groups found
              Text(
                'No Groups yet',
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Create a group to start splitting bills with friends and family.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
        
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      // horizontal: 10,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (_)=>CreateNewGroupScreen()));
                  },
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.group,size: 25,),
                        const SizedBox(width: 10,),
                        Text('Create Group',style: TextStyle(
                            fontSize: 17
                        ),)]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
