import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/checkin.dart';

class CheckInCard extends StatelessWidget {
  final CheckIn checkIn;
  final VoidCallback onTap;

  const CheckInCard({super.key, required this.checkIn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: File(checkIn.photoPath).existsSync()
                ? Image.file(File(checkIn.photoPath), fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
        ),
        title: Text(checkIn.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(checkIn.createdAt)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}