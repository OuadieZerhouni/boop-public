import 'package:flutter/material.dart';

import '../core/app_services.dart';
import '../game/critters.dart';
import '../l10n/l10n.dart';
import 'critter_painter.dart';
import 'names.dart';
import 'theme.dart';
import 'widgets.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.onPicked});

  /// Called after an unlocked critter is chosen (the shell jumps to Boop).
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final l = context.l10n;
    return ListenableBuilder(
      listenable: s.progress,
      builder: (context, _) {
        final p = s.progress.value;
        final next = nextLocked(p.lifetimeBoops);
        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.collectionTitle, style: display(context, 32)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Pill(color: BoopColors.mint, child: Text(l.collectionCount(p.unlockedCount, kCritters.length))),
                          if (p.bestCombo >= 2) Pill(color: BoopColors.butter, child: Text(l.bestCombo(p.bestCombo))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        next == null ? l.everyoneHere : l.nextFriend(next.unlockAt - p.lifetimeBoops),
                        style: body(context, 15, color: BoopColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final c = kCritters[i];
                      final unlocked = p.isUnlocked(c);
                      return _CritterCard(
                        critter: c,
                        unlocked: unlocked,
                        selected: unlocked && p.selected.id == c.id,
                        boops: p.boopsFor(c.id),
                        remaining: c.unlockAt - p.lifetimeBoops,
                        onTap: () {
                          if (unlocked) {
                            s.sound.selection();
                            s.progress.select(c.id);
                            onPicked();
                          } else {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content: Text(l.lockedSnack(c.unlockAt - p.lifetimeBoops), style: body(context, 15, color: Colors.white)),
                                duration: const Duration(seconds: 2),
                              ));
                          }
                        },
                      );
                    },
                    childCount: kCritters.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CritterCard extends StatelessWidget {
  const _CritterCard({
    required this.critter,
    required this.unlocked,
    required this.selected,
    required this.boops,
    required this.remaining,
    required this.onTap,
  });

  final CritterSpecies critter;
  final bool unlocked;
  final bool selected;
  final int boops;
  final int remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final name = unlocked ? critterName(l, critter) : l.lockedName;
    return Semantics(
      button: true,
      selected: selected,
      label: unlocked ? '$name, ${critterKind(l, critter)}, ${l.boopCount(boops)}' : '${l.lockedName}, ${l.lockedRemaining(remaining)}',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('critter-card-${critter.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: StickerCard(
          color: selected ? BoopColors.glow : (unlocked ? Colors.white : const Color(0xFFF6EEE6)),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: CritterPainter(species: critter, silhouette: !unlocked, shadow: unlocked)),
                    ),
                    if (selected)
                      const PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: Icon(Icons.favorite_rounded, color: BoopColors.heart, size: 22),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(name, style: display(context, 18), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                unlocked ? l.boopCount(boops) : l.lockedRemaining(remaining),
                style: body(context, 12.5, color: BoopColors.inkSoft),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
