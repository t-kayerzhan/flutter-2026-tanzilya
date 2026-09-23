import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            'assets/ava.jpg',
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Schyler',
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          university,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.outline,
            fontFamily: 'Schyler',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
