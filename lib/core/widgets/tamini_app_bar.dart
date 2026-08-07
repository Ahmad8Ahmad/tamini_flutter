import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_localizations.dart';

class TaminiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool floating;
  final bool pinned;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final bool showSearch;
  final TextEditingController? searchController;
  final String? searchHint;
  final ValueChanged<String>? onSearch;

  const TaminiAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.floating = true,
    this.pinned = false,
    this.expandedHeight,
    this.flexibleSpace,
    this.showSearch = false,
    this.searchController,
    this.searchHint,
    this.onSearch,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showSearch ? 56 : 0));

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: floating,
      pinned: pinned,
      expandedHeight: expandedHeight,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: showSearch
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: searchController,
                  onSubmitted: onSearch,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: searchHint ?? AppLocalizations.of(context).searchFood,
                    hintStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppTheme.gray400,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.orange400, size: 20),
                    filled: true,
                    fillColor: AppTheme.orange50.withValues(alpha: 0.6),
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.roundedXl,
                      borderSide: const BorderSide(color: AppTheme.orange100),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.roundedXl,
                      borderSide: const BorderSide(color: AppTheme.orange100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.roundedXl,
                      borderSide: const BorderSide(color: AppTheme.orange400, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            )
          : bottom != null
              ? PreferredSize(preferredSize: const Size.fromHeight(48), child: bottom!)
              : null,
    );
  }
}
