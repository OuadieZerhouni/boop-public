import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../audio/sfx.dart';
import '../core/app_services.dart';
import '../core/test_env.dart';
import '../game/combo.dart';
import '../game/critters.dart';
import '../game/progress.dart';
import '../l10n/l10n.dart';
import 'critter_painter.dart';
import 'critter_stage.dart';
import 'names.dart';
import 'particles.dart';
import 'theme.dart';
import 'widgets.dart';

class BoopScreen extends StatefulWidget {
  const BoopScreen({super.key, required this.onOpenSettings});
  final VoidCallback onOpenSettings;

  @override
  State<BoopScreen> createState() => _BoopScreenState();
}

class _BoopScreenState extends State<BoopScreen> with TickerProviderStateMixin {
  final _particles = ParticleController();
  final _stage = CritterStageController();
  late final AnimationController _banner;
  late final AnimationController _comboPulse;
  String _bannerText = '';
  int _shownCombo = 0;

  @override
  void initState() {
    super.initState();
    // Eager, never lazy: a controller first touched in dispose() throws.
    _banner = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _comboPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _banner.dispose();
    _comboPulse.dispose();
    super.dispose();
  }

  AppServices get _s => AppScope.of(context);

  void _onBoop(CritterSpecies c, Offset at) {
    final s = _s;
    final l = context.l10n;
    final step = s.combo.boop(s.clock());
    s.sound.boop(boopPitchIndex(c.pitch, step.count));
    if (step.tier != null) {
      s.sound.medium();
    } else {
      s.sound.light();
    }
    s.boop(c.id);
    s.progress.recordCombo(step.count);
    s.progress.completeOnboarding();

    _particles.hearts(at, count: step.count >= 10 ? 2 : 1);
    _particles.text(at + const Offset(0, -36), '+1', color: BoopColors.heart);

    if (step.tier != null) {
      _bannerText = switch (step.tier!) {
        ComboTier.boopADoop => l.tierBoopADoop,
        ComboTier.snootStorm => l.tierSnootStorm,
        ComboTier.megaBoop => l.tierMegaBoop,
      };
      _banner.forward(from: 0);
      s.sound.play(Sfx.chime);
      _particles.sparkles(at, count: 10);
    }
    if (step.sneeze) {
      _stage.sneeze();
      s.sound.play(Sfx.sneeze);
      _particles.confetti(at, count: 30);
      _particles.text(at + const Offset(0, -80), l.achoo, color: BoopColors.ink, size: 30);
    }
    _shownCombo = step.count;
    if (step.count >= 2) _comboPulse.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge([s.progress, s.settings, s.remote]),
      builder: (context, _) {
        final p = s.progress.value;
        final settings = s.settings.value;
        final reduced = motionReduced(context, settings.reduceMotion);
        _particles.muted = reduced;
        final now = s.clock();
        final critter = p.selected;
        final goal = s.dailyGoal;
        final today = p.todayAt(now);
        final liveCombo = s.combo.countAt(now) >= 2 ? _shownCombo : 0;
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(
                lifetime: p.lifetimeBoops,
                today: today,
                goal: goal,
                streak: p.streakAt(now),
                goalMet: p.goalMetAt(now),
                onSettings: widget.onOpenSettings,
              ),
              _Banners(services: s),
              const SizedBox(height: 6),
              Text(critterName(l, critter), style: display(context, 30)),
              Text(critterKind(l, critter), style: body(context, 15, color: BoopColors.inkSoft)),
              SizedBox(
                height: 44,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: liveCombo >= 2 ? 1 : 0,
                    child: ScaleTransition(
                      scale: Tween(begin: 1.18, end: 1.0).animate(CurvedAnimation(parent: _comboPulse, curve: Curves.easeOut)),
                      child: Pill(color: BoopColors.butter, child: Text(l.comboLabel(math.max(liveCombo, 2)))),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final side = math.min(box.maxWidth, box.maxHeight).clamp(0.0, 420.0);
                    return Center(
                      child: SizedBox.square(
                        dimension: side,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [BoopColors.glow, BoopColors.glow.withValues(alpha: 0)], stops: const [0.35, 1]),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: CritterStage(
                                key: const ValueKey('critter-stage'),
                                species: critter,
                                controller: _stage,
                                reduceMotion: reduced,
                                semanticLabel: l.semanticsCritter(critterName(l, critter)),
                                onBoop: (at) => _onBoop(critter, at),
                                onBodyTap: (at) {
                                  s.sound.play(Sfx.giggle, volume: 0.8);
                                  s.sound.selection();
                                  _particles.sparkles(at, count: 4, color: BoopColors.sky);
                                },
                                onHugStart: (at) {
                                  s.sound.play(Sfx.hug);
                                  s.sound.medium();
                                  _particles.hearts(at, count: 6, scale: 1.2);
                                },
                                onRelease: () => s.sound.play(Sfx.boing, volume: 0.7),
                              ),
                            ),
                            if (!p.onboardingDone) _OnboardingHint(side: side, species: critter, reduced: reduced),
                            Positioned.fill(child: ParticleLayer(controller: _particles)),
                            Positioned.fill(child: IgnorePointer(child: _TierBanner(animation: _banner, text: _bannerText))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: _NextFriendCard(progress: p),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.lifetime, required this.today, required this.goal, required this.streak, required this.goalMet, required this.onSettings});
  final int lifetime;
  final int today;
  final int goal;
  final int streak;
  final bool goalMet;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: '${l.todayProgress(today, goal)}${streak > 0 ? ', ${l.streakDays(streak)}' : ''}',
              excludeSemantics: true,
              child: Row(
                children: [
                  GoalRing(
                    progress: goal == 0 ? 0 : today / goal,
                    done: goalMet,
                    size: 58,
                    child: goalMet
                        ? const Icon(Icons.check_rounded, color: BoopColors.ink, size: 26)
                        : FittedBox(child: Padding(padding: const EdgeInsets.all(8), child: Text('${math.min(today, goal)}', style: display(context, 15)))),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.todayProgress(math.min(today, goal), goal),
                            style: body(context, 13, color: BoopColors.inkSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (streak > 0)
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8A3D), size: 18),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(l.streakDays(streak),
                                    style: body(context, 13, weight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Pill(
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_rounded, color: BoopColors.heart, size: 18),
                    const SizedBox(width: 4),
                    Text(l.boopCount(lifetime), key: const ValueKey('lifetime-boops')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: l.settingsTooltip,
            onPressed: onSettings,
            icon: const Icon(Icons.settings_rounded, color: BoopColors.ink, size: 28),
          ),
        ],
      ),
    );
  }
}

class _NextFriendCard extends StatelessWidget {
  const _NextFriendCard({required this.progress});
  final Progress progress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final next = nextLocked(progress.lifetimeBoops);
    if (next == null) {
      return StickerCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        color: BoopColors.butter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration_rounded, color: BoopColors.ink),
            const SizedBox(width: 8),
            Text(l.everyoneHere, style: display(context, 18)),
          ],
        ),
      );
    }
    final prevAt = kCritters.lastWhere((c) => c.unlockAt <= progress.lifetimeBoops).unlockAt;
    final span = next.unlockAt - prevAt;
    final done = progress.lifetimeBoops - prevAt;
    final remaining = next.unlockAt - progress.lifetimeBoops;
    return StickerCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 48,
            child: CustomPaint(painter: CritterPainter(species: next, silhouette: true, shadow: false)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.nextFriend(remaining), style: body(context, 15, weight: FontWeight.w800), key: const ValueKey('next-friend')),
                const SizedBox(height: 6),
                StickerProgress(value: span == 0 ? 1 : done / span),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHint extends StatefulWidget {
  const _OnboardingHint({required this.side, required this.species, required this.reduced});
  final double side;
  final CritterSpecies species;
  final bool reduced;

  @override
  State<_OnboardingHint> createState() => _OnboardingHintState();
}

