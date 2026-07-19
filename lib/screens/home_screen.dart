import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/storage_service.dart';
import '../models/checkin.dart';
import '../widgets/checkin_card.dart';
import '../widgets/empty_state.dart';
import 'new_checkin_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FieldCheck')),
      body: ValueListenableBuilder(
        valueListenable: StorageService.box.listenable(),
        builder: (context, Box<CheckIn> box, _) {
          final items = StorageService.getAllCheckIns();
          if (items.isEmpty) return const EmptyState();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final checkIn = items[index];
              return CheckInCard(
                checkIn: checkIn,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(checkIn: checkIn)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewCheckInScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}