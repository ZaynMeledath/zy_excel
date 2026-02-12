import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: () {}, child: Text('Load Excel File')),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, child: Text('Save Updated Excel')),
        ],
      ),
    );
  }
}
