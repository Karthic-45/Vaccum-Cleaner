import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> schedules = [
    {
      'title': 'Morning Clean',
      'subtitle': 'Every Weekday, 8:00 AM',
      'mode': 'Full Clean',
      'active': true,
    },
    {
      'title': 'Deep Clean',
      'subtitle': 'Every Saturday, 10:00 AM',
      'mode': 'Edge Clean',
      'active': true,
    },
    {
      'title': 'Draft Schedule',
      'subtitle': 'Not active yet',
      'mode': 'Spot Clean',
      'active': false,
    },
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final modes = ['Full Clean', 'Edge Clean', 'Spot Clean'];
    String selectedMode = modes[0];
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "New Schedule",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Schedule Title",
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedMode,
                  items: modes
                      .map((mode) => DropdownMenuItem(
                    value: mode,
                    child: Text(mode),
                  ))
                      .toList(),
                  onChanged: (val) {
                    selectedMode = val!;
                  },
                  decoration: const InputDecoration(labelText: "Mode"),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    selectedTime == null
                        ? "Pick Time"
                        : selectedTime!.format(context),
                  ),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedTime != null) {
                  final newSchedule = {
                    'title': titleController.text,
                    'subtitle': "At ${selectedTime!.format(context)}",
                    'mode': selectedMode,
                    'active': false,
                  };
                  schedules.insert(0, newSchedule);
                  _listKey.currentState!.insertItem(
                    0,
                    duration: const Duration(milliseconds: 500),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Rosie - Schedule',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        body: AnimatedList(
          key: _listKey,
          padding: const EdgeInsets.all(16),
          initialItemCount: schedules.length,
          itemBuilder: (context, index, animation) {
            final schedule = schedules[index];
            return _buildAnimatedCard(
              schedule['title'],
              schedule['subtitle'],
              schedule['mode'],
              schedule['active'],
                  (bool value) {
                setState(() {
                  schedules[index]['active'] = value;
                });
              },
              animation,
              index,
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddScheduleDialog,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(
      String title,
      String subtitle,
      String mode,
      bool isActive,
      Function(bool) onChanged,
      Animation<double> animation,
      int index,
      ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          onDismissed: (direction) {
            final removedItem = schedules[index];
            setState(() {
              schedules.removeAt(index);
              _listKey.currentState!.removeItem(
                index,
                    (context, animation) => _buildAnimatedCard(
                  removedItem['title'],
                  removedItem['subtitle'],
                  removedItem['mode'],
                  removedItem['active'],
                      (bool value) {},
                  animation,
                  index,
                ),
                duration: const Duration(milliseconds: 400),
              );
            });
          },
          child: GestureDetector(
            onTapDown: (_) => setState(() {}),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isActive
                      ? [
                    Colors.blue.shade400.withOpacity(0.3),
                    Colors.blue.shade100
                  ]
                      : [Colors.grey.shade100, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.cleaning_services,
                    color: isActive ? Colors.blue : Colors.grey,
                    size: 28,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  '$subtitle\nMode: $mode',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                trailing: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Switch.adaptive(
                      value: isActive,
                      onChanged: onChanged,
                      activeColor: Colors.blue,
                    );
                  },
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
