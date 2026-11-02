import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ApproveIntent extends Intent {
  const ApproveIntent();
}

class RejectIntent extends Intent {
  const RejectIntent();
}

class MoveSelectionIntent extends Intent {
  const MoveSelectionIntent(this.delta);
  final int delta;
}

class ClearSelectionIntent extends Intent {
  const ClearSelectionIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class ShowShortcutsIntent extends Intent {
  const ShowShortcutsIntent();
}

Map<ShortcutActivator, Intent> get appShortcuts {
  return <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.keyC): const ApproveIntent(),
    const SingleActivator(LogicalKeyboardKey.keyX): const RejectIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowDown): const MoveSelectionIntent(1),
    const SingleActivator(LogicalKeyboardKey.arrowUp): const MoveSelectionIntent(-1),
    const SingleActivator(LogicalKeyboardKey.escape): const ClearSelectionIntent(),
    const SingleActivator(LogicalKeyboardKey.keyR): const RefreshIntent(),
    const SingleActivator(LogicalKeyboardKey.f1): const ShowShortcutsIntent(),
  };
}