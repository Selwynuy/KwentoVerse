import 'package:flutter/material.dart';

class StudentSearchPage extends StatelessWidget {
  const StudentSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Search',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          Text('Student Search (stub) – wire actual search UI later.'),
        ],
      ),
    );
  }
}

