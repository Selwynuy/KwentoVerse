import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({super.key});

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'SELECT YOUR AVATAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _AvatarCircle(
                              index: 0,
                              isSelected: _selectedIndex == 0,
                              accent: accent,
                              onTap: () => setState(() => _selectedIndex = 0),
                            ),
                            _AvatarCircle(
                              index: 1,
                              isSelected: _selectedIndex == 1,
                              accent: accent,
                              onTap: () => setState(() => _selectedIndex = 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _AvatarCircle(
                              index: 2,
                              isSelected: _selectedIndex == 2,
                              accent: accent,
                              onTap: () => setState(() => _selectedIndex = 2),
                            ),
                            _AvatarCircle(
                              index: 3,
                              isSelected: _selectedIndex == 3,
                              accent: accent,
                              onTap: () => setState(() => _selectedIndex = 3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _AvatarCircle(
                              index: 4,
                              isSelected: _selectedIndex == 4,
                              accent: accent,
                              onTap: () => setState(() => _selectedIndex = 4),
                            ),
                            _AvatarCircle(
                              index: 5,
                              isSelected: _selectedIndex == 5,
                              accent: accent,
                              onTap: () => setState(() => _selectedIndex = 5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedIndex == null
                          ? null
                          : () {
                              // Placeholder: later persist avatar choice.
                              context.go('/student/home');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        "LET'S GO!",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.index,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? accent : Colors.black87,
            width: isSelected ? 4 : 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(
            _avatarIconFor(index),
            size: 40,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

IconData _avatarIconFor(int index) {
  switch (index) {
    case 0:
      return Icons.sentiment_satisfied_alt_outlined;
    case 1:
      return Icons.emoji_people_outlined;
    case 2:
      return Icons.face_retouching_natural_outlined;
    case 3:
      return Icons.psychology_alt_outlined;
    case 4:
      return Icons.self_improvement_outlined;
    case 5:
    default:
      return Icons.star_border_rounded;
  }
}

