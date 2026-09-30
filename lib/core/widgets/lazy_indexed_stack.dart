import 'package:flutter/material.dart';

/// An [IndexedStack] that only builds a child the first time its index is
/// shown, instead of building every child up front.
///
/// This prevents hidden tabs from running their `initState` (and any network
/// fetches that kick off there) when the app starts. Once a child has been
/// visited it stays mounted, so switching back preserves its state exactly
/// like a plain [IndexedStack] would.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  final Set<int> _built = {};

  @override
  Widget build(BuildContext context) {
    _built.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: List<Widget>.generate(
        widget.children.length,
        (i) => _built.contains(i) ? widget.children[i] : const SizedBox.shrink(),
        growable: false,
      ),
    );
  }
}