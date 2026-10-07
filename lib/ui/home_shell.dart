import 'dart:async';

import 'package:flutter/material.dart';

import '../audio/sfx.dart';
import '../core/app_services.dart';
import '../game/critters.dart';
import '../l10n/l10n.dart';
import 'boop_screen.dart';
import 'collection_screen.dart';
import 'rush_screen.dart';
import 'settings_screen.dart';
import 'theme.dart';
import 'unlock_dialog.dart';

/// Tabs + the celebration queue. Celebrations are shown here so they appear
/// whichever tab produced them (a Rush round can unlock a critter too).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.rushSeed});

  /// Deterministic Boop Rush rounds in tests.
  final int? rushSeed;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  StreamSubscription<BoopEvent>? _sub;
  final List<CritterSpecies> _queue = [];
  bool _showing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sub == null) {
      final s = AppScope.of(context);
      _sub = s.events.listen(_onEvent);
      // Anything unlocked but never celebrated (e.g. the app was closed first).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _queue.addAll(s.progress.value.pendingCelebrations.where((c) => !_queue.contains(c)));
        _drain();
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(BoopEvent e) {
    if (!mounted) return;
    final s = AppScope.of(context);
    switch (e) {
      case UnlockEvent(:final critter):
        if (!_queue.contains(critter)) _queue.add(critter);
        _drain();
      case GoalMetEvent():
        s.sound.play(Sfx.chime);
        final l = context.l10n;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8A3D)),
                const SizedBox(width: 8),
                Expanded(child: Text(l.dailyDone, style: body(context, 16, weight: FontWeight.w800, color: Colors.white))),
              ],
            ),
            duration: const Duration(seconds: 2),
          ));
    }
  }

  Future<void> _drain() async {
    if (_showing || _queue.isEmpty || !mounted) return;
    _showing = true;
    final s = AppScope.of(context);
    while (_queue.isNotEmpty && mounted) {
      final c = _queue.removeAt(0);
      s.progress.markCelebrated(c.id);
      s.sound.play(Sfx.fanfare);
      s.sound.heavy();
      final boopNow = await showUnlockDialog(context, c, reduceMotion: motionReduced(context, s.settings.value.reduceMotion));
      if (!mounted) break;
      if (boopNow) {
        s.progress.select(c.id);
        setState(() => _tab = 0);
      }
    }
    _showing = false;
    if (mounted) unawaited(s.maybeAskForReview());
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = AppScope.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          BoopScreen(onOpenSettings: _openSettings),
          CollectionScreen(onPicked: () => setState(() => _tab = 0)),
          RushScreen(seed: widget.rushSeed),
        ],
      ),
      bottomNavigationBar: _TabBar(
        index: _tab,
        labels: [l.tabBoop, l.tabCritters, l.tabRush],
        icons: const [Icons.favorite_rounded, Icons.grid_view_rounded, Icons.bolt_rounded],
        onTap: (i) {
          if (i != _tab) s.sound.selection();
          setState(() => _tab = i);
        },
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.labels, required this.icons, required this.onTap});
  final int index;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  static const _colors = [BoopColors.heart, BoopColors.mint, BoopColors.butter];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BoopColors.ink, width: kOutline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == index,
                    button: true,
                    label: labels[i],
                    excludeSemantics: true,
                    child: GestureDetector(
                      key: ValueKey('tab-$i'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: i == index ? _colors[i] : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: i == index ? BoopColors.ink : Colors.transparent, width: 2.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons[i], color: BoopColors.ink, size: 26),
                            const SizedBox(height: 2),
                            Text(labels[i], style: display(context, 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
