import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/colors.dart';
import 'cleaning_screen.dart';

// Enum for robot states
enum RobotState { docked, cleaning, returning, error }

// Enum for cleaning modes
enum CleaningMode { full, edge, spot }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  RobotState _currentState = RobotState.docked;
  CleaningMode _selectedMode = CleaningMode.full;
  double _batteryLevel = 1.0;
  bool _showCycleCompleteNotification = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showCycleCompleteNotification = false);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- Helper Functions ---
  Color _getThemeColor() {
    if (_currentState == RobotState.cleaning) {
      switch (_selectedMode) {
        case CleaningMode.full:
          return Colors.blueAccent;
        case CleaningMode.edge:
          return Colors.lightBlue;
        case CleaningMode.spot:
          return Colors.indigo;
      }
    }
    switch (_currentState) {
      case RobotState.docked:
        return Colors.blue.shade700;
      case RobotState.returning:
        return Colors.lightBlueAccent;
      case RobotState.error:
        return Colors.blue; // Error also blue
      case RobotState.cleaning:
        throw UnimplementedError();
    }
  }

  String _getStatusText(RobotState state) {
    switch (state) {
      case RobotState.docked:
        return 'Docked - ${(_batteryLevel * 100).toInt()}% Charged';
      case RobotState.cleaning:
        return 'Cleaning...';
      case RobotState.returning:
        return 'Returning to Dock...';
      case RobotState.error:
        return 'Error: Brush Stuck';
    }
  }

  String _getModeText(CleaningMode mode) {
    switch (mode) {
      case CleaningMode.full:
        return 'Full Clean';
      case CleaningMode.edge:
        return 'Edge Clean';
      case CleaningMode.spot:
        return 'Spot Clean';
    }
  }

  void _triggerError() {
    Haptics.vibrate(HapticsType.heavy);
    setState(() => _currentState = RobotState.error);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: CurvedAnimation(
              parent: _animationController, curve: Curves.elasticInOut),
          child: AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.blue), // Error icon blue
                SizedBox(width: 10),
                Text('Error Detected')
              ],
            ),
            content: const Text(
                'The robot\'s main brush appears to be stuck. Please check for obstructions and try again.'),
            actions: [
              TextButton(
                child: const Text('OK',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () => _resolveError(context),
              )
            ],
          ),
        );
      },
    );
  }

  void _resolveError(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
    setState(() => _currentState = RobotState.docked);
  }

  void _toggleCleaning() {
    Haptics.vibrate(HapticsType.light);
    setState(() {
      _showCycleCompleteNotification = false;
      if (_currentState == RobotState.cleaning) {
        _currentState = RobotState.returning;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _currentState = RobotState.docked);
        });
      } else {
        _currentState = RobotState.cleaning;
      }
    });
  }

  void _returnToDock() {
    Haptics.vibrate(HapticsType.light);
    setState(() {
      _showCycleCompleteNotification = false;
      _currentState = RobotState.returning;
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _currentState = RobotState.docked);
      });
    });
  }

  void _showModesBottomSheet(BuildContext context) {
    Haptics.vibrate(HapticsType.selection);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Cleaning Mode',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 16),
                    _buildModeTile(context, 'Full Clean',
                        'Cleans the entire accessible area.', CleaningMode.full),
                    _buildModeTile(context, 'Edge Clean',
                        'Follows walls to clean perimeters.', CleaningMode.edge),
                    _buildModeTile(context, 'Spot Clean',
                        'Cleans a small area in a spiral.', CleaningMode.spot),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    final activeColor = _getThemeColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rosie',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 25),
        ),
        elevation: 0,
        flexibleSpace: AnimatedContainer(
          duration: const Duration(seconds: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [activeColor.withOpacity(0.9), activeColor.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Icon(Icons.bug_report,
                  key: ValueKey(_currentState),
                  color: Colors.red),
            ),
            tooltip: 'Simulate Error',
            onPressed: _triggerError,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _showCycleCompleteNotification
                        ? _buildNotificationBar(activeColor)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 500),
                    style: TextStyle(
                        fontSize: 16, color: activeColor, fontWeight: FontWeight.w600),
                    child: Text(_getStatusText(_currentState)),
                  ),
                  const SizedBox(height: 24),
                  _buildLastCleanedStats(activeColor),
                  const SizedBox(height: 24),
                  _buildMapWithRobot(activeColor),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: _buildActionWideButton(
                              _currentState == RobotState.cleaning ? 'Stop' : 'Clean',
                              _toggleCleaning,
                              _currentState == RobotState.cleaning ? activeColor : activeColor)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildActionWideButton('Return to Dock', _returnToDock, activeColor)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Live View",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CleaningScreen())),
                      child: Hero(
                        tag: "liveView",
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: Shimmer.fromColors(
                            baseColor: Colors.blueGrey.shade700,
                            highlightColor: Colors.blueGrey.shade500,
                            child: Container(
                              color: Colors.blueGrey.shade900,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.videocam, color: Colors.white, size: 50),
                                  SizedBox(height: 10),
                                  Text("Tap to open Live View", style: TextStyle(color: Colors.white))
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMaintenanceAlert(activeColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBar(Color activeColor) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      child: Card(
        color: activeColor.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                  child: Text('Cleaning Cycle Complete!',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastCleanedStats(Color activeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: activeColor.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Last Cleaned', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                          children: [
                            TextSpan(text: '45'),
                            TextSpan(text: ' m²', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
                          ]),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor)),
                  ])),
          const SizedBox(width: 24),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Duration', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
                          children: [
                            TextSpan(text: '60'),
                            TextSpan(text: ' min', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal))
                          ]),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: 0.9,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor)),
                  ])),
        ],
      ),
    );
  }

  Widget _buildMapWithRobot(Color activeColor) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: _currentState == RobotState.cleaning ? 150 : 50,
              top: _currentState == RobotState.cleaning ? 120 : 200,
              child: Column(
                children: [
                  AnimatedRotation(
                    turns: _currentState == RobotState.cleaning ? 1 : 0,
                    duration: const Duration(seconds: 2),
                    child: Icon(Icons.smart_toy_rounded, color: activeColor, size: 36),
                  ),
                  Text(_getModeText(_selectedMode),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: activeColor)),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              child: ElevatedButton.icon(
                onPressed: () => _showModesBottomSheet(context),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                label: const Text('More Modes', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100.withOpacity(0.9),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionWideButton(String label, VoidCallback onPressed, Color buttonColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 6,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(label,
              key: ValueKey(label), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildMaintenanceAlert(Color activeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: activeColor, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Maintenance Alert:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
              SizedBox(height: 4),
              Text('Filter life at 10%', style: TextStyle(color: Colors.black54, fontSize: 14)),
            ]),
          ),
          TextButton(
            onPressed: () => Haptics.vibrate(HapticsType.light),
            child: Text('View', style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTile(BuildContext context, String title, String subtitle, CleaningMode mode) {
    final bool isSelected = _selectedMode == mode;
    final Color activeColor = _getThemeColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.smart_toy, color: isSelected ? activeColor : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? activeColor : Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.black54)),
        trailing: isSelected ? Icon(Icons.check_circle, color: activeColor) : null,
        tileColor: isSelected ? activeColor.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() => _selectedMode = mode);
          Navigator.pop(context);
        },
      ),
    );
  }
}
