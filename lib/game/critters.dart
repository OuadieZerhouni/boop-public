import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// How a critter's ears (or ear-equivalent) are drawn.
enum EarStyle { bunny, round, tuft, bumps, pig, cloud, none, floppy, jelly, leaf, horns }

/// The thing you boop.
enum NoseStyle { button, heart, beak, snout, triangle, star }

/// One collectible critter. Pure data: drawing lives in ui/critter_painter.dart.
@immutable
class CritterSpecies {
  const CritterSpecies({
    required this.id,
    required this.unlockAt,
    required this.body,
    required this.belly,
    required this.accent,
    required this.nose,
    required this.cheek,
    required this.ears,
    required this.noseStyle,
    required this.pitch,
    this.aspect = 1.0,
    this.patches = false,
    this.freckles = false,
    this.whiskers = false,
    this.glossy = false,
  });

  /// Stable id: persisted, and the key of every localized name.
  final String id;

  /// Lifetime boops needed to unlock.
  final int unlockAt;

  final Color body;
  final Color belly;
  final Color accent;
  final Color nose;
  final Color cheek;
  final EarStyle ears;
  final NoseStyle noseStyle;

  /// Base squeak pitch, in semitone steps (0–11, one per critter); combos add
  /// up to 7 more.
  final int pitch;

  /// Body width / height. >1 is a wider, squatter critter.
  final double aspect;

  /// Panda-style dark eye patches.
  final bool patches;
  final bool freckles;
  final bool whiskers;

  /// Translucent jelly sheen (Jelly).
  final bool glossy;
}

/// The collection, in unlock order. Thresholds are part of the SPEC (F3) and
/// covered by tests — change them only together with SPEC.md.
const List<CritterSpecies> kCritters = [
  CritterSpecies(
    id: 'mochi', unlockAt: 0, pitch: 5, ears: EarStyle.bunny, noseStyle: NoseStyle.heart,
    body: Color(0xFFFFD9E3), belly: Color(0xFFFFF1F4), accent: Color(0xFFFFB3C7), nose: Color(0xFFFF6F8E), cheek: Color(0xFFFF9FB6),
  ),
  CritterSpecies(
    id: 'pip', unlockAt: 30, pitch: 11, ears: EarStyle.tuft, noseStyle: NoseStyle.beak, aspect: 0.96,
    body: Color(0xFFFFE07A), belly: Color(0xFFFFF3C2), accent: Color(0xFFFFC94A), nose: Color(0xFFFF9A3D), cheek: Color(0xFFFFA98A),
  ),
  CritterSpecies(
    id: 'bao', unlockAt: 80, pitch: 1, ears: EarStyle.round, noseStyle: NoseStyle.button, patches: true, aspect: 1.06,
    body: Color(0xFFFAF7F2), belly: Color(0xFFFFFFFF), accent: Color(0xFF3B2A2A), nose: Color(0xFF3B2A2A), cheek: Color(0xFFFFB0C0),
  ),
  CritterSpecies(
    id: 'kiwi', unlockAt: 150, pitch: 3, ears: EarStyle.bumps, noseStyle: NoseStyle.button, aspect: 1.14, freckles: true,
    body: Color(0xFF8EDB8A), belly: Color(0xFFD9F5C9), accent: Color(0xFF5DBB63), nose: Color(0xFF3F9A55), cheek: Color(0xFFFF9FA8),
  ),
  CritterSpecies(
    id: 'momo', unlockAt: 250, pitch: 0, ears: EarStyle.round, noseStyle: NoseStyle.snout, aspect: 1.12,
    body: Color(0xFFD9C7E6), belly: Color(0xFFF1E7F7), accent: Color(0xFFFFB7C9), nose: Color(0xFFE6A9C4), cheek: Color(0xFFFF9FBA),
  ),
  CritterSpecies(
    id: 'puff', unlockAt: 400, pitch: 7, ears: EarStyle.cloud, noseStyle: NoseStyle.triangle,
    body: Color(0xFFF4EEFF), belly: Color(0xFFFFFFFF), accent: Color(0xFFD9CCFF), nose: Color(0xFFB79CF5), cheek: Color(0xFFFFB5D0),
  ),
  CritterSpecies(
    id: 'nori', unlockAt: 600, pitch: 2, ears: EarStyle.none, noseStyle: NoseStyle.button, whiskers: true, aspect: 1.12,
    body: Color(0xFFB9CCDD), belly: Color(0xFFE6EEF5), accent: Color(0xFF8FA9C0), nose: Color(0xFF3B2A2A), cheek: Color(0xFFFFB3C2),
  ),
  CritterSpecies(
    id: 'taro', unlockAt: 850, pitch: 9, ears: EarStyle.round, noseStyle: NoseStyle.triangle, whiskers: true, aspect: 1.1,
    body: Color(0xFFF2C38F), belly: Color(0xFFFFF0DC), accent: Color(0xFFE0A066), nose: Color(0xFFFF8F9E), cheek: Color(0xFFFF9C8A),
  ),
  CritterSpecies(
    id: 'coco', unlockAt: 1150, pitch: 4, ears: EarStyle.floppy, noseStyle: NoseStyle.button, aspect: 1.02,
    body: Color(0xFFE2B48A), belly: Color(0xFFFFEBD6), accent: Color(0xFFA9734A), nose: Color(0xFF3B2A2A), cheek: Color(0xFFFF9F9F),
  ),
  CritterSpecies(
    id: 'jelly', unlockAt: 1500, pitch: 10, ears: EarStyle.jelly, noseStyle: NoseStyle.heart, glossy: true, aspect: 1.04,
    body: Color(0xFFD3B8FF), belly: Color(0xFFEFE4FF), accent: Color(0xFFB08BFF), nose: Color(0xFFFF7FB0), cheek: Color(0xFFFF9FD0),
  ),
  CritterSpecies(
    id: 'sprout', unlockAt: 2000, pitch: 8, ears: EarStyle.leaf, noseStyle: NoseStyle.button, freckles: true,
    body: Color(0xFFC4EBA0), belly: Color(0xFFEFFADF), accent: Color(0xFF6DC06A), nose: Color(0xFFFF9F7A), cheek: Color(0xFFFFA8A0),
  ),
  CritterSpecies(
    id: 'star', unlockAt: 3000, pitch: 6, ears: EarStyle.horns, noseStyle: NoseStyle.star, aspect: 1.04,
    body: Color(0xFF9FD3FF), belly: Color(0xFFE2F2FF), accent: Color(0xFFFFD36B), nose: Color(0xFFFFB84D), cheek: Color(0xFFFFA6C9),
  ),
];

CritterSpecies critterById(String id) => kCritters.firstWhere((c) => c.id == id, orElse: () => kCritters.first);

/// The next locked critter for [lifetimeBoops], or null when all are unlocked.
CritterSpecies? nextLocked(int lifetimeBoops) {
  for (final c in kCritters) {
    if (c.unlockAt > lifetimeBoops) return c;
  }
  return null;
}
