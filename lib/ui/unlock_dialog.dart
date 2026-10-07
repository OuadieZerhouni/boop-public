import 'package:flutter/material.dart';

import '../game/critters.dart';
import '../l10n/l10n.dart';
import 'critter_painter.dart';
import 'names.dart';
import 'particles.dart';
import 'theme.dart';
import 'widgets.dart';

/// "New friend!" — returns true when the player chose to boop them now.
Future<bool> showUnlockDialog(BuildContext context, CritterSpecies critter, {required bool reduceMotion}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: BoopColors.ink.withValues(alpha: 0.45),
    transitionDuration: Duration(milliseconds: reduceMotion ? 120 : 380),
    pageBuilder: (context, _, _) => _UnlockCard(critter: critter, reduceMotion: reduceMotion),
    transitionBuilder: (context, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: reduceMotion ? Curves.easeOut : Curves.easeOutBack);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: reduceMotion ? 0.95 : 0.6, end: 1.0).animate(curved), child: child),
      );
    },
  );
  return result ?? false;
}

class _UnlockCard extends StatefulWidget {
  const _UnlockCard({required this.critter, required this.reduceMotion});
  final CritterSpecies critter;
  final bool reduceMotion;

  @override
  State<_UnlockCard> createState() => _UnlockCardState();
}

class _UnlockCardState extends State<_UnlockCard> {
  final _particles = ParticleController();

  @override
  void initState() {
    super.initState();
    _particles.muted = widget.reduceMotion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.sizeOf(context);
      _particles.confetti(Offset(size.width / 2, size.height * 0.4), count: 60, spread: 1.4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final name = critterName(l, widget.critter);
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Material(
              type: MaterialType.transparency,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: StickerCard(
                  key: const ValueKey('unlock-dialog'),
                  color: BoopColors.cream,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Pill(color: BoopColors.heart, child: Text(l.unlockTitle, style: display(context, 16, color: Colors.white))),
                      const SizedBox(height: 8),
                      SizedBox.square(
                        dimension: 190,
                        child: CustomPaint(
                          painter: CritterPainter(
                            species: widget.critter,
                            pose: const CritterPose(face: CritterFace.happy, blush: 1),
                          ),
                        ),
                      ),
                      Text(l.unlockBody(name), textAlign: TextAlign.center, style: display(context, 24)),
                      const SizedBox(height: 2),
                      Text(critterKind(l, widget.critter), style: body(context, 15, color: BoopColors.inkSoft)),
                      const SizedBox(height: 16),
                      StickerButton(
                        key: const ValueKey('unlock-boop'),
                        expand: true,
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l.unlockBoop),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        key: const ValueKey('unlock-later'),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l.unlockLater, style: body(context, 16, weight: FontWeight.w800, color: BoopColors.inkSoft)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: ParticleLayer(controller: _particles)),
      ],
    );
  }
}
