import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// 1. Ensure you import your model
import '../models/trash_record.dart'; 

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // 2. Add the <TrashRecord> type here
  late Box<TrashRecord> historyBox; 

  @override
  void initState() {
    super.initState();
    // 3. Add the <TrashRecord> type to the Hive.box call
    historyBox = Hive.box<TrashRecord>('history'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _confirmClearHistory(),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        // 4. Ensure the listenable matches the typed box
        valueListenable: historyBox.listenable(), 
        builder: (context, Box<TrashRecord> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No records found.\nYour scan history will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final reversedIndex = box.length - 1 - index;
              // 5. This will now correctly return a TrashRecord object
              final record = box.getAt(reversedIndex); 
              return _buildHistoryCard(record!, reversedIndex);
            },
          );
        },
      ),
    );
  }

  // 6. Update the parameter type to TrashRecord
  Widget _buildHistoryCard(TrashRecord record, int index) {
    final DateTime dt = record.timestamp;
    final String dateStr = "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: record.imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(record.imagePath!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.restore_from_trash, size: 40, color: Colors.blueGrey),
        title: Text(
          record.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dateStr),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Recycling Guide:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(record.recommendations), 
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => historyBox.deleteAt(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Remove from History', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This will permanently delete all your local recycling records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              historyBox.clear();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}