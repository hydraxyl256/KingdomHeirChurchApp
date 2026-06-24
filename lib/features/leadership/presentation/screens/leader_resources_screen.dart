import 'package:flutter/material.dart';

class LeaderResourcesScreen extends StatelessWidget {
  const LeaderResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leader Resources')),
      body: const Center(child: Text('Leader Toolkit & Resources')),
    );
  }
}
