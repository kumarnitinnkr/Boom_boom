// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:boom_boom/bloc/bubble_game_bloc.dart';
import 'package:boom_boom/main.dart';
import 'package:boom_boom/services/audio_service.dart'; // Import service
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // REQUIRED for icons

// Global AudioService instance
final AudioService audioService = AudioService();

// ====================================================================
// --- 1. DAZZLING TITLE WIDGET (Handles entrance animation & 3D text) ---
// ====================================================================
class DazzlingTitle extends StatefulWidget {
  const DazzlingTitle({super.key});

  @override
  State<DazzlingTitle> createState() => _DazzlingTitleState();
}

class _DazzlingTitleState extends State<DazzlingTitle> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500), // Increased duration
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.95), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 50),
    ]).animate(_controller);

    _floatAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define colors for the 12 characters (B-U-B-B-L-E [space] B-O-O-M-!)
    final List<Color> titleColors = [
      Colors.redAccent, Colors.yellowAccent, Colors.lightGreenAccent, Colors.cyanAccent, Colors.pinkAccent, Colors.orangeAccent, Colors.transparent,
      Colors.red, Colors.yellow, Colors.lightGreen, Colors.cyan, Colors.pink,
    ];
    // FIX: Changed to the 12-character string that includes the space and exclamation mark
    const String titleText = 'BUBBLE BOOM';

    final List<Widget> coloredLetters = titleText.split('').asMap().entries.map((entry) {
      final int index = entry.key;
      final String letter = entry.value;

      return Text(
        letter,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: titleColors[index % titleColors.length],
          fontFamily: 'GameFont',
          shadows: [
            Shadow(color: Colors.white.withAlpha((255 * 0.8).round()), blurRadius: 5, offset: Offset(0, 0)),
          ],
        ),
      );
    }).toList();


    return SlideTransition(
      position: _floatAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Shadow Layer (Dark color for 3D extrusion)
            Text(
              titleText, // Use the full text for the shadow layer
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.blue[900],
                fontFamily: 'GameFont',
              ),
            ),
            // 2. Top Layer (Multi-Color Text, slightly offset)
            Positioned(
              top: 2.0, left: 2.0,
              child: Row( // Layers individual colored letters
                mainAxisSize: MainAxisSize.min,
                children: coloredLetters,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// --- 2. SOUND TOGGLE BUTTON WIDGET (Handles mute state) ---
// ====================================================================
class SoundToggleButton extends StatefulWidget {
  const SoundToggleButton({super.key});

  @override
  State<SoundToggleButton> createState() => _SoundToggleButtonState();
}

class _SoundToggleButtonState extends State<SoundToggleButton> {
  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    if (_isMuted) {
      audioService.stopBackgroundMusic();
    } else {
      audioService.playBackgroundMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = _isMuted ? FontAwesomeIcons.volumeOff : FontAwesomeIcons.volumeUp;
    final String text = _isMuted ? 'Sound OFF' : 'Sound ON';

    return ElevatedButton(
      onPressed: _toggleMute,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isMuted ? Colors.redAccent : Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        minimumSize: const Size(280, 70),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 15,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'GameFont',
            ),
          ),
        ],
      ),
    );
  }
}


// ====================================================================
// --- 3. CUSTOM BUTTON WIDGET (3D Press Effect) ---
// ====================================================================
class _CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;

  const _CustomButton({
    required this.text,
    required this.onPressed,
    required this.buttonColor,
  });

  @override
  State<_CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<_CustomButton> {
  bool _isPressed = false;
  static const double _shadowDepth = 8.0;

  @override
  Widget build(BuildContext context) {
    final offset = _isPressed ? const Offset(0, 4.0) : const Offset(0, _shadowDepth);
    final double blurRadius = _isPressed ? 3.0 : 12.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        width: 280,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: offset,
              blurRadius: blurRadius,
            ),
          ],
        ),

        child: Stack(
          children: [
            // Bottom layer (Used as the base color)
            Container(
              decoration: BoxDecoration(
                color: widget.buttonColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Top surface (Moves down when pressed)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              top: _isPressed ? 4.0 : 0,
              bottom: _isPressed ? 0 : 4.0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.buttonColor, // Brighter color for the top surface
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'GameFont',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ====================================================================
// --- 4. HOME SCREEN (The main consuming widget) ---
// ====================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper method to navigate and start a new game
  void _startGame(BuildContext context) {
    audioService.stopBackgroundMusic();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => BubbleGameBloc(),
          child: const BubbleGameScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_screen_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === Consumes DazzlingTitle ===
              const DazzlingTitle(),
              // ==============================
              const SizedBox(height: 80),

              // 1. PLAY BUTTON
              _CustomButton(
                text: 'Play Game',
                onPressed: () => _startGame(context),
                buttonColor: Colors.lightGreen,
              ),
              const SizedBox(height: 20),

              // 2. LEADERBOARD
              _CustomButton(
                text: 'Leaderboard',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewing High Scores...')),
                  );
                },
                buttonColor: Colors.orangeAccent,
              ),
              const SizedBox(height: 20),

              // 3. SOUND TOGGLE BUTTON
              const SoundToggleButton(),
            ],
          ),
        ),
      ),
    );
  }
}