class _OnboardingHintState extends State<_OnboardingHint> with SingleTickerProviderStateMixin {
  late final AnimationController _bob;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    // Endless loops never settle under `flutter test`; the hint is static there.
    if (!widget.reduced && !skipDeviceOnlyWork) _bob.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = CritterGeometry(widget.side, widget.species);
    return Positioned(
      left: g.nose.dx - 90,
      width: 180,
      top: g.nose.dy + g.noseHitRadius * 0.55,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _bob,
          builder: (context, child) => Transform.translate(offset: Offset(0, 10 * _bob.value), child: child),
          child: Column(
            key: const ValueKey('onboarding-hint'),
            children: [
              const Text('👆', style: TextStyle(fontSize: 34)),
              Pill(color: Colors.white, child: Text(context.l10n.onboardingHint)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierBanner extends StatelessWidget {
  const _TierBanner({required this.animation, required this.text});
  final Animation<double> animation;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        if (t == 0 || t == 1 || text.isEmpty) return const SizedBox.shrink();
        final scale = t < 0.15 ? Curves.easeOutBack.transform(t / 0.15) : 1.0;
        final opacity = t > 0.75 ? (1 - (t - 0.75) / 0.25) : 1.0;
        return Align(
          alignment: const Alignment(0, -0.92),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: -0.06,
                child: StickerCard(
                  color: BoopColors.heart,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Text(text, style: display(context, 26, color: Colors.white)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Remote announcement and soft-update prompt, each dismissible.
class _Banners extends StatelessWidget {
  const _Banners({required this.services});
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cfg = services.remote.value;
    final lang = Localizations.localeOf(context).languageCode;
    final p = services.progress.value;
    final ann = cfg.announcement;
    final children = <Widget>[];
    if (services.remote.updateAvailable && cfg.updateUrlIos.isNotEmpty && !p.dismissedAnnouncements.contains('update-${cfg.latestVersion}')) {
      children.add(_banner(
        context,
        title: l.updateAvailable,
        body: '',
        action: l.updateAction,
        onAction: () => launchUrl(Uri.parse(cfg.updateUrlIos), mode: LaunchMode.externalApplication),
        onDismiss: () => services.progress.dismissAnnouncement('update-${cfg.latestVersion}'),
      ));
    }
    if (ann != null && !p.dismissedAnnouncements.contains(ann.id)) {
      children.add(_banner(
        context,
        title: ann.title.resolve(lang),
        body: ann.body.resolve(lang),
        action: ann.url.isEmpty ? null : '→',
        onAction: ann.url.isEmpty ? null : () => launchUrl(Uri.parse(ann.url), mode: LaunchMode.externalApplication),
        onDismiss: () => services.progress.dismissAnnouncement(ann.id),
      ));
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 0), child: Column(children: children));
  }

  Widget _banner(BuildContext context, {required String title, required String body, String? action, VoidCallback? onAction, required VoidCallback onDismiss}) {
    final l = context.l10n;
    return StickerCard(
      color: BoopColors.sky,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty) Text(title, style: display(context, 15)),
                if (body.isNotEmpty) Text(body, style: _bodyStyle(context)),
              ],
            ),
          ),
          if (action != null && onAction != null) TextButton(onPressed: onAction, child: Text(action, style: display(context, 15))),
          IconButton(tooltip: l.dismiss, onPressed: onDismiss, icon: const Icon(Icons.close_rounded, color: BoopColors.ink)),
        ],
      ),
    );
  }

  TextStyle _bodyStyle(BuildContext context) => body(context, 13);
}
