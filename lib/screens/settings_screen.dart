import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> consumables = [
    {'name': 'Main Brush', 'percent': 0.85, 'status': 'Approx 120 hours left'},
    {'name': 'Side Brush', 'percent': 0.60, 'status': 'Approx 80 hours left'},
    {'name': 'Filter', 'percent': 0.25, 'status': 'Replace soon'},
  ];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    // Animate consumables in sequence
    Future.delayed(const Duration(milliseconds: 200), () {
      for (int i = 0; i < consumables.length; i++) {
        Future.delayed(Duration(milliseconds: i * 250), () {
          _listKey.currentState?.insertItem(i);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Rosie - Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White title text
          ),
        ),
        elevation: 2,
        backgroundColor: Colors.blue, // Blue AppBar
        foregroundColor: Colors.white, // White icons (back button, actions)
      ),

      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              'Maintenance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),

          // Animated Consumables
          AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: 0,
            itemBuilder: (context, index, animation) {
              final item = consumables[index];
              return _buildAnimatedConsumable(
                item['name'],
                item['percent'],
                item['status'],
                animation,
              );
            },
          ),

          const Divider(height: 30),

          // General Settings
          _buildSettingsTile(
            icon: Icons.volume_up,
            title: "Voice & Volume",
            trailing: _buildResetButton(),
          ),
          _buildSettingsTile(
            icon: Icons.wifi,
            title: "Wi-Fi Settings",
            subtitle: "Tap to change",
            trailing: _buildResetButton(),
          ),

          const Divider(height: 30),

          // About
          _buildSettingsTile(icon: Icons.location_searching, title: "Find My Robot"),
          _buildSettingsTile(icon: Icons.pets, title: "Find My Robeo"),

          const Divider(height: 30),

          // Firmware Update
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.system_update, color: primaryColor),
              title: const Text("Firmware Update"),
              subtitle: const Text("Version: 1.2.5"),
              trailing: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Check If Updates"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedConsumable(
      String name,
      double percent,
      String status,
      Animation<double> animation,
      ) {
    Color progressColor =
    percent > 0.5 ? primaryColor : (percent > 0.2 ? Colors.orange : Colors.red);

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    "${(percent * 100).toInt()}%",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: progressColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(status,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing,
        onTap: () {},
      ),
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text("Reset"),
    );
  }
}
