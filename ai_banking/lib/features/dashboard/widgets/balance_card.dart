import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../shared/models/account.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/privacy_sensitive_text.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key, required this.account, this.onTap});
  final Account account;
  final VoidCallback? onTap;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final List<Color> gradientColors = widget.account.cardGradientColors.map((hex) {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    }).toList();

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          child: Stack(
            children: [
              GlassCard(
                opacity: 0.12,
                blur: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.account.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.account.type.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        _getNetworkIcon(widget.account.cardNetwork),
                      ],
                    ),
                    const Spacer(),
                    PrivacySensitiveText(
                      '${widget.account.currency} ${widget.account.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrivacySensitiveText(
                          widget.account.accountNumber,
                          style: const TextStyle(
                            color: Colors.white70,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.account.expiryDate,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: CardSkySceneryPainter(
                          progress: _controller.value,
                          isDarkMode: isDarkMode,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNetworkIcon(CardNetwork network) {
    IconData iconData;
    switch (network) {
      case CardNetwork.visa:
        iconData = Icons.credit_card;
        break;
      case CardNetwork.mastercard:
        iconData = Icons.payment;
        break;
      default:
        iconData = Icons.credit_card;
    }
    return Icon(iconData, color: Colors.white, size: 32);
  }
}

class CardSkySceneryPainter extends CustomPainter {
  CardSkySceneryPainter({required this.progress, required this.isDarkMode});
  final double progress;
  final bool isDarkMode;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDarkMode) {
      _drawNightSky(canvas, size);
    } else {
      _drawDaySky(canvas, size);
    }
  }

  void _drawDaySky(Canvas canvas, Size size) {
    final double sunX = size.width < 340 ? size.width * 0.72 : size.width * 0.80;
    final double sunY = size.height * 0.42;

    final paintSunGlow = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
      
    final paintSun = Paint()
      ..color = Colors.amber.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    
    final sunOffset = Offset(sunX, sunY);
    canvas.drawCircle(sunOffset, 32, paintSunGlow);
    canvas.drawCircle(sunOffset, 20, paintSun);

    // --- EXACT 4 CLOUDS (Completely finished by 0.70, leaving 0.70 to 1.0 completely clear before reset) ---
    _drawFiniteCloud(canvas, size, progress, 0.22, 30, 0.00, 0.35);
    _drawFiniteCloud(canvas, size, progress, 0.60, 22, 0.11, 0.46);
    _drawFiniteCloud(canvas, size, progress, 0.78, 26, 0.22, 0.57);
    _drawFiniteCloud(canvas, size, progress, 0.40, 18, 0.33, 0.68);

    // --- EXACT 5 BIRDS (Fully exit the card by 0.68 progress, leaving a clean sky before reset) ---
    const double birdStart = 0.05;
    const double birdEnd = 0.68;

    if (progress >= birdStart && progress <= birdEnd) {
      double flockProgress = (progress - birdStart) / (birdEnd - birdStart);
      
      double groupAlpha = 1.0;
      if (flockProgress < 0.1) {
        groupAlpha = flockProgress / 0.1;
      } else if (flockProgress > 0.85) {
        groupAlpha = (1.0 - flockProgress) / 0.15;
      }

      final individualBirdPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85 * groupAlpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;

      final List<Offset> flockOffsets = [
        const Offset(0.0, 0.0),      // Leader 1
        const Offset(-35.0, 15.0),   // Follower 2
        const Offset(-65.0, -12.0),  // Follower 3
        const Offset(-100.0, 8.0),   // Follower 4
        const Offset(-130.0, -8.0),  // Follower 5
      ];

      double totalFlightPath = size.width + 180;

      for (int i = 0; i < flockOffsets.length; i++) {
        double individualProgress = flockProgress - (i * 0.03);
        if (individualProgress < 0.0 || individualProgress > 1.0) continue;

        double x = -60 + (individualProgress * totalFlightPath) + flockOffsets[i].dx;
        double baseHeight = size.height * 0.22;
        double y = baseHeight + flockOffsets[i].dy + (math.sin((individualProgress * math.pi * 3) + i) * 6);

        double flapCycle = progress * math.pi * 35 + (i * 2.0);
        double wingFlapFactor = math.sin(flapCycle) * 9.0;

        _drawFlappingBird(canvas, Offset(x, y), wingFlapFactor, individualBirdPaint);
      }
    }
  }

  void _drawFiniteCloud(Canvas canvas, Size size, double p, double relativeY, double radius, double startTime, double endTime) {
    if (p < startTime || p > endTime) return;

    double localProgress = (p - startTime) / (endTime - startTime);
    
    double alphaFade = 1.0;
    if (localProgress < 0.12) {
      alphaFade = localProgress / 0.12;
    } else if (localProgress > 0.88) {
      alphaFade = (1.0 - localProgress) / 0.12;
    }

    final paintCloud = Paint()
      ..color = Colors.white.withValues(alpha: 0.22 * alphaFade.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    double travelDistance = size.width + 120;
    double xPos = -60 + (localProgress * travelDistance);

    _drawCloud(canvas, Offset(xPos, size.height * relativeY), radius, paintCloud);
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.7, center.dy + radius * 0.3), radius * 0.7, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.7, center.dy + radius * 0.3), radius * 0.7, paint);
  }

  void _drawFlappingBird(Canvas canvas, Offset center, double flapOffset, Paint paint) {
    final path = Path();
    path.moveTo(center.dx - 9, center.dy + flapOffset);
    path.quadraticBezierTo(center.dx - 4.5, center.dy - 3, center.dx, center.dy + 1);
    path.quadraticBezierTo(center.dx + 4.5, center.dy - 3, center.dx + 9, center.dy + flapOffset);
    canvas.drawPath(path, paint);
  }

  void _drawNightSky(Canvas canvas, Size size) {
    final double moonX = size.width < 340 ? size.width * 0.72 : size.width * 0.80;
    final double moonY = size.height * 0.42;
    final moonOffset = Offset(moonX, moonY);
    
    final paintMoonGlow = Paint()
      ..color = const Color(0xFFFFFDD0).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(moonOffset, 28, paintMoonGlow);

    final paintMoon = Paint()
      ..color = const Color(0xFFFFFDD0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(moonOffset, 18, paintMoon);
    
    final paintShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(moonOffset.dx + 6, moonOffset.dy - 3), 15, paintShadow);

    final paintCrater = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(moonOffset.dx - 4, moonOffset.dy + 4), 3.0, paintCrater);

    // 1. Stationary Glowing Stars scattered around the background
    final stationaryStarPaint = Paint()
      ..style = PaintingStyle.fill;

    final List<Offset> stationaryStars = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.35, size.height * 0.15),
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.55, size.height * 0.25),
      Offset(size.width * 0.45, size.height * 0.85),
      Offset(size.width * 0.75, size.height * 0.20),
      Offset(size.width * 0.85, size.height * 0.70),
    ];

    for (int i = 0; i < stationaryStars.length; i++) {
      final pos = stationaryStars[i];
      double pulse = 0.6 + (0.4 * math.sin((progress * math.pi * 4) + i));
      
      stationaryStarPaint.color = const Color(0xFFFFFDD0).withValues(alpha: 0.3 + (0.4 * pulse));
      canvas.drawCircle(pos, 1.8 + (0.8 * pulse), stationaryStarPaint);
    }

    // 2. Maximum Wide-Spread Origins covering the entire upper-left to mid area seamlessly
    double totalSpanX = size.width + 350;
    double totalSpanY = size.height + 250;

    for (int i = 0; i < 6; i++) {
      double seedX = (i * 73.0) % (size.width * 0.8);
      double seedY = -50.0 + ((i * 37.0) % (size.height * 0.5));
      
      double cycle = (progress + (i * 0.16)) % 1.0;

      double startX = seedX + (cycle * totalSpanX);
      double startY = seedY + (cycle * totalSpanY * 0.6);

      _drawTeardropShootingStar(canvas, Offset(startX, startY));
    }
  }

  void _drawTeardropShootingStar(Canvas canvas, Offset headPos) {
    final glowPaint = Paint()
      ..color = const Color(0xFFFFEE55).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(headPos, 5, glowPaint);

    final path = Path();
    path.moveTo(headPos.dx, headPos.dy);
    
    path.quadraticBezierTo(
      headPos.dx - 22, headPos.dy - 8, 
      headPos.dx - 48, headPos.dy - 28
    );
    path.quadraticBezierTo(
      headPos.dx - 30, headPos.dy - 16, 
      headPos.dx - 4, headPos.dy - 4
    );
    path.close();

    final trailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFF066),
          const Color(0xFFFFCC00).withValues(alpha: 0.6),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: headPos, radius: 40))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, trailPaint);
  }

  @override
  bool shouldRepaint(covariant CardSkySceneryPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDarkMode != isDarkMode;
  }
}