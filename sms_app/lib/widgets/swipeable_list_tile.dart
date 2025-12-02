import 'package:flutter/material.dart';
import '../helpers/notification_helper.dart';
import '../utils/action_result.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


class SwipeableListTile<T> extends StatefulWidget {
  final T item;
  final String? deleteConfirmMessage;
  final Future<ActionResult?> Function()? onDelete;
  final void Function()? onTap;
  final Widget Function(BuildContext, T) contentBuilder;
  final bool enableDelete;

  const SwipeableListTile({
    super.key,
    required this.item,
    this.deleteConfirmMessage,
    this.onDelete,
    this.onTap,
    required this.contentBuilder,
    this.enableDelete = true,
  });

  @override
  State<SwipeableListTile<T>> createState() => _SwipeableListTileState<T>();
}

class _SwipeableListTileState<T> extends State<SwipeableListTile<T>> {
  double _elevation = 0;

  // @override
  // Widget build(BuildContext context) {
  //   final theme = Theme.of(context);
  //
  //   final tile = GestureDetector(
  //     onTapDown: (_) => setState(() => _elevation = 3),
  //     onTapCancel: () => setState(() => _elevation = 0),
  //     onTapUp: (_) => Future.delayed(const Duration(milliseconds: 150), () {
  //       if (mounted) setState(() => _elevation = 0);
  //     }),
  //     child: InkWell(
  //       onTap: widget.onTap,
  //       borderRadius: BorderRadius.circular(12),
  //       child: AnimatedContainer(
  //         duration: const Duration(milliseconds: 180),
  //         curve: Curves.easeOut,
  //         width: double.infinity,
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //         decoration: BoxDecoration(
  //           color: theme.colorScheme.surface.withValues(alpha: 0.95),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(
  //             color: theme.dividerColor.withValues(alpha: 0.4),
  //             width: 1,
  //           ),
  //           boxShadow: [
  //             if (_elevation > 0)
  //               BoxShadow(
  //                 color: Colors.black.withValues(alpha: 0.08),
  //                 offset: const Offset(0, 2),
  //                 blurRadius: 6,
  //               ),
  //           ],
  //         ),
  //         child: widget.contentBuilder(context, widget.item),
  //       ),
  //     ),
  //   );
  //
  //   if (!widget.enableDelete) {
  //     return Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 6),
  //       child: tile,
  //     );
  //   }
  //
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(12),
  //       child: Dismissible(
  //         key: ValueKey(widget.item),
  //         background: Container(
  //           alignment: Alignment.centerRight,
  //           padding: const EdgeInsets.symmetric(horizontal: 20),
  //           decoration: BoxDecoration(
  //             color: Colors.red.shade400,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: const Icon(Icons.delete, color: Colors.white, size: 28),
  //         ),
  //         direction: DismissDirection.endToStart,
  //         confirmDismiss: (_) async {
  //           final confirm = await showDialog<bool>(
  //             context: context,
  //             builder: (ctx) => AlertDialog(
  //               title: const Text('Confirm Delete'),
  //               content: Text(
  //                 widget.deleteConfirmMessage ?? 'Are you sure?',
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.of(ctx).pop(false),
  //                   child: const Text('Cancel'),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () => Navigator.of(ctx).pop(true),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.red,
  //                   ),
  //                   child: const Text('Delete'),
  //                 ),
  //               ],
  //             ),
  //           );
  //           if (confirm != true) return false;
  //           try {
  //             final result = await widget.onDelete?.call();
  //             showSuccess(result?.message ?? "Success");
  //             return true;
  //           } catch (e) {
  //             showError(e.toString());
  //             return false;
  //           }
  //         },
  //         onUpdate: (details) {
  //           setState(() => _elevation = details.progress > 0 ? 3 : 0);
  //         },
  //         child: tile,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isWindows = !kIsWeb && Platform.isWindows;
    final isSwipeablePlatform = kIsWeb || Platform.isAndroid;

    final tileContent = widget.contentBuilder(context, widget.item);

    final tile = GestureDetector(
      onTapDown: (_) => setState(() => _elevation = 3),
      onTapCancel: () => setState(() => _elevation = 0),
      onTapUp: (_) => Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _elevation = 0);
      }),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              if (_elevation > 0)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
            ],
          ),
          child: isWindows && widget.enableDelete
              ? Row(
            children: [
              Expanded(child: tileContent),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: Text(
                        widget.deleteConfirmMessage ?? 'Are you sure?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  try {
                    final result = await widget.onDelete?.call();
                    showSuccess(result?.message ?? "Success");
                  } catch (e) {
                    showError(e.toString());
                  }
                },
              ),
            ],
          )
              : tileContent,
        ),
      ),
    );

    // No delete at all? return plain tile
    if (!widget.enableDelete) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: tile,
      );
    }

    // 🌀 ANDROID + WEB → Swipeable
    if (isSwipeablePlatform) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Dismissible(
            key: ValueKey(widget.item),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: Text(
                    widget.deleteConfirmMessage ?? 'Are you sure?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return false;

              try {
                final result = await widget.onDelete?.call();
                showSuccess(result?.message ?? "Success");
                return true;
              } catch (e) {
                showError(e.toString());
                return false;
              }
            },
            onUpdate: (details) {
              setState(() => _elevation = details.progress > 0 ? 3 : 0);
            },
            child: tile,
          ),
        ),
      );
    }

    // 🖥 WINDOWS → Delete icon only
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: tile,
    );
  }

}
