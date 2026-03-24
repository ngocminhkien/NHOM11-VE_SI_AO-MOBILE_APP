import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trung tâm trợ giúp')),
      body: const Center(child: Text('Trợ giúp và hỗ trợ')),
    );
  }
}
