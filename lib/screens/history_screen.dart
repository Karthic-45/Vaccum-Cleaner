import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> history = [
    {
      'title': 'Morning Clean',
      'date': 'Sep 25, 2025',
      'time': '08:00 AM',
      'duration': '45 mins',
      'mode': 'Full Clean',
      'status': 'Completed',
    },
    {
      'title': 'Deep Clean',
      'date': 'Sep 24, 2025',
      'time': '10:00 AM',
      'duration': '1 hr 20 mins',
      'mode': 'Edge Clean',
      'status': 'Completed',
    },
    {
      'title': 'Spot Clean',
      'date': 'Sep 23, 2025',
      'time': '03:30 PM',
      'duration': '20 mins',
      'mode': 'Spot Clean',
      'status': 'Failed',
    },
    {
      'title': 'Draft Schedule',
      'date': 'Sep 22, 2025',
      'time': '02:15 PM',
      'duration': 'Not started',
      'mode': 'Full Clean',
      'status': 'Cancelled',
    },
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    // Animate items one by one when screen opens
    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < history.length; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          _listKey.currentState?.insertItem(i);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cleaning History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White title text
          ),
        ),
        elevation: 2,
        backgroundColor: Colors.blue, // Blue AppBar
        foregroundColor: Colors.white, // White icons (back button, actions)
      ),

      body: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.all(16),
        initialItemCount: 0, // Start empty, then animate in
        itemBuilder: (context, index, animation) {
          final item = history[index];
          return _buildAnimatedHistoryCard(item, animation);
        },
      ),
    );
  }

  Widget _buildAnimatedHistoryCard(
      Map<String, dynamic> item, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0), // Slide from right
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: item['status'] == 'Completed'
                  ? Colors.green.withOpacity(0.2)
                  : item['status'] == 'Failed'
                  ? Colors.red.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              child: Icon(
                item['status'] == 'Completed'
                    ? Icons.check_circle
                    : item['status'] == 'Failed'
                    ? Icons.error
                    : Icons.cancel,
                color: item['status'] == 'Completed'
                    ? Colors.green
                    : item['status'] == 'Failed'
                    ? Colors.red
                    : Colors.orange,
                size: 28,
              ),
            ),
            title: Text(
              item['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${item['date']} • ${item['time']}\n"
                  "Mode: ${item['mode']} • Duration: ${item['duration']}",
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            trailing: Text(
              item['status'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item['status'] == 'Completed'
                    ? Colors.green
                    : item['status'] == 'Failed'
                    ? Colors.red
                    : Colors.orange,
              ),
            ),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }
}
