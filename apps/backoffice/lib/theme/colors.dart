import 'package:flutter/material.dart';

abstract final class AppColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6C3FEF),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE8DEFF),
    onPrimaryContainer: Color(0xFF1D0060),
    secondary: Color(0xFF00A896),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD0F4F0),
    onSecondaryContainer: Color(0xFF00201C),
    tertiary: Color(0xFFFF7A00),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE0CC),
    onTertiaryContainer: Color(0xFF4A2200),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFF8F7FC),
    onSurface: Color(0xFF1C1B1F),
    surfaceDim: Color(0xFFDAD9E0),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F1F9),
    surfaceContainer: Color(0xFFECEBF4),
    surfaceContainerHigh: Color(0xFFE6E5EE),
    surfaceContainerHighest: Color(0xFFDAD9E0),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFFCFBCFF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFCFBCFF),
    onPrimary: Color(0xFF381E72),
    primaryContainer: Color(0xFF4F378B),
    onPrimaryContainer: Color(0xFFE8DEFF),
    secondary: Color(0xFF7EE0D6),
    onSecondary: Color(0xFF003731),
    secondaryContainer: Color(0xFF005048),
    onSecondaryContainer: Color(0xFFD0F4F0),
    tertiary: Color(0xFFFFB77C),
    onTertiary: Color(0xFF4A2200),
    tertiaryContainer: Color(0xFF6B3300),
    onTertiaryContainer: Color(0xFFFFE0CC),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF141218),
    onSurface: Color(0xFFE6E1E5),
    surfaceDim: Color(0xFF141218),
    surfaceBright: Color(0xFF3B383E),
    surfaceContainerLowest: Color(0xFF0F0D13),
    surfaceContainerLow: Color(0xFF1C1B20),
    surfaceContainer: Color(0xFF211F26),
    surfaceContainerHigh: Color(0xFF2B292F),
    surfaceContainerHighest: Color(0xFF36343B),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFF6C3FEF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}

@immutable
class EntryStatusColors extends ThemeExtension<EntryStatusColors> {
  const EntryStatusColors({
    required this.pending,
    required this.onPending,
    required this.approved,
    required this.onApproved,
    required this.rejected,
    required this.onRejected,
    required this.archived,
    required this.onArchived,
  });

  final Color pending;
  final Color onPending;
  final Color approved;
  final Color onApproved;
  final Color rejected;
  final Color onRejected;
  final Color archived;
  final Color onArchived;

  static const light = EntryStatusColors(
    pending: Color(0xFFFFF0C2),
    onPending: Color(0xFF6D5000),
    approved: Color(0xFFD0F4E0),
    onApproved: Color(0xFF00522A),
    rejected: Color(0xFFFFDAD6),
    onRejected: Color(0xFF93000A),
    archived: Color(0xFFE8E7EC),
    onArchived: Color(0xFF49454F),
  );

  static const dark = EntryStatusColors(
    pending: Color(0xFF5C4700),
    onPending: Color(0xFFFFE08F),
    approved: Color(0xFF00522A),
    onApproved: Color(0xFFA0F0C0),
    rejected: Color(0xFF93000A),
    onRejected: Color(0xFFFFB4AB),
    archived: Color(0xFF36343B),
    onArchived: Color(0xFFCAC4D0),
  );

  @override
  EntryStatusColors copyWith({
    Color? pending,
    Color? onPending,
    Color? approved,
    Color? onApproved,
    Color? rejected,
    Color? onRejected,
    Color? archived,
    Color? onArchived,
  }) {
    return EntryStatusColors(
      pending: pending ?? this.pending,
      onPending: onPending ?? this.onPending,
      approved: approved ?? this.approved,
      onApproved: onApproved ?? this.onApproved,
      rejected: rejected ?? this.rejected,
      onRejected: onRejected ?? this.onRejected,
      archived: archived ?? this.archived,
      onArchived: onArchived ?? this.onArchived,
    );
  }

  @override
  EntryStatusColors lerp(EntryStatusColors? other, double t) {
    if (other == null) return this;
    return EntryStatusColors(
      pending: Color.lerp(pending, other.pending, t)!,
      onPending: Color.lerp(onPending, other.onPending, t)!,
      approved: Color.lerp(approved, other.approved, t)!,
      onApproved: Color.lerp(onApproved, other.onApproved, t)!,
      rejected: Color.lerp(rejected, other.rejected, t)!,
      onRejected: Color.lerp(onRejected, other.onRejected, t)!,
      archived: Color.lerp(archived, other.archived, t)!,
      onArchived: Color.lerp(onArchived, other.onArchived, t)!,
    );
  }
}

extension EntryStatusColorsX on ThemeData {
  EntryStatusColors get statusColors => extension<EntryStatusColors>() ?? EntryStatusColors.light;
}