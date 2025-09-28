import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import '../utils/colors.dart';

class CleaningScreen extends StatefulWidget {
  const CleaningScreen({super.key});

  @override
  State<CleaningScreen> createState() => _CleaningScreenState();
}

class _CleaningScreenState extends State<CleaningScreen> with SingleTickerProviderStateMixin {
  bool _isManualControl = false;
  bool _isPaused = false;

  // Joystick state
  Offset _joystickOffset = Offset.zero;
  String _joystickDirection = ''; // 'up', 'down', 'left', 'right'

  late AnimationController _joystickTapController;
  late Animation<double> _joystickTapAnimation;

  final double _joystickRadius = 120; // Outer joystick radius
  final double _thumbRadius = 40; // Thumbstick radius

  @override
  void initState() {
    super.initState();
    _joystickTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _joystickTapAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _joystickTapController, curve: Curves.easeOutCubic),
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _joystickTapController.dispose();
    super.dispose();
  }

  void _showTemporaryAction(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Haptics.vibrate(HapticsType.light);
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          _isManualControl ? 'Rosie - Manual Control' : 'Rosie - Cleaning...',
          style: const TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isManualControl ? Icons.smart_toy_outlined : Icons.gamepad_outlined,
              color: textColor,
              size: 26,
            ),
            tooltip: _isManualControl ? 'Switch to Auto Cleaning' : 'Switch to Manual Control',
            onPressed: () {
              Haptics.vibrate(HapticsType.medium);
              setState(() {
                _isManualControl = !_isManualControl;
                _joystickOffset = Offset.zero;
                _joystickDirection = '';
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [
            _buildVideoFeed(),
            const SizedBox(height: 28),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isManualControl
                    ? _buildManualControlPanel(key: const ValueKey('manual_panel'))
                    : _buildLiveCleaningPanel(key: const ValueKey('live_panel')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoFeed() {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.pexels.com/photos/1643383/pexels-photo-1643383.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCleaningPanel({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatColumn('Time', '00:25:18', Icons.timer),
            _buildStatColumn('Area', '15 m²', Icons.square_foot),
            _buildStatColumn('Battery', '78%', Icons.battery_charging_full),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: 0.78,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTogglePauseButton(),
            _buildBottomRcButton(Icons.stop_circle_outlined, 'Return to Dock'),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTogglePauseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.vibrate(HapticsType.medium);
          setState(() {
            _isPaused = !_isPaused;
          });
          _showTemporaryAction(_isPaused ? 'Paused' : 'Resumed');
        },
        borderRadius: BorderRadius.circular(25),
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.1),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _isPaused ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _isPaused ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                  color: _isPaused ? Colors.orange : Colors.green, size: 36),
              const SizedBox(height: 8),
              Text(_isPaused ? 'Resume' : 'Pause',
                  style: TextStyle(
                      color: _isPaused ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualControlPanel({required Key key}) {
    return Column(
      key: key,
      children: [
        const Text('RC Joystick',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 30),
        _buildJoystick(),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomRcButton(Icons.flash_on_outlined, 'Suction Power'),
            _buildBottomRcButton(Icons.videocam_outlined, 'Record Video'),
            _buildBottomRcButton(Icons.stop_circle_outlined, 'Return to Dock'),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildJoystick() {
    return Center(
      child: GestureDetector(
        onPanStart: (_) {
          _joystickTapController.forward(from: 0.0);
        },
        onPanUpdate: (details) {
          setState(() {
            _joystickOffset += details.delta;
            if (_joystickOffset.distance > _joystickRadius - _thumbRadius) {
              _joystickOffset = Offset.fromDirection(
                  _joystickOffset.direction, _joystickRadius - _thumbRadius);
            }
            _updateJoystickDirection();
          });
        },
        onPanEnd: (_) {
          _joystickTapController.reverse();
          setState(() {
            _joystickOffset = Offset.zero;
            _joystickDirection = '';
          });
        },
        child: Transform.scale(
          scale: _joystickTapAnimation.value,
          child: Container(
            width: _joystickRadius * 2,
            height: _joystickRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(4, 4)),
                const BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-4, -4)),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: _joystickRadius * 2 - 20,
                  height: _joystickRadius * 2 - 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
                ),
                // Thumb
                Transform.translate(
                  offset: _joystickOffset,
                  child: Container(
                    width: _thumbRadius * 2,
                    height: _thumbRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26, blurRadius: 8, offset: const Offset(2, 2))
                      ],
                    ),
                  ),
                ),
                // Glowing directional arrows
                ...['up', 'down', 'left', 'right'].map((dir) => _buildArrow(dir)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(String direction) {
    Offset offset;
    switch (direction) {
      case 'up':
        offset = Offset(0, -_joystickRadius + 30);
        break;
      case 'down':
        offset = Offset(0, _joystickRadius - 30);
        break;
      case 'left':
        offset = Offset(-_joystickRadius + 30, 0);
        break;
      default:
        offset = Offset(_joystickRadius - 30, 0);
    }

    bool active = _joystickDirection == direction;

    return Transform.translate(
      offset: offset,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? primaryColor.withOpacity(0.5) : Colors.transparent,
          boxShadow: active
              ? [BoxShadow(color: primaryColor.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
              : [],
        ),
        child: Icon(
          direction == 'up'
              ? Icons.keyboard_arrow_up
              : direction == 'down'
              ? Icons.keyboard_arrow_down
              : direction == 'left'
              ? Icons.keyboard_arrow_left
              : Icons.keyboard_arrow_right,
          color: active ? Colors.white : secondaryTextColor,
          size: 36,
        ),
      ),
    );
  }

  void _updateJoystickDirection() {
    double angle = _joystickOffset.direction;
    double distance = _joystickOffset.distance;

    if (distance < 10) {
      _joystickDirection = '';
      return;
    }

    if (angle >= -0.785 && angle < 0.785) {
      _joystickDirection = 'right';
    } else if (angle >= 0.785 && angle < 2.356) {
      _joystickDirection = 'down';
    } else if (angle < -0.785 && angle >= -2.356) {
      _joystickDirection = 'up';
    } else {
      _joystickDirection = 'left';
    }
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  color: secondaryTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(color: textColor, fontSize: 19, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomRcButton(IconData icon, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.vibrate(HapticsType.light);
          _showTemporaryAction('$label clicked!');
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: primaryColor.withOpacity(0.1),
        highlightColor: primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: secondaryTextColor, size: 24),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
