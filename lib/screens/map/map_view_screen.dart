import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: AppColors.accent),
            SizedBox(height: 16),
            Text('Map View', style: TextStyle(color: AppColors.textPrimary, fontSize: 20)),
            SizedBox(height: 8),
            Text('Google Maps integration available', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